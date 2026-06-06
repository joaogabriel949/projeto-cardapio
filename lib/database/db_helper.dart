import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Padrão Singleton para garantir apenas uma instância do banco
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Retorna a instância do banco (inicia se ainda não existir)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa e cria o banco de dados
  // Inicializa e cria o banco de dados
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'nutri_app.db');

    return await openDatabase(
      path,
      version: 4, // Incrementado para simplificar colunas e corrigir salvamento
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Cria as tabelas na primeira vez que o app rodar
  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabela de Usuários
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        foto TEXT,
        data_nascimento TEXT NOT NULL
      )
    ''');
    
    // Na inicialização do banco
    await db.execute('''
      CREATE TABLE IF NOT EXISTS taco_alimentos (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        categoria TEXT,
        energia_kcal REAL,
        proteina_g REAL,
        carboidrato_g REAL,
        gordura_total_g REAL,
        fibra_g REAL,
        sodio_mg REAL,
        calcio_mg REAL,
        ferro_mg REAL
      )
    ''');

    // 2. Tabela de Alimentos (com campos nutricionais simplificados)
    await db.execute('''
      CREATE TABLE alimentos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        foto TEXT,
        categoria TEXT NOT NULL,
        tipo TEXT NOT NULL,
        calorias REAL,
        proteinas REAL,
        carboidratos REAL,
        gorduras_totais REAL,
        sodio REAL,
        calcio REAL,
        ferro REAL,
        nutri_score TEXT,
        unidade_medida TEXT
      )
    ''');

    // 3. Tabela de Cardápios
    await db.execute('''
      CREATE TABLE cardapios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        cafe_id INTEGER,
        almoco_id INTEGER,
        janta_id INTEGER,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
        FOREIGN KEY (cafe_id) REFERENCES alimentos (id),
        FOREIGN KEY (almoco_id) REFERENCES alimentos (id),
        FOREIGN KEY (janta_id) REFERENCES alimentos (id)
      )
    ''');
  }

  // Migração segura: adiciona colunas nutricionais sem apagar dados existentes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final colunasParaAdicionar = {
        'calorias': 'REAL',
        'proteinas': 'REAL',
        'carboidratos': 'REAL',
        'acucares': 'REAL',
        'gorduras_totais': 'REAL',
        'gorduras_saturadas': 'REAL',
        'gorduras_trans': 'REAL',
        'sodio': 'REAL',
        'fibras': 'REAL',
        'vitamina_a': 'REAL',
        'vitamina_c': 'REAL',
        'calcio': 'REAL',
        'ferro': 'REAL',
        'nutri_score': 'TEXT',
      };

      for (var entry in colunasParaAdicionar.entries) {
        await db.execute(
          'ALTER TABLE alimentos ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE alimentos ADD COLUMN unidade_medida TEXT',
      );
    }
    if (oldVersion < 4) {
      // SQLite não suporta DROP COLUMN — renomeia, recria e copia apenas as
      // colunas da v4, preservando todos os dados do usuário.
      await db.execute('ALTER TABLE alimentos RENAME TO alimentos_old');
      await db.execute('''
        CREATE TABLE alimentos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          foto TEXT,
          categoria TEXT NOT NULL,
          tipo TEXT NOT NULL,
          calorias REAL,
          proteinas REAL,
          carboidratos REAL,
          gorduras_totais REAL,
          sodio REAL,
          calcio REAL,
          ferro REAL,
          nutri_score TEXT,
          unidade_medida TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO alimentos (id, nome, foto, categoria, tipo, calorias, proteinas,
          carboidratos, gorduras_totais, sodio, calcio, ferro, nutri_score, unidade_medida)
        SELECT id, nome, foto, categoria, tipo, calorias, proteinas,
          carboidratos, gorduras_totais, sodio, calcio, ferro, nutri_score, unidade_medida
        FROM alimentos_old
      ''');
      await db.execute('DROP TABLE alimentos_old');
    }
  }

  // =========================================================
  // MÉTODOS PARA ALIMENTOS
  // =========================================================

  Future<int> insertAlimento(Map<String, dynamic> alimento) async {
    Database db = await database;
    return await db.insert('alimentos', alimento);
  }

  Future<List<Map<String, dynamic>>> getAlimentos() async {
    Database db = await database;
    return await db.query('alimentos');
  }

  Future<List<Map<String, dynamic>>> getAlimentoPorNome(String nome) async {
    Database db = await database;
    return await db.query(
      'alimentos',
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
    );
  }

  Future<int> deleteAlimento(int id) async {
    Database db = await database;
    return await db.delete(
      'alimentos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================================================
  // MÉTODOS PARA USUÁRIOS E CARDÁPIOS
  // =========================================================

  Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    Database db = await database;
    return await db.insert('usuarios', usuario);
  }

  Future<List<Map<String, dynamic>>> getTodosUsuarios() async {
    Database db = await database;
    return await db.query('usuarios', orderBy: 'nome ASC');
  }

  Future<List<Map<String, dynamic>>> getUsuarioPorNome(String nome) async {
    Database db = await database;
    return await db.query(
      'usuarios',
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
    );
  }

  Future<int> insertCardapio(Map<String, dynamic> cardapio) async {
    Database db = await database;
    return await db.insert('cardapios', cardapio);
  }

  Future<List<Map<String, dynamic>>> getTodosCardapios() async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT
        c.id,
        c.usuario_id,
        u.nome  AS paciente_nome,
        c.cafe_id,
        a1.nome AS cafe_nome,
        c.almoco_id,
        a2.nome AS almoco_nome,
        c.janta_id,
        a3.nome AS janta_nome
      FROM cardapios c
      LEFT JOIN usuarios   u  ON u.id  = c.usuario_id
      LEFT JOIN alimentos  a1 ON a1.id = c.cafe_id
      LEFT JOIN alimentos  a2 ON a2.id = c.almoco_id
      LEFT JOIN alimentos  a3 ON a3.id = c.janta_id
      ORDER BY c.id DESC
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCardapiosPorUsuario(
      int usuarioId) async {
    Database db = await database;
    return await db.query(
      'cardapios',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

  // Para uso exclusivo em testes — fecha, deleta e reseta a instância do banco.
  static Future<void> resetDatabase() async {
    await _database?.close();
    _database = null;
    final dbPath = await getDatabasesPath();
    await deleteDatabase(join(dbPath, 'nutri_app.db'));
  }
}

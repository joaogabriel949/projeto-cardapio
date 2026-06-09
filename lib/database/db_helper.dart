import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/cardapio_model.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'nutri_app.db');
    return openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        // Ativa integridade referencial no SQLite (desabilitada por padrão)
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ─── DDL ──────────────────────────────────────────────────────────────────

  static const _sqlUsuarios = '''
    CREATE TABLE IF NOT EXISTS usuarios(
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      nome            TEXT NOT NULL,
      foto            TEXT,
      data_nascimento TEXT NOT NULL
    )
  ''';

  static const _sqlTacoAlimentos = '''
    CREATE TABLE IF NOT EXISTS taco_alimentos(
      id              INTEGER PRIMARY KEY,
      nome            TEXT NOT NULL,
      categoria       TEXT,
      energia_kcal    REAL,
      proteina_g      REAL,
      carboidrato_g   REAL,
      gordura_total_g REAL,
      fibra_g         REAL,
      sodio_mg        REAL,
      calcio_mg       REAL,
      ferro_mg        REAL
    )
  ''';

  static const _sqlAlimentos = '''
    CREATE TABLE IF NOT EXISTS alimentos(
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      nome            TEXT NOT NULL,
      foto            TEXT,
      categoria       TEXT NOT NULL,
      tipo            TEXT NOT NULL,
      calorias        REAL,
      proteinas       REAL,
      carboidratos    REAL,
      gorduras_totais REAL,
      sodio           REAL,
      calcio          REAL,
      ferro           REAL,
      nutri_score     TEXT,
      unidade_medida  TEXT
    )
  ''';

  static const _sqlCardapios = '''
    CREATE TABLE IF NOT EXISTS cardapios(
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      usuario_id      INTEGER,
      nome            TEXT NOT NULL,
      data_criacao    TEXT NOT NULL,
      observacoes     TEXT,
      instrucoes      TEXT,
      restricoes      TEXT,
      info_adicionais TEXT,
      status          TEXT DEFAULT 'finalizado',
      FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    )
  ''';

  static const _sqlRefeicoes = '''
    CREATE TABLE IF NOT EXISTS refeicoes(
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      cardapio_id INTEGER NOT NULL,
      nome        TEXT NOT NULL,
      horario     TEXT,
      ordem       INTEGER DEFAULT 0,
      FOREIGN KEY (cardapio_id) REFERENCES cardapios(id) ON DELETE CASCADE
    )
  ''';

  static const _sqlRefeicaoItens = '''
    CREATE TABLE IF NOT EXISTS refeicao_itens(
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      refeicao_id       INTEGER NOT NULL,
      alimento_id       INTEGER NOT NULL,
      quantidade        REAL NOT NULL DEFAULT 100.0,
      unidade           TEXT NOT NULL DEFAULT 'g',
      calorias_calc     REAL,
      proteinas_calc    REAL,
      carboidratos_calc REAL,
      gorduras_calc     REAL,
      sodio_calc        REAL,
      FOREIGN KEY (refeicao_id) REFERENCES refeicoes(id) ON DELETE CASCADE,
      FOREIGN KEY (alimento_id) REFERENCES alimentos(id)
    )
  ''';

  static const _sqlCardapioItens = '''
    CREATE TABLE IF NOT EXISTS cardapio_itens(
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      cardapio_id       INTEGER NOT NULL,
      alimento_id       INTEGER NOT NULL,
      quantidade        REAL NOT NULL DEFAULT 100.0,
      unidade           TEXT NOT NULL DEFAULT 'g',
      calorias_calc     REAL,
      proteinas_calc    REAL,
      carboidratos_calc REAL,
      gorduras_calc     REAL,
      sodio_calc        REAL,
      FOREIGN KEY (cardapio_id) REFERENCES cardapios(id) ON DELETE CASCADE,
      FOREIGN KEY (alimento_id) REFERENCES alimentos(id)
    )
  ''';

  // ─── Criação ───────────────────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_sqlUsuarios);
    await db.execute(_sqlTacoAlimentos);
    await db.execute(_sqlAlimentos);
    await db.execute(_sqlCardapios);
    await db.execute(_sqlRefeicoes);
    await db.execute(_sqlRefeicaoItens);
    await db.execute(_sqlCardapioItens);
  }

  // ─── Migração incremental ──────────────────────────────────────────────────

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS alimentos');
      await db.execute(_sqlAlimentos);
    }
    if (oldVersion < 5) {
      // Recria cardapios com a nova estrutura (campos extras + sem FKs antigas)
      await db.execute('DROP TABLE IF EXISTS cardapios');
      await db.execute(_sqlCardapios);
      // Cria as novas tabelas relacionais
      await db.execute(_sqlRefeicoes);
      await db.execute(_sqlRefeicaoItens);
    }
    if (oldVersion < 6) {
      await db.execute(_sqlCardapioItens);
    }
  }

  // ─── ALIMENTOS ─────────────────────────────────────────────────────────────

  Future<int> insertAlimento(Map<String, dynamic> data) async =>
      (await database).insert('alimentos', data);

  /// Busca com filtros opcionais
  Future<List<Map<String, dynamic>>> getAlimentos({
    String? searchTerm,
    String? categoria,
    String? tipo,
    String? nutriScore,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args      = <dynamic>[];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      conditions.add('nome LIKE ?');
      args.add('%$searchTerm%');
    }
    if (categoria != null && categoria.isNotEmpty) {
      conditions.add('categoria LIKE ?');
      args.add('%$categoria%');
    }
    if (tipo != null && tipo.isNotEmpty) {
      conditions.add('tipo = ?');
      args.add(tipo);
    }
    if (nutriScore != null && nutriScore.isNotEmpty) {
      conditions.add('nutri_score = ?');
      args.add(nutriScore);
    }

    return db.query(
      'alimentos',
      where:     conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy:   'nome ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAlimentoPorNome(String nome) async =>
      getAlimentos(searchTerm: nome);

  Future<int> deleteAlimento(int id) async =>
      (await database).delete('alimentos', where: 'id = ?', whereArgs: [id]);

  // ─── USUÁRIOS ──────────────────────────────────────────────────────────────

  Future<int> insertUsuario(Map<String, dynamic> data) async =>
      (await database).insert('usuarios', data);

  Future<List<Map<String, dynamic>>> getUsuarioPorNome(String nome) async =>
      (await database).query('usuarios',
          where: 'nome LIKE ?', whereArgs: ['%$nome%']);

  Future<List<Map<String, dynamic>>> getTodosUsuarios() async {
    final db = await database;
    return db.query('usuarios', orderBy: 'nome ASC');
  }

  // ─── CARDÁPIOS ─────────────────────────────────────────────────────────────

  Future<int> insertCardapio(Map<String, dynamic> data) async =>
      (await database).insert('cardapios', data);

  Future<int> updateCardapio(int id, Map<String, dynamic> data) async =>
      (await database)
          .update('cardapios', data, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteCardapio(int id) async =>
      (await database).delete('cardapios', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getCardapios({int? usuarioId}) async {
    final db = await database;
    return db.query(
      'cardapios',
      where:     usuarioId != null ? 'usuario_id = ?' : null,
      whereArgs: usuarioId != null ? [usuarioId] : null,
      orderBy:   'data_criacao DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTodosCardapios() async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.*, u.nome as paciente_nome
      FROM cardapios c
      LEFT JOIN usuarios u ON c.usuario_id = u.id
      ORDER BY c.data_criacao DESC
    ''');
  }

  // Mantido para compatibilidade com código legado
  Future<List<Map<String, dynamic>>> getCardapiosPorUsuario(
          int usuarioId) async =>
      getCardapios(usuarioId: usuarioId);

  // ─── REFEIÇÕES ─────────────────────────────────────────────────────────────

  Future<int> insertRefeicao(Map<String, dynamic> data) async =>
      (await database).insert('refeicoes', data);

  Future<List<Map<String, dynamic>>> getRefeicoesPorCardapio(
          int cardapioId) async =>
      (await database).query('refeicoes',
          where: 'cardapio_id = ?',
          whereArgs: [cardapioId],
          orderBy: 'ordem ASC');

  // ─── ITENS ─────────────────────────────────────────────────────────────────

  Future<int> insertRefeicaoItem(Map<String, dynamic> data) async =>
      (await database).insert('refeicao_itens', data);

  Future<int> updateRefeicaoItem(int id, Map<String, dynamic> data) async =>
      (await database).update('refeicao_itens', data,
          where: 'id = ?', whereArgs: [id]);

  Future<int> deleteRefeicaoItem(int id) async =>
      (await database)
          .delete('refeicao_itens', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getItensPorRefeicao(
      int refeicaoId) async =>
      (await database).rawQuery('''
        SELECT ri.*, a.nome, a.foto, a.calorias, a.proteinas,
              a.carboidratos, a.gorduras_totais, a.sodio,
              a.calcio, a.ferro, a.nutri_score, a.unidade_medida,
              a.categoria, a.tipo
        FROM refeicao_itens ri
        INNER JOIN alimentos a ON ri.alimento_id = a.id
        WHERE ri.refeicao_id = ?
        ORDER BY ri.id ASC
      ''', [refeicaoId]);

  Future<List<Map<String, dynamic>>> getItensAvulsos(int cardapioId) async =>
      (await database).rawQuery('''
        SELECT ci.*, a.nome, a.foto, a.calorias, a.proteinas,
              a.carboidratos, a.gorduras_totais, a.sodio,
              a.calcio, a.ferro, a.nutri_score, a.unidade_medida,
              a.categoria, a.tipo
        FROM cardapio_itens ci
        INNER JOIN alimentos a ON ci.alimento_id = a.id
        WHERE ci.cardapio_id = ?
        ORDER BY ci.id ASC
      ''', [cardapioId]);

  // ─── CARDÁPIO COMPLETO (JOIN) ───────────────────────────────────────────────

  Future<Map<String, dynamic>?> getCardapioCompleto(int cardapioId) async {
    final db = await database;
    final rows =
        await db.query('cardapios', where: 'id = ?', whereArgs: [cardapioId]);
    if (rows.isEmpty) return null;

    final cardapio = Map<String, dynamic>.from(rows.first);
    final refeicoes = await getRefeicoesPorCardapio(cardapioId);

    final refeicoesComItens = <Map<String, dynamic>>[];
    for (final ref in refeicoes) {
      final r = Map<String, dynamic>.from(ref);
      r['itens'] = await getItensPorRefeicao(ref['id'] as int);
      refeicoesComItens.add(r);
    }
    cardapio['refeicoes'] = refeicoesComItens;
    
    cardapio['itens_avulsos'] = await getItensAvulsos(cardapioId);

    return cardapio;
  }

  // ─── TRANSAÇÃO: salva cardápio completo atomicamente ───────────────────────

  Future<int> salvarCardapioCompleto(CardapioModel cardapio) async {
    final db = await database;
    return db.transaction((txn) async {
      final cardapioId = await txn.insert('cardapios', cardapio.toMap());

      for (int i = 0; i < cardapio.refeicoes.length; i++) {
        final ref = cardapio.refeicoes[i];

        final refMap = {
          ...ref.toMap(),
          'cardapio_id': cardapioId,
          'ordem': i,
        };

        final refeicaoId = await txn.insert('refeicoes', refMap);

        for (final item in ref.itens) {
          final itemMap = {
            ...item.toMap(),
            'refeicao_id': refeicaoId,
          };

          await txn.insert('refeicao_itens', itemMap);
        }
      }

      for (final item in cardapio.itensAvulsos) {
        final itemMap = {
          ...item.toMap(),
          'cardapio_id': cardapioId,
        };
        // Remove refeicao_id if it exists from toMap
        itemMap.remove('refeicao_id');
        await txn.insert('cardapio_itens', itemMap);
      }

      return cardapioId;
    });
  }

  static Future<void> resetDatabase() async {
    final path = join(await getDatabasesPath(), 'nutri_app.db');
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    await deleteDatabase(path);
  }
}
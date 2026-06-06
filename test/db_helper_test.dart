import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:goomer_nutri/database/db_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.resetDatabase();
  });

  group('Alimentos', () {
    test('insere e lista alimento', () async {
      final db = DatabaseHelper();
      await db.insertAlimento({
        'nome': 'Banana',
        'categoria': 'Frutas',
        'tipo': 'Fruta',
        'calorias': 89.0,
      });
      final lista = await db.getAlimentos();
      expect(lista.length, 1);
      expect(lista.first['nome'], 'Banana');
      expect(lista.first['calorias'], 89.0);
    });

    test('busca por nome (LIKE)', () async {
      final db = DatabaseHelper();
      await db.insertAlimento({'nome': 'Arroz branco', 'categoria': 'Cereais', 'tipo': 'Carboidrato'});
      await db.insertAlimento({'nome': 'Arroz integral', 'categoria': 'Cereais', 'tipo': 'Carboidrato'});
      await db.insertAlimento({'nome': 'Feijão preto', 'categoria': 'Leguminosas', 'tipo': 'Proteína'});
      final resultado = await db.getAlimentoPorNome('arroz');
      expect(resultado.length, 2);
    });

    test('exclui alimento por id', () async {
      final db = DatabaseHelper();
      final id = await db.insertAlimento({'nome': 'Maçã', 'categoria': 'Frutas', 'tipo': 'Fruta'});
      await db.deleteAlimento(id);
      final lista = await db.getAlimentos();
      expect(lista, isEmpty);
    });

    test('lista vazia quando não há alimentos', () async {
      final lista = await DatabaseHelper().getAlimentos();
      expect(lista, isEmpty);
    });
  });

  group('Usuários', () {
    test('insere e lista usuário', () async {
      final db = DatabaseHelper();
      await db.insertUsuario({
        'nome': 'João Silva',
        'data_nascimento': '1995-03-10T00:00:00.000',
      });
      final lista = await db.getTodosUsuarios();
      expect(lista.length, 1);
      expect(lista.first['nome'], 'João Silva');
    });

    test('lista em ordem alfabética', () async {
      final db = DatabaseHelper();
      await db.insertUsuario({'nome': 'Zilda', 'data_nascimento': '1990-01-01T00:00:00.000'});
      await db.insertUsuario({'nome': 'Ana', 'data_nascimento': '1985-06-15T00:00:00.000'});
      final lista = await db.getTodosUsuarios();
      expect(lista.first['nome'], 'Ana');
      expect(lista.last['nome'], 'Zilda');
    });

    test('retorna id do usuário inserido', () async {
      final id = await DatabaseHelper().insertUsuario({
        'nome': 'Carlos',
        'data_nascimento': '2000-07-20T00:00:00.000',
      });
      expect(id, greaterThan(0));
    });
  });

  group('Cardápios', () {
    test('insere cardápio e retorna com nomes via LEFT JOIN', () async {
      final db = DatabaseHelper();
      final usuarioId = await db.insertUsuario({
        'nome': 'Ana',
        'data_nascimento': '2000-01-01T00:00:00.000',
      });
      final cafeId = await db.insertAlimento({
        'nome': 'Aveia',
        'categoria': 'Cereais',
        'tipo': 'Carboidrato',
      });
      final almocoId = await db.insertAlimento({
        'nome': 'Frango grelhado',
        'categoria': 'Carnes',
        'tipo': 'Proteína',
      });
      await db.insertCardapio({
        'usuario_id': usuarioId,
        'cafe_id': cafeId,
        'almoco_id': almocoId,
      });
      final cardapios = await db.getTodosCardapios();
      expect(cardapios.length, 1);
      expect(cardapios.first['paciente_nome'], 'Ana');
      expect(cardapios.first['cafe_nome'], 'Aveia');
      expect(cardapios.first['almoco_nome'], 'Frango grelhado');
      expect(cardapios.first['janta_nome'], isNull);
    });

    test('cardápio sem paciente tem paciente_nome null', () async {
      final db = DatabaseHelper();
      final alimentoId = await db.insertAlimento({
        'nome': 'Iogurte',
        'categoria': 'Laticínios',
        'tipo': 'Proteína',
      });
      await db.insertCardapio({'cafe_id': alimentoId});
      final cardapios = await db.getTodosCardapios();
      expect(cardapios.first['paciente_nome'], isNull);
      expect(cardapios.first['cafe_nome'], 'Iogurte');
    });

    test('ordena cardápios do mais recente para o mais antigo', () async {
      final db = DatabaseHelper();
      await db.insertCardapio({'usuario_id': null});
      await db.insertCardapio({'usuario_id': null});
      final cardapios = await db.getTodosCardapios();
      expect(cardapios.first['id'], greaterThan(cardapios.last['id'] as int));
    });
  });
}

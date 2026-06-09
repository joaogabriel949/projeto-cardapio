import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:goomer_nutri/database/db_helper.dart';
import 'package:goomer_nutri/data/models/alimento_model.dart';
import 'package:goomer_nutri/data/models/cardapio_model.dart';

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
      await db.insertAlimento({
        'nome': 'Arroz branco',
        'categoria': 'Cereais',
        'tipo': 'Carboidrato'
      });
      await db.insertAlimento({
        'nome': 'Arroz integral',
        'categoria': 'Cereais',
        'tipo': 'Carboidrato'
      });
      await db.insertAlimento({
        'nome': 'Feijão preto',
        'categoria': 'Leguminosas',
        'tipo': 'Proteína'
      });
      final resultado = await db.getAlimentoPorNome('arroz');
      expect(resultado.length, 2);
    });

    test('exclui alimento por id', () async {
      final db = DatabaseHelper();
      final id = await db.insertAlimento(
          {'nome': 'Maçã', 'categoria': 'Frutas', 'tipo': 'Fruta'});
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
      await db.insertUsuario(
          {'nome': 'Zilda', 'data_nascimento': '1990-01-01T00:00:00.000'});
      await db.insertUsuario(
          {'nome': 'Ana', 'data_nascimento': '1985-06-15T00:00:00.000'});
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
    test('insere e lista cardápio simples', () async {
      final db = DatabaseHelper();
      final usuarioId = await db.insertUsuario({
        'nome': 'Ana',
        'data_nascimento': '2000-01-01T00:00:00.000',
      });

      await db.insertCardapio({
        'usuario_id': usuarioId,
        'nome': 'Cardápio Secagem',
        'data_criacao': '2026-06-09T00:00:00.000',
      });

      final cardapios = await db.getTodosCardapios();
      expect(cardapios.length, 1);
      expect(cardapios.first['nome'], 'Cardápio Secagem');
      expect(cardapios.first['paciente_nome'], 'Ana');
    });

    test('salva e recupera cardápio completo com refeições e itens', () async {
      final db = DatabaseHelper();
      final usuarioId = await db.insertUsuario({
        'nome': 'Bruno',
        'data_nascimento': '1995-10-15T00:00:00.000',
      });

      final alimentoId = await db.insertAlimento({
        'nome': 'Iogurte Natural',
        'categoria': 'Laticínios',
        'tipo': 'Proteína',
        'calorias': 60.0,
      });

      final banana = AlimentoModel(
        id: alimentoId,
        nome: 'Iogurte Natural',
        categoria: 'Laticínios',
        tipo: 'Proteína',
        calorias: 60.0,
      );

      final item = RefeicaoItemModel(
        alimento: banana,
        quantidade: 150.0,
      );

      final lanche = RefeicaoModel(
        nome: 'Lanche da Tarde',
        horario: '16:00',
        itens: [item],
      );

      final cardapioModel = CardapioModel(
        usuarioId: usuarioId,
        nome: 'Plano Bulk',
        dataCriacao: '2026-06-09T00:00:00.000',
        refeicoes: [lanche],
      );

      final cardapioId = await db.salvarCardapioCompleto(cardapioModel);
      expect(cardapioId, greaterThan(0));

      final completo = await db.getCardapioCompleto(cardapioId);
      expect(completo, isNotNull);
      expect(completo!['nome'], 'Plano Bulk');
      
      final refeicoes = completo['refeicoes'] as List;
      expect(refeicoes.length, 1);
      expect(refeicoes.first['nome'], 'Lanche da Tarde');

      final itens = refeicoes.first['itens'] as List;
      expect(itens.length, 1);
      expect(itens.first['nome'], 'Iogurte Natural');
      expect(itens.first['quantidade'], 150.0);
    });

    test('salva cardápio com usuarioId nulo', () async {
      final db = DatabaseHelper();
      final alimentoId = await db.insertAlimento({
        'nome': 'Iogurte Natural',
        'categoria': 'Laticínios',
        'tipo': 'Proteína',
        'calorias': 60.0,
      });

      final banana = AlimentoModel(
        id: alimentoId,
        nome: 'Iogurte Natural',
        categoria: 'Laticínios',
        tipo: 'Proteína',
        calorias: 60.0,
      );

      final item = RefeicaoItemModel(
        alimento: banana,
        quantidade: 150.0,
      );

      final lanche = RefeicaoModel(
        nome: 'Lanche da Tarde',
        horario: '16:00',
        itens: [item],
      );

      final cardapioModel = CardapioModel(
        usuarioId: null,
        nome: 'Plano Bulk Sem Usuario',
        dataCriacao: '2026-06-09T00:00:00.000',
        refeicoes: [lanche],
      );

      final cardapioId = await db.salvarCardapioCompleto(cardapioModel);
      expect(cardapioId, greaterThan(0));
    });


    test('ordena cardápios do mais recente para o mais antigo', () async {
      final db = DatabaseHelper();
      await db.insertCardapio({
        'nome': 'Cardápio A',
        'data_criacao': '2026-06-09T01:00:00.000',
      });
      await db.insertCardapio({
        'nome': 'Cardápio B',
        'data_criacao': '2026-06-09T02:00:00.000',
      });

      final cardapios = await db.getTodosCardapios();
      expect(cardapios.length, 2);
      expect(cardapios.first['nome'], 'Cardápio B');
      expect(cardapios.last['nome'], 'Cardápio A');
    });
  });
}

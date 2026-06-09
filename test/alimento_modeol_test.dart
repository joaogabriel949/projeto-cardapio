import 'package:flutter_test/flutter_test.dart';
import 'package:goomer_nutri/data/models/alimento_model.dart';
import 'package:goomer_nutri/data/models/usuario_model.dart';
import 'package:goomer_nutri/data/models/cardapio_model.dart';

void main() {
  group('AlimentoModel', () {
    test('fromMap com todos os campos', () {
      final map = {
        'id': 1,
        'nome': 'Arroz branco cozido',
        'foto': null,
        'categoria': 'Cereais e derivados',
        'tipo': 'Carboidrato',
        'calorias': 130.0,
        'proteinas': 2.5,
        'carboidratos': 28.0,
        'gorduras_totais': 0.3,
        'sodio': 1.0,
        'calcio': 4.0,
        'ferro': 0.2,
        'nutri_score': 'B',
        'unidade_medida': '100g',
      };
      final a = AlimentoModel.fromMap(map);
      expect(a.id, 1);
      expect(a.nome, 'Arroz branco cozido');
      expect(a.calorias, 130.0);
      expect(a.proteinas, 2.5);
      expect(a.carboidratos, 28.0);
      expect(a.nutriScore, 'B');
      expect(a.unidadeMedida, '100g');
    });

    test('fromMap com campos ausentes usa defaults e nulls', () {
      final a =
          AlimentoModel.fromMap({'nome': 'Teste', 'categoria': '', 'tipo': ''});
      expect(a.id, isNull);
      expect(a.calorias, isNull);
      expect(a.proteinas, isNull);
      expect(a.nutriScore, isNull);
      expect(a.foto, isNull);
    });

    test('fromMap converte num para double', () {
      final a = AlimentoModel.fromMap({
        'nome': 'Frango',
        'categoria': 'Carnes',
        'tipo': 'Proteína',
        'calorias': 165,
        'proteinas': 31,
      });
      expect(a.calorias, isA<double>());
      expect(a.calorias, 165.0);
      expect(a.proteinas, 31.0);
    });

    test('toMap inclui id quando presente', () {
      const a = AlimentoModel(
        id: 7,
        nome: 'Maçã',
        categoria: 'Frutas',
        tipo: 'Fruta',
        calorias: 52.0,
      );
      final map = a.toMap();
      expect(map['id'], 7);
      expect(map['nome'], 'Maçã');
      expect(map['calorias'], 52.0);
    });

    test('toMap omite id quando null', () {
      const a = AlimentoModel(nome: 'Banana', categoria: 'Frutas', tipo: 'Fruta');
      final map = a.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('round-trip fromMap -> toMap -> fromMap preserva valores', () {
      const original = AlimentoModel(
        id: 3,
        nome: 'Frango grelhado',
        categoria: 'Carnes',
        tipo: 'Proteína',
        calorias: 165.0,
        proteinas: 31.0,
        carboidratos: 0.0,
        gordurasTotais: 3.6,
        sodio: 74.0,
        nutriScore: 'A',
      );
      final restored = AlimentoModel.fromMap(original.toMap());
      expect(restored.nome, original.nome);
      expect(restored.calorias, original.calorias);
      expect(restored.proteinas, original.proteinas);
      expect(restored.nutriScore, original.nutriScore);
    });
  });

  group('Usuario', () {
    test('fromMap com todos os campos', () {
      final map = {
        'id': 2,
        'nome': 'Maria Silva',
        'foto': 'https://example.com/foto.jpg',
        'data_nascimento': '1990-05-15T00:00:00.000',
      };
      final u = Usuario.fromMap(map);
      expect(u.id, 2);
      expect(u.nome, 'Maria Silva');
      expect(u.foto, 'https://example.com/foto.jpg');
      expect(u.dataNascimento, '1990-05-15T00:00:00.000');
    });

    test('fromMap com campos ausentes usa defaults', () {
      final u = Usuario.fromMap({});
      expect(u.id, isNull);
      expect(u.nome, '');
      expect(u.dataNascimento, '');
      expect(u.foto, isNull);
    });

    test('toMap omite id quando null', () {
      final u =
          Usuario(nome: 'Teste', dataNascimento: '2000-01-01T00:00:00.000');
      expect(u.toMap().containsKey('id'), isFalse);
    });
  });

  group('CardapioModel', () {
    test('calcula totais corretamente com refeições e itens', () {
      final banana = AlimentoModel(
        id: 1,
        nome: 'Banana',
        categoria: 'Frutas',
        tipo: 'Fruta',
        calorias: 89.0,
        proteinas: 1.1,
        carboidratos: 22.8,
        gordurasTotais: 0.3,
        sodio: 1.0,
      );

      final aveia = AlimentoModel(
        id: 2,
        nome: 'Aveia',
        categoria: 'Cereais',
        tipo: 'Carboidrato',
        calorias: 389.0,
        proteinas: 16.9,
        carboidratos: 66.3,
        gordurasTotais: 6.9,
        sodio: 2.0,
      );

      final item1 = RefeicaoItemModel(
        alimento: banana,
        quantidade: 100.0,
      );

      final item2 = RefeicaoItemModel(
        alimento: aveia,
        quantidade: 50.0,
      );

      final cafe = RefeicaoModel(
        nome: 'Café da Manhã',
        itens: [item1, item2],
      );

      final cardapio = CardapioModel(
        nome: 'Cardápio Teste',
        dataCriacao: '2026-06-09T00:00:00.000',
        refeicoes: [cafe],
      );

      expect(cardapio.totalCalorias, closeTo(283.5, 0.01));
      expect(cardapio.totalProteinas, closeTo(9.55, 0.01));
      expect(cardapio.totalCarboidratos, closeTo(55.95, 0.01));
      expect(cardapio.totalGorduras, closeTo(3.75, 0.01));
      expect(cardapio.totalSodio, closeTo(2.0, 0.01));
    });

    test('toMap serializa os campos do cardapio', () {
      final cardapio = CardapioModel(
        id: 10,
        usuarioId: 2,
        nome: 'Cardápio B',
        dataCriacao: '2026-06-09T00:00:00.000',
        observacoes: 'Sem açúcar',
        status: 'finalizado',
      );

      final map = cardapio.toMap();
      expect(map['id'], 10);
      expect(map['usuario_id'], 2);
      expect(map['nome'], 'Cardápio B');
      expect(map['observacoes'], 'Sem açúcar');
      expect(map['status'], 'finalizado');
    });
  });
}

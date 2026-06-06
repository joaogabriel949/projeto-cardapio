import 'package:flutter_test/flutter_test.dart';
import 'package:goomer_nutri/models/alimento.dart';
import 'package:goomer_nutri/models/usuario.dart';
import 'package:goomer_nutri/models/cardapio.dart';

void main() {
  group('Alimento', () {
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
      final a = Alimento.fromMap(map);
      expect(a.id, 1);
      expect(a.nome, 'Arroz branco cozido');
      expect(a.calorias, 130.0);
      expect(a.proteinas, 2.5);
      expect(a.carboidratos, 28.0);
      expect(a.nutriScore, 'B');
      expect(a.unidadeMedida, '100g');
    });

    test('fromMap com campos ausentes usa defaults e nulls', () {
      final a = Alimento.fromMap({'nome': 'Teste', 'categoria': '', 'tipo': ''});
      expect(a.id, isNull);
      expect(a.calorias, isNull);
      expect(a.proteinas, isNull);
      expect(a.nutriScore, isNull);
      expect(a.foto, isNull);
    });

    test('fromMap converte num para double', () {
      final a = Alimento.fromMap({
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
      const a = Alimento(
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
      const a = Alimento(nome: 'Banana', categoria: 'Frutas', tipo: 'Fruta');
      final map = a.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('round-trip fromMap -> toMap -> fromMap preserva valores', () {
      const original = Alimento(
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
      final restored = Alimento.fromMap(original.toMap());
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
      const u = Usuario(nome: 'Teste', dataNascimento: '2000-01-01T00:00:00.000');
      expect(u.toMap().containsKey('id'), isFalse);
    });
  });

  group('Cardapio', () {
    test('fromMap com campos JOIN preenchidos', () {
      final map = {
        'id': 1,
        'usuario_id': 2,
        'cafe_id': 3,
        'almoco_id': 4,
        'janta_id': null,
        'paciente_nome': 'Maria',
        'cafe_nome': 'Pão integral',
        'almoco_nome': 'Arroz com feijão',
        'janta_nome': null,
      };
      final c = Cardapio.fromMap(map);
      expect(c.id, 1);
      expect(c.pacienteNome, 'Maria');
      expect(c.cafeNome, 'Pão integral');
      expect(c.almocoNome, 'Arroz com feijão');
      expect(c.jantaNome, isNull);
      expect(c.jantaId, isNull);
    });

    test('toMap não inclui campos de JOIN', () {
      final c = Cardapio.fromMap({
        'id': 1,
        'usuario_id': 2,
        'cafe_id': 3,
        'paciente_nome': 'Maria',
        'cafe_nome': 'Pão',
      });
      final map = c.toMap();
      expect(map.containsKey('paciente_nome'), isFalse);
      expect(map.containsKey('cafe_nome'), isFalse);
      expect(map['cafe_id'], 3);
    });
  });
}

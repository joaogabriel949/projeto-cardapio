import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ResultadoBusca {
  final String nome;
  final String? foto;
  final String? tipoSugerido;
  final String? nutriScore;
  final Map<String, double> valoresPor100g;
  final List<Map<String, dynamic>> unidades;
  final String fonte;

  const ResultadoBusca({
    required this.nome,
    this.foto,
    this.tipoSugerido,
    this.nutriScore,
    required this.valoresPor100g,
    required this.unidades,
    required this.fonte,
  });
}

class AlimentoService {
  static List<Map<String, dynamic>> get _unidadesPadrao => [
        {'descricao': '100g', 'gramas': 100.0},
        {'descricao': 'g', 'gramas': 1.0},
        {'descricao': 'ml', 'gramas': 1.0},
      ];

  Future<ResultadoBusca?> buscar(String nome) async {
    if (nome.trim().isEmpty) return null;
    final taco = await _buscarNoTaco(nome);
    if (taco != null) return taco;
    return _buscarNaApi(nome);
  }

  Future<ResultadoBusca?> _buscarNoTaco(String nome) async {
    try {
      final jsonString =
          await rootBundle.loadString('lib/database/taco_alimentos.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final alimentos = jsonData['alimentos'] as List<dynamic>;

      final found = alimentos.firstWhere(
        (item) =>
            item['nome'].toString().toLowerCase().contains(nome.toLowerCase()),
        orElse: () => null,
      );
      if (found == null) return null;

      final valores = <String, double>{
        'calorias': (found['energia_kcal'] as num?)?.toDouble() ?? 0.0,
        'proteinas': (found['proteina_g'] as num?)?.toDouble() ?? 0.0,
        'carboidratos': (found['carboidrato_g'] as num?)?.toDouble() ?? 0.0,
        'gorduras_totais': (found['gordura_g'] as num?)?.toDouble() ?? 0.0,
        'sodio': (found['sodio_mg'] as num?)?.toDouble() ?? 0.0,
        'calcio': (found['calcio_mg'] as num?)?.toDouble() ?? 0.0,
        'ferro': (found['ferro_mg'] as num?)?.toDouble() ?? 0.0,
      };

      List<Map<String, dynamic>> unidades = [
        {'descricao': '100g', 'gramas': 100.0}
      ];
      if (found['unidades'] != null) {
        final raw = found['unidades'] as List<dynamic>;
        final vistas = <String>{'100g'};
        for (final u in raw) {
          final desc = u['descricao']?.toString().trim() ?? '';
          if (desc.isNotEmpty && vistas.add(desc)) {
            unidades.add(
                {'descricao': desc, 'gramas': (u['gramas'] as num).toDouble()});
          }
        }
      } else {
        unidades = _unidadesPadrao;
      }

      return ResultadoBusca(
        nome: found['nome'] as String,
        tipoSugerido:
            _mapearTipo([found['categoria']?.toString().trim() ?? '']),
        valoresPor100g: valores,
        unidades: unidades,
        fonte: 'taco',
      );
    } catch (e) {
      debugPrint('AlimentoService TACO: $e');
      return null;
    }
  }

  Future<ResultadoBusca?> _buscarNaApi(String nome) async {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'GoomerNutri',
      version: '1.0.0',
    );

    final configuration = ProductSearchQueryConfiguration(
      parametersList: [
        SearchTerms(terms: [nome]),
        const PageNumber(page: 1),
        const PageSize(size: 5),
      ],
      language: OpenFoodFactsLanguage.PORTUGUESE,
      fields: [
        ProductField.NAME,
        ProductField.IMAGE_FRONT_URL,
        ProductField.CATEGORIES_TAGS,
        ProductField.NUTRIMENTS,
        ProductField.NUTRISCORE,
      ],
      version: ProductQueryVersion.v3,
    );

    final result =
        await OpenFoodAPIClient.searchProducts(null, configuration);
    if (result.products == null || result.products!.isEmpty) return null;

    final produto = result.products!.first;
    final n = produto.nutriments;
    final valores = n != null
        ? <String, double>{
            'calorias':
                n.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0.0,
            'proteinas':
                n.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0.0,
            'carboidratos':
                n.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
                    0.0,
            'gorduras_totais':
                n.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0.0,
            'sodio':
                n.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0.0,
            'calcio':
                n.getValue(Nutrient.calcium, PerSize.oneHundredGrams) ?? 0.0,
            'ferro': n.getValue(Nutrient.iron, PerSize.oneHundredGrams) ?? 0.0,
          }
        : <String, double>{};

    return ResultadoBusca(
      nome: produto.productName ?? nome,
      foto: produto.imageFrontUrl,
      tipoSugerido: _mapearTipo(produto.categoriesTags ?? []),
      nutriScore: produto.nutriscore?.toUpperCase(),
      valoresPor100g: valores,
      unidades: _unidadesPadrao,
      fonte: 'api',
    );
  }

  String? _mapearTipo(List<String> tags) {
    const mapeamento = {
      'Bebida': ['en:beverages', 'drink', 'suco', 'juice', 'water', 'milk'],
      'Proteína': [
        'en:meats', 'en:fish', 'en:eggs', 'carne', 'frango', 'peixe', 'ovo', 'queijo'
      ],
      'Carboidrato': [
        'en:breads', 'en:pastas', 'pão', 'arroz', 'massa', 'farinha', 'bread'
      ],
      'Fruta': ['en:fruits', 'fruta', 'fruit'],
      'Grão': ['en:legumes', 'en:cereals', 'feijão', 'lentilha', 'aveia', 'grain'],
    };

    for (final tag in tags) {
      final tagLow = tag.toLowerCase().trim();
      for (final entry in mapeamento.entries) {
        for (final palavra in entry.value) {
          if (tagLow.contains(palavra)) return entry.key;
        }
      }
    }
    return null;
  }
}

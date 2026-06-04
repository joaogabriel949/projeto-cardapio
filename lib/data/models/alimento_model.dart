import 'package:openfoodfacts/openfoodfacts.dart';

class AlimentoModel {
  final int?    id;
  final String  nome;
  final String? foto;
  final String  categoria;
  final String  tipo;
  final double? calorias;
  final double? proteinas;
  final double? carboidratos;
  final double? gordurasTotais;
  final double? sodio;
  final double? calcio;
  final double? ferro;
  final String? nutriScore;
  final String? unidadeMedida;
  final List<Map<String, dynamic>> unidadesDisponiveis;

  const AlimentoModel({
    this.id,
    required this.nome,
    this.foto,
    required this.categoria,
    required this.tipo,
    this.calorias,
    this.proteinas,
    this.carboidratos,
    this.gordurasTotais,
    this.sodio,
    this.calcio,
    this.ferro,
    this.nutriScore,
    this.unidadeMedida,
    this.unidadesDisponiveis = const [
      {'descricao': '100g', 'gramas': 100.0},
      {'descricao': 'g', 'gramas': 1.0},
      {'descricao': 'ml', 'gramas': 1.0},
    ],
  });

  // ---------------------------------------------------------------------------
  // Helper Estático para auto-mapeamento de tipo
  // ---------------------------------------------------------------------------
  static String autoMapearTipo(List<String> tags) {
    const mapeamento = {
      'Bebida': ['en:beverages', 'drink', 'suco', 'juice', 'water', 'milk', 'bebida', 'leite'],
      'Proteína': [
        'en:meats',
        'en:fish',
        'en:eggs',
        'carne',
        'frango',
        'peixe',
        'ovo',
        'queijo',
        'pescado',
        'laticinio'
      ],
      'Carboidrato': [
        'en:breads',
        'en:pastas',
        'pão',
        'arroz',
        'massa',
        'farinha',
        'bread',
        'cereal',
        'tubérculo',
        'tuberculo'
      ],
      'Fruta': ['en:fruits', 'fruta', 'fruit'],
      'Grão': [
        'en:legumes',
        'en:cereals',
        'feijão',
        'feijao',
        'lentilha',
        'aveia',
        'grain',
        'leguminosa'
      ],
    };

    for (String tag in tags) {
      final tagLow = tag.toLowerCase().trim();
      for (var entry in mapeamento.entries) {
        for (String palavra in entry.value) {
          if (tagLow.contains(palavra)) {
            return entry.key;
          }
        }
      }
    }
    return '';
  }

  // ---------------------------------------------------------------------------
  // Factory: leitura do banco SQLite (chaves snake_case do DB)
  // ---------------------------------------------------------------------------
  factory AlimentoModel.fromMap(Map<String, dynamic> map) {
    return AlimentoModel(
      id:             map['id'] as int?,
      nome:           (map['nome'] as String?) ?? '',
      foto:           map['foto'] as String?,
      categoria:      (map['categoria'] as String?) ?? '',
      tipo:           (map['tipo'] as String?) ?? '',
      calorias:       (map['calorias'] as num?)?.toDouble(),
      proteinas:      (map['proteinas'] as num?)?.toDouble(),
      carboidratos:   (map['carboidratos'] as num?)?.toDouble(),
      gordurasTotais: (map['gorduras_totais'] as num?)?.toDouble(),
      sodio:          (map['sodio'] as num?)?.toDouble(),
      calcio:         (map['calcio'] as num?)?.toDouble(),
      ferro:          (map['ferro'] as num?)?.toDouble(),
      nutriScore:     map['nutri_score'] as String?,
      unidadeMedida:  map['unidade_medida'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Factory: JSON do TACO local (chaves como energia_kcal, proteina_g, etc.)
  // ---------------------------------------------------------------------------
  factory AlimentoModel.fromTacoJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> units = [];
    final Set<String> descricoesVistas = {'100g'};
    units.add({'descricao': '100g', 'gramas': 100.0});

    if (json['unidades'] != null) {
      final List<dynamic> unidadesOriginais = json['unidades'];
      for (var u in unidadesOriginais) {
        if (u['descricao'] != null) {
          String desc = u['descricao'].toString().trim();
          if (!descricoesVistas.contains(desc) && desc.isNotEmpty) {
            descricoesVistas.add(desc);
            units.add({
              'descricao': desc,
              'gramas': (u['gramas'] as num).toDouble(),
            });
          }
        }
      }
    } else {
      units.addAll([
        {'descricao': 'g', 'gramas': 1.0},
        {'descricao': 'ml', 'gramas': 1.0},
      ]);
    }

    final catTaco = json['categoria']?.toString().trim() ?? '';
    final tipoMapeado = autoMapearTipo([catTaco]);

    return AlimentoModel(
      nome:           (json['nome'] as String?) ?? '',
      foto:           null,
      categoria:      catTaco,
      tipo:           tipoMapeado,
      calorias:       (json['energia_kcal'] as num?)?.toDouble(),
      proteinas:      (json['proteina_g'] as num?)?.toDouble(),
      carboidratos:   (json['carboidrato_g'] as num?)?.toDouble(),
      gordurasTotais: (json['gordura_g'] as num?)?.toDouble(),
      sodio:          (json['sodio_mg'] as num?)?.toDouble(),
      calcio:         (json['calcio_mg'] as num?)?.toDouble(),
      ferro:          (json['ferro_mg'] as num?)?.toDouble(),
      nutriScore:     null,  // TACO não possui Nutri-Score
      unidadeMedida:  '100g',
      unidadesDisponiveis: units,
    );
  }

  // ---------------------------------------------------------------------------
  // Factory: produto do Open Food Facts
  // ---------------------------------------------------------------------------
  factory AlimentoModel.fromOpenFoodFacts(Product produto) {
    final n = produto.nutriments;
    final tags = produto.categoriesTags ?? [];
    final tipoMapeado = autoMapearTipo(tags);

    return AlimentoModel(
      nome:           produto.productName ?? '',
      foto:           produto.imageFrontUrl,
      categoria:      '',  // categoria de refeição é manual
      tipo:           tipoMapeado,
      calorias:       n?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
      proteinas:      n?.getValue(Nutrient.proteins, PerSize.oneHundredGrams),
      carboidratos:   n?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
      gordurasTotais: n?.getValue(Nutrient.fat, PerSize.oneHundredGrams),
      sodio:          n?.getValue(Nutrient.sodium, PerSize.oneHundredGrams),
      calcio:         n?.getValue(Nutrient.calcium, PerSize.oneHundredGrams),
      ferro:          n?.getValue(Nutrient.iron, PerSize.oneHundredGrams),
      nutriScore:     produto.nutriscore?.toUpperCase(),
      unidadeMedida:  '100g',
      unidadesDisponiveis: const [
        {'descricao': '100g', 'gramas': 100.0},
        {'descricao': 'g', 'gramas': 1.0},
        {'descricao': 'ml', 'gramas': 1.0},
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Serialização para SQLite
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nome':            nome,
      'foto':            foto,
      'categoria':       categoria,
      'tipo':            tipo,
      'calorias':        calorias,
      'proteinas':       proteinas,
      'carboidratos':    carboidratos,
      'gorduras_totais': gordurasTotais,
      'sodio':           sodio,
      'calcio':          calcio,
      'ferro':           ferro,
      'nutri_score':     nutriScore,
      'unidade_medida':  unidadeMedida,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // ---------------------------------------------------------------------------
  // Mapa de valores nutricionais por 100g (para cálculos de conversão)
  // ---------------------------------------------------------------------------
  Map<String, double> get valoresPor100g => {
    'calorias':        calorias ?? 0.0,
    'proteinas':       proteinas ?? 0.0,
    'carboidratos':    carboidratos ?? 0.0,
    'gorduras_totais': gordurasTotais ?? 0.0,
    'sodio':           sodio ?? 0.0,
    'calcio':          calcio ?? 0.0,
    'ferro':           ferro ?? 0.0,
  };

  // ---------------------------------------------------------------------------
  // copyWith para criar cópias com campos alterados
  // ---------------------------------------------------------------------------
  AlimentoModel copyWith({
    int?    id,
    String? nome,
    String? foto,
    String? categoria,
    String? tipo,
    double? calorias,
    double? proteinas,
    double? carboidratos,
    double? gordurasTotais,
    double? sodio,
    double? calcio,
    double? ferro,
    String? nutriScore,
    String? unidadeMedida,
    List<Map<String, dynamic>>? unidadesDisponiveis,
  }) {
    return AlimentoModel(
      id:             id ?? this.id,
      nome:           nome ?? this.nome,
      foto:           foto ?? this.foto,
      categoria:      categoria ?? this.categoria,
      tipo:           tipo ?? this.tipo,
      calorias:       calorias ?? this.calorias,
      proteinas:      proteinas ?? this.proteinas,
      carboidratos:   carboidratos ?? this.carboidratos,
      gordurasTotais: gordurasTotais ?? this.gordurasTotais,
      sodio:          sodio ?? this.sodio,
      calcio:         calcio ?? this.calcio,
      ferro:          ferro ?? this.ferro,
      nutriScore:     nutriScore ?? this.nutriScore,
      unidadeMedida:  unidadeMedida ?? this.unidadeMedida,
      unidadesDisponiveis: unidadesDisponiveis ?? this.unidadesDisponiveis,
    );
  }
}

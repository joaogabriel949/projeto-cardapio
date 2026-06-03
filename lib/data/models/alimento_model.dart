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
  });

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

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
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
}

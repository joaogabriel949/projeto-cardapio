import 'alimento_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Item de refeição: um alimento + quantidade
// ─────────────────────────────────────────────────────────────────────────────
class RefeicaoItemModel {
  final int?         id;
  final int?         refeicaoId;
  final AlimentoModel alimento;
  double             quantidade; // em gramas
  final String       unidade;

  RefeicaoItemModel({
    this.id,
    this.refeicaoId,
    required this.alimento,
    this.quantidade = 100.0,
    this.unidade = 'g',
  });

  // Valores calculados proporcionalmente à quantidade
  double get caloriasCalculadas    => ((alimento.calorias    ?? 0) * quantidade / 100.0);
  double get proteinasCalculadas   => ((alimento.proteinas   ?? 0) * quantidade / 100.0);
  double get carboidratosCalculados => ((alimento.carboidratos ?? 0) * quantidade / 100.0);
  double get gordurasCalculadas    => ((alimento.gordurasTotais ?? 0) * quantidade / 100.0);
  double get sodioCalculado        => ((alimento.sodio       ?? 0) * quantidade / 100.0);

  Map<String, dynamic> toMap() => {
    if (id != null)        'id': id,
    if (refeicaoId != null) 'refeicao_id': refeicaoId,
    'alimento_id':          alimento.id,
    'quantidade':           quantidade,
    'unidade':              unidade,
    'calorias_calc':        caloriasCalculadas,
    'proteinas_calc':       proteinasCalculadas,
    'carboidratos_calc':    carboidratosCalculados,
    'gorduras_calc':        gordurasCalculadas,
    'sodio_calc':           sodioCalculado,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Refeição: tem vários itens
// ─────────────────────────────────────────────────────────────────────────────
class RefeicaoModel {
  final int?                 id;
  final int?                 cardapioId;
  final String               nome;
  String?                    horario;
  final int                  ordem;
  final List<RefeicaoItemModel> itens;

  RefeicaoModel({
    this.id,
    this.cardapioId,
    required this.nome,
    this.horario,
    this.ordem = 0,
    List<RefeicaoItemModel>? itens,
  }) : itens = itens ?? [];

  double get totalCalorias     => itens.fold(0, (s, i) => s + i.caloriasCalculadas);
  double get totalProteinas    => itens.fold(0, (s, i) => s + i.proteinasCalculadas);
  double get totalCarboidratos => itens.fold(0, (s, i) => s + i.carboidratosCalculados);
  double get totalGorduras     => itens.fold(0, (s, i) => s + i.gordurasCalculadas);
  double get totalSodio        => itens.fold(0, (s, i) => s + i.sodioCalculado);

  Map<String, dynamic> toMap() => {
    if (id != null)         'id': id,
    if (cardapioId != null) 'cardapio_id': cardapioId,
    'nome':    nome,
    'horario': horario,
    'ordem':   ordem,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Cardápio: tem várias refeições
// ─────────────────────────────────────────────────────────────────────────────
class CardapioModel {
  final int?               id;
  final int?               usuarioId;
  final String             nome;
  final String             dataCriacao;
  String?                  observacoes;
  String?                  instrucoes;
  String?                  restricoes;
  String?                  infoAdicionais;
  final String             status;
  final List<RefeicaoModel> refeicoes;
  final List<RefeicaoItemModel> itensAvulsos;

  CardapioModel({
    this.id,
    this.usuarioId,
    required this.nome,
    required this.dataCriacao,
    this.observacoes,
    this.instrucoes,
    this.restricoes,
    this.infoAdicionais,
    this.status = 'finalizado',
    List<RefeicaoModel>? refeicoes,
    List<RefeicaoItemModel>? itensAvulsos,
  }) : refeicoes = refeicoes ?? [],
       itensAvulsos = itensAvulsos ?? [];

  double get totalCalorias     => refeicoes.fold(0.0, (s, r) => s + r.totalCalorias) + itensAvulsos.fold(0.0, (s, i) => s + i.caloriasCalculadas);
  double get totalProteinas    => refeicoes.fold(0.0, (s, r) => s + r.totalProteinas) + itensAvulsos.fold(0.0, (s, i) => s + i.proteinasCalculadas);
  double get totalCarboidratos => refeicoes.fold(0.0, (s, r) => s + r.totalCarboidratos) + itensAvulsos.fold(0.0, (s, i) => s + i.carboidratosCalculados);
  double get totalGorduras     => refeicoes.fold(0.0, (s, r) => s + r.totalGorduras) + itensAvulsos.fold(0.0, (s, i) => s + i.gordurasCalculadas);
  double get totalSodio        => refeicoes.fold(0.0, (s, r) => s + r.totalSodio) + itensAvulsos.fold(0.0, (s, i) => s + i.sodioCalculado);

  Map<String, dynamic> toMap() => {
    if (id != null)         'id': id,
    if (usuarioId != null)  'usuario_id': usuarioId,
    'nome':            nome,
    'data_criacao':    dataCriacao,
    'observacoes':     observacoes,
    'instrucoes':      instrucoes,
    'restricoes':      restricoes,
    'info_adicionais': infoAdicionais,
    'status':          status,
  };
}

class DbConstants {
  // ── Banco ─────────────────────────────────────────────────
  static const String dbName    = 'nutri_app.db';
  static const int    dbVersion = 5;

  // ── Tabelas ───────────────────────────────────────────────
  static const String tAlimentos     = 'alimentos';
  static const String tUsuarios      = 'usuarios';
  static const String tCardapios     = 'cardapios';
  static const String tRefeicoes     = 'refeicoes';
  static const String tRefeicaoItens = 'refeicao_itens';
  static const String tTacoAlimentos = 'taco_alimentos';

  // ── Colunas comuns ────────────────────────────────────────
  static const String cId = 'id';

  // ── Colunas cardapios ─────────────────────────────────────
  static const String cCardapioNome       = 'nome';
  static const String cCardapioDataCriacao = 'data_criacao';
  static const String cCardapioObs        = 'observacoes';
  static const String cCardapioInstrucoes = 'instrucoes';
  static const String cCardapioRestricoes = 'restricoes';
  static const String cCardapioInfo       = 'info_adicionais';
  static const String cCardapioStatus     = 'status';
}

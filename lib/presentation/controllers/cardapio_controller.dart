import 'package:flutter/foundation.dart';
import '../../../database/db_helper.dart';
import '../../../data/models/alimento_model.dart';
import '../../../data/models/cardapio_model.dart';

class CardapioController extends ChangeNotifier {
  final _db = DatabaseHelper();

  // ─── Campos do cardápio ───────────────────────────────────────────────────
  String nome           = '';
  String observacoes    = '';
  String instrucoes     = '';
  String restricoes     = '';
  String infoAdicionais = '';

  // ─── Refeições padrão pré-populadas ──────────────────────────────────────
  final List<RefeicaoModel> refeicoes = [
    RefeicaoModel(nome: 'Café da Manhã', horario: '07:00', ordem: 0),
    RefeicaoModel(nome: 'Almoço',        horario: '12:00', ordem: 1),
    RefeicaoModel(nome: 'Lanche',        horario: '15:30', ordem: 2),
    RefeicaoModel(nome: 'Jantar',        horario: '19:00', ordem: 3),
  ];

  // ─── Estado ───────────────────────────────────────────────────────────────
  bool    isLoading    = false;
  String? errorMessage;

  // ─── Totais em tempo real ─────────────────────────────────────────────────
  double get totalCalorias     => refeicoes.fold(0, (s, r) => s + r.totalCalorias);
  double get totalProteinas    => refeicoes.fold(0, (s, r) => s + r.totalProteinas);
  double get totalCarboidratos => refeicoes.fold(0, (s, r) => s + r.totalCarboidratos);
  double get totalGorduras     => refeicoes.fold(0, (s, r) => s + r.totalGorduras);
  double get totalSodio        => refeicoes.fold(0, (s, r) => s + r.totalSodio);

  int get totalItens =>
      refeicoes.fold(0, (s, r) => s + r.itens.length);

  bool get podesSalvar =>
      nome.isNotEmpty && refeicoes.any((r) => r.itens.isNotEmpty);

  // ─── Operações sobre refeições ────────────────────────────────────────────

  void adicionarRefeicao(String nomeRef, {String? horario}) {
    refeicoes.add(RefeicaoModel(
      nome:    nomeRef,
      horario: horario,
      ordem:   refeicoes.length,
    ));
    notifyListeners();
  }

  void removerRefeicao(int index) {
    if (index >= 0 && index < refeicoes.length) {
      refeicoes.removeAt(index);
      notifyListeners();
    }
  }

  void reordenarRefeicoes(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = refeicoes.removeAt(oldIndex);
    refeicoes.insert(newIndex, item);
    notifyListeners();
  }

  // ─── Operações sobre itens ────────────────────────────────────────────────

  void adicionarItem(int refeicaoIndex, AlimentoModel alimento,
      {double quantidade = 100.0, String unidade = 'g'}) {
    if (refeicaoIndex < 0 || refeicaoIndex >= refeicoes.length) return;
    refeicoes[refeicaoIndex].itens.add(RefeicaoItemModel(
      alimento:   alimento,
      quantidade: quantidade,
      unidade:    unidade,
    ));
    notifyListeners();
  }

  void atualizarQuantidade(int refeicaoIndex, int itemIndex, double quantidade) {
    if (quantidade <= 0) return;
    refeicoes[refeicaoIndex].itens[itemIndex].quantidade = quantidade;
    notifyListeners();
  }

  void removerItem(int refeicaoIndex, int itemIndex) {
    refeicoes[refeicaoIndex].itens.removeAt(itemIndex);
    notifyListeners();
  }

  // ─── Salvar ───────────────────────────────────────────────────────────────

  Future<int?> salvarCardapio() async {
    if (!podesSalvar) return null;

    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      final cardapio = CardapioModel(
        nome:           nome,
        dataCriacao:    DateTime.now().toIso8601String(),
        observacoes:    observacoes.isEmpty    ? null : observacoes,
        instrucoes:     instrucoes.isEmpty     ? null : instrucoes,
        restricoes:     restricoes.isEmpty     ? null : restricoes,
        infoAdicionais: infoAdicionais.isEmpty ? null : infoAdicionais,
        status:         'finalizado',
        refeicoes:      refeicoes,
      );
      return await _db.salvarCardapioCompleto(cardapio);
    } catch (e) {
      errorMessage = 'Erro ao salvar: $e';
      debugPrint('CardapioController.salvarCardapio: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  void reset() {
    nome           = '';
    observacoes    = '';
    instrucoes     = '';
    restricoes     = '';
    infoAdicionais = '';
    for (final r in refeicoes) { r.itens.clear(); }
    errorMessage = null;
    notifyListeners();
  }
}

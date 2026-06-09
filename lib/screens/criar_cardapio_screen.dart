import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../presentation/controllers/cardapio_controller.dart';
import '../data/models/cardapio_model.dart';
import '../presentation/widgets/cardapio/seletor_alimentos_bottom_sheet.dart';

class CriarCardapioScreen extends StatefulWidget {
  const CriarCardapioScreen({super.key});

  @override
  State<CriarCardapioScreen> createState() => _CriarCardapioScreenState();
}

class _CriarCardapioScreenState extends State<CriarCardapioScreen>
    with TickerProviderStateMixin {

  // Identidade visual do projeto
  static const _primary = Color(0xFF6200EE);
  static const _bg      = Color(0xFFFCF9F8);

  late final CardapioController _ctrl;
  late final TabController       _tabCtrl;
  final _formKey      = GlobalKey<FormState>();
  final _nomeCtrl     = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl    = CardapioController();
    _tabCtrl = TabController(length: 3, vsync: this);
    _ctrl.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tabCtrl.dispose();
    _nomeCtrl.dispose();
    super.dispose();
  }

  // ── BUILD PRINCIPAL ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildResumoTopo(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildAbaInformacoes(),
                _buildAbaRefeicoes(),
                _buildAbaResumo(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Novo Cardápio',
        style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions: [
        TextButton.icon(
          onPressed: _mostrarDialogNovaRefeicao,
          icon: const Icon(Icons.add, color: _primary, size: 20),
          label: const Text(
            'Refeição',
            style: TextStyle(
                color: _primary, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ── RESUMO NUTRICIONAL TOPO (sempre visível) ──────────────────────────────

  Widget _buildResumoTopo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        children: [
          _miniChip('🔥', _ctrl.totalCalorias.toStringAsFixed(0),
              'kcal', const Color(0xFFFF6B35)),
          const SizedBox(width: 6),
          _miniChip('💪', _ctrl.totalProteinas.toStringAsFixed(1),
              'prot', const Color(0xFF4CAF50)),
          const SizedBox(width: 6),
          _miniChip('🌾', _ctrl.totalCarboidratos.toStringAsFixed(1),
              'carb', const Color(0xFF2196F3)),
          const SizedBox(width: 6),
          _miniChip('🥑', _ctrl.totalGorduras.toStringAsFixed(1),
              'gord', const Color(0xFFFF9800)),
          const SizedBox(width: 6),
          _miniChip('🧂', _ctrl.totalSodio.toStringAsFixed(0),
              'mg Na', const Color(0xFF9C27B0)),
        ],
      ),
    );
  }

  Widget _miniChip(
      String emoji, String valor, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            Text(
              valor,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color),
              overflow: TextOverflow.ellipsis,
            ),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: color.withValues(alpha: 0.75))),
          ],
        ),
      ),
    );
  }

  // ── TAB BAR ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabCtrl,
        labelColor:          _primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor:      _primary,
        indicatorWeight:     3,
        labelStyle:   const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.info_outline,       size: 20), text: 'Informações'),
          Tab(icon: Icon(Icons.restaurant_menu,    size: 20), text: 'Refeições'),
          Tab(icon: Icon(Icons.bar_chart_rounded,  size: 20), text: 'Resumo'),
        ],
      ),
    );
  }

  // ── ABA 1 — INFORMAÇÕES ───────────────────────────────────────────────────

  Widget _buildAbaInformacoes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titulo('📋 Dados do Cardápio'),
            const SizedBox(height: 14),
            _campo(
              label: 'Nome do Cardápio *',
              hint: 'Ex: Plano Emagrecimento — Semana 1',
              controller: _nomeCtrl,
              icon: Icons.label_outline,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nome obrigatório' : null,
              onChanged: (v) => _ctrl.nome = v,
            ),
            const SizedBox(height: 14),
            _campo(
              label: 'Observações',
              hint: 'Notas gerais sobre este cardápio...',
              icon: Icons.notes,
              maxLines: 3,
              onChanged: (v) => _ctrl.observacoes = v,
            ),
            const SizedBox(height: 24),
            _titulo('📌 Instruções e Restrições'),
            const SizedBox(height: 14),
            _campo(
              label: 'Instruções de Preparo',
              hint: 'Como preparar, horários, dicas...',
              icon: Icons.checklist_rounded,
              maxLines: 4,
              onChanged: (v) => _ctrl.instrucoes = v,
            ),
            const SizedBox(height: 14),
            _campo(
              label: 'Restrições Alimentares',
              hint: 'Ex: Sem glúten, sem lactose, baixo sódio...',
              icon: Icons.block,
              maxLines: 2,
              onChanged: (v) => _ctrl.restricoes = v,
            ),
            const SizedBox(height: 14),
            _campo(
              label: 'Informações Adicionais',
              hint: 'Alertas, orientações, substituições...',
              icon: Icons.info_outline,
              maxLines: 3,
              onChanged: (v) => _ctrl.infoAdicionais = v,
            ),
          ],
        ),
      ),
    );
  }

  // ── ABA 2 — REFEIÇÕES ─────────────────────────────────────────────────────

  Widget _buildAbaRefeicoes() {
    final refs = _ctrl.refeicoes;
    final avulsos = _ctrl.itensAvulsos;

    if (refs.isEmpty && avulsos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Nenhum alimento cadastrado',
                style: TextStyle(
                    fontSize: 16, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _abrirSeletor(-1),
                  icon: const Icon(Icons.fastfood),
                  label: const Text('Adicionar Alimento'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _mostrarDialogNovaRefeicao,
                  icon: const Icon(Icons.add, color: _primary),
                  label: const Text('Nova Refeição', style: TextStyle(color: _primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        if (avulsos.isNotEmpty)
          _cardAvulsos(avulsos),
        
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: refs.length,
          onReorder: _ctrl.reordenarRefeicoes,
          itemBuilder: (ctx, i) =>
              _cardRefeicao(refs[i], i, key: ValueKey('ref_$i')),
        ),

        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _abrirSeletor(-1),
                icon: const Icon(Icons.fastfood, color: _primary),
                label: const Text('Alimento Avulso', style: TextStyle(color: _primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _mostrarDialogNovaRefeicao,
                icon: const Icon(Icons.add),
                label: const Text('Nova Refeição'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardAvulsos(List<RefeicaoItemModel> avulsos) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: Colors.orange.shade600,
            child: Row(
              children: [
                const Icon(Icons.fastfood, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Itens Avulsos',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${avulsos.fold(0.0, (s, i) => s + i.caloriasCalculadas).toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: avulsos.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 60),
            itemBuilder: (ctx, itemIdx) =>
                _tilItemAvulso(avulsos[itemIdx], itemIdx),
          ),
        ],
      ),
    );
  }

  Widget _tilItemAvulso(RefeicaoItemModel item, int itemIdx) {
    final foto = item.alimento.foto ?? '';
    final temFoto = foto.startsWith('http');

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.orange.shade100,
        backgroundImage: temFoto ? NetworkImage(foto) : null,
        child: !temFoto
            ? Icon(Icons.fastfood, color: Colors.orange.shade600, size: 18)
            : null,
      ),
      title: Text(
        item.alimento.nome,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        '${item.caloriasCalculadas.toStringAsFixed(0)} kcal · '
        'P ${item.proteinasCalculadas.toStringAsFixed(1)}g · '
        'C ${item.carboidratosCalculados.toStringAsFixed(1)}g · '
        'G ${item.gordurasCalculadas.toStringAsFixed(1)}g',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 68,
            child: TextFormField(
              initialValue: item.quantidade.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: item.unidade,
                suffixStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 6),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                ),
              ),
              onChanged: (v) {
                final q = double.tryParse(v);
                if (q != null && q > 0) {
                  _ctrl.atualizarQuantidadeAvulso(itemIdx, q);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _ctrl.removerItemAvulso(itemIdx),
            child: const Icon(Icons.close,
                color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _cardRefeicao(RefeicaoModel ref, int refIdx, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header roxo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: _primary,
            child: Row(
              children: [
                const Icon(Icons.drag_handle, color: Colors.white54, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.nome,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      if (ref.horario != null && ref.horario!.isNotEmpty)
                        Text(
                          '🕐 ${ref.horario}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                // Badge calorias
                if (ref.itens.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ref.totalCalorias.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                    ),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white70, size: 20),
                  onPressed: () => _ctrl.removerRefeicao(refIdx),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),

          // Itens
          if (ref.itens.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Nenhum alimento — toque em + para adicionar',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ref.itens.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 60),
              itemBuilder: (ctx, itemIdx) =>
                  _tilItem(ref.itens[itemIdx], refIdx, itemIdx),
            ),

          // Botão adicionar
          Padding(
            padding: const EdgeInsets.all(10),
            child: OutlinedButton.icon(
              onPressed: () => _abrirSeletor(refIdx),
              icon: const Icon(Icons.add_circle_outline,
                  color: _primary, size: 18),
              label: const Text(
                'Adicionar Alimento',
                style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 42),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tilItem(
      RefeicaoItemModel item, int refIdx, int itemIdx) {
    final foto = item.alimento.foto ?? '';
    final temFoto = foto.startsWith('http');

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: _primary.withValues(alpha: 0.1),
        backgroundImage: temFoto ? NetworkImage(foto) : null,
        child: !temFoto
            ? const Icon(Icons.fastfood, color: _primary, size: 18)
            : null,
      ),
      title: Text(
        item.alimento.nome,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13),
      ),
      subtitle: Text(
        '${item.caloriasCalculadas.toStringAsFixed(0)} kcal · '
        'P ${item.proteinasCalculadas.toStringAsFixed(1)}g · '
        'C ${item.carboidratosCalculados.toStringAsFixed(1)}g · '
        'G ${item.gordurasCalculadas.toStringAsFixed(1)}g',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo quantidade inline
          SizedBox(
            width: 68,
            child: TextFormField(
              initialValue: item.quantidade.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: item.unidade,
                suffixStyle: const TextStyle(fontSize: 10),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 6),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _primary, width: 2),
                ),
              ),
              onChanged: (v) {
                final q = double.tryParse(v);
                if (q != null && q > 0) {
                  _ctrl.atualizarQuantidade(refIdx, itemIdx, q);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _ctrl.removerItem(refIdx, itemIdx),
            child: const Icon(Icons.close,
                color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }

  // ── ABA 3 — RESUMO ────────────────────────────────────────────────────────

  Widget _buildAbaResumo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titulo('📊 Resumo Nutricional Total'),
          const SizedBox(height: 14),
          _cardMacros(),
          const SizedBox(height: 22),
          _titulo('🍽️ Por Refeição'),
          const SizedBox(height: 12),
          if (_ctrl.itensAvulsos.isNotEmpty)
            _cardResumoAvulsos(),
          ..._ctrl.refeicoes
              .where((r) => r.itens.isNotEmpty)
              .map(_cardResumoRefeicao),
          if (_ctrl.refeicoes.every((r) => r.itens.isEmpty) && _ctrl.itensAvulsos.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Adicione alimentos no cardápio\npara ver o resumo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 14),
                ),
              ),
            ),
          if (_ctrl.observacoes.isNotEmpty) ...[
            const SizedBox(height: 20),
            _titulo('📝 Observações'),
            const SizedBox(height: 8),
            _infoBox(_ctrl.observacoes, Icons.notes),
          ],
          if (_ctrl.restricoes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _titulo('⚠️ Restrições'),
            const SizedBox(height: 8),
            _infoBox(_ctrl.restricoes, Icons.block,
                color: Colors.orange),
          ],
          if (_ctrl.instrucoes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _titulo('📋 Instruções'),
            const SizedBox(height: 8),
            _infoBox(_ctrl.instrucoes, Icons.checklist_rounded,
                color: Colors.blue),
          ],
        ],
      ),
    );
  }

  Widget _cardMacros() {
    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _circuloMacro('Calorias',
                    _ctrl.totalCalorias.toStringAsFixed(0), 'kcal',
                    const Color(0xFFFF6B35)),
                _circuloMacro('Proteínas',
                    _ctrl.totalProteinas.toStringAsFixed(1), 'g',
                    const Color(0xFF4CAF50)),
                _circuloMacro('Carbs',
                    _ctrl.totalCarboidratos.toStringAsFixed(1), 'g',
                    const Color(0xFF2196F3)),
                _circuloMacro('Gorduras',
                    _ctrl.totalGorduras.toStringAsFixed(1), 'g',
                    const Color(0xFFFF9800)),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Sódio total: ${_ctrl.totalSodio.toStringAsFixed(0)} mg',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _circuloMacro(
      String label, String valor, String unidade, Color cor) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cor.withValues(alpha: 0.1),
            border: Border.all(color: cor, width: 2.5),
          ),
          alignment: Alignment.center,
          child: Text(
            valor,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: cor),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
        Text(unidade,
            style: TextStyle(fontSize: 10, color: cor)),
      ],
    );
  }

  Widget _cardResumoRefeicao(RefeicaoModel ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.restaurant_menu, color: _primary),
        title: Text(ref.nome,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${ref.totalCalorias.toStringAsFixed(0)} kcal · '
          '${ref.itens.length} alimento${ref.itens.length != 1 ? 's' : ''}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        children: ref.itens.map((item) {
          return ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.fiber_manual_record,
                size: 8, color: Colors.grey),
            title: Text(
              '${item.alimento.nome}  —  ${item.quantidade.toStringAsFixed(0)}${item.unidade}',
              style: const TextStyle(fontSize: 13),
            ),
            trailing: Text(
              '${item.caloriasCalculadas.toStringAsFixed(0)} kcal',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _cardResumoAvulsos() {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(Icons.fastfood, color: Colors.orange.shade600),
        title: const Text('Itens Avulsos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${_ctrl.itensAvulsos.fold(0.0, (s, i) => s + i.caloriasCalculadas).toStringAsFixed(0)} kcal · '
          '${_ctrl.itensAvulsos.length} alimento${_ctrl.itensAvulsos.length != 1 ? 's' : ''}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        children: _ctrl.itensAvulsos.map((item) {
          return ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.fiber_manual_record,
                size: 8, color: Colors.grey),
            title: Text(
              '${item.alimento.nome}  —  ${item.quantidade.toStringAsFixed(0)}${item.unidade}',
              style: const TextStyle(fontSize: 13),
            ),
            trailing: Text(
              '${item.caloriasCalculadas.toStringAsFixed(0)} kcal',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── FAB SALVAR ────────────────────────────────────────────────────────────

  Widget _buildFab() {
    final ativo = _ctrl.podesSalvar && !_ctrl.isLoading;
    return FloatingActionButton.extended(
      onPressed: ativo ? _salvar : null,
      backgroundColor: ativo ? _primary : Colors.grey.shade400,
      icon: _ctrl.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.save_outlined, color: Colors.white),
      label: const Text(
        'Salvar Cardápio',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── LÓGICA ────────────────────────────────────────────────────────────────

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _tabCtrl.animateTo(0);
      return;
    }
    if (!_ctrl.podesSalvar) {
      _snack(
        'Adicione pelo menos um alimento ao cardápio.',
        cor: Colors.orange,
      );
      return;
    }

    final id = await _ctrl.salvarCardapio();
    if (!mounted) return;

    if (id != null) {
      _snack('✅ Cardápio salvo com sucesso!', cor: const Color(0xFF4CAF50));
      Navigator.pop(context);
    } else {
      _snack(_ctrl.errorMessage ?? 'Erro ao salvar.', cor: Colors.red);
    }
  }

  void _abrirSeletor(int refIdx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SeletorAlimentosBottomSheet(
        onAlimentoSelecionado: (alimento, quantidade, unidade) {
          if (refIdx == -1) {
            _ctrl.adicionarItemAvulso(alimento, quantidade: quantidade, unidade: unidade);
          } else {
            _ctrl.adicionarItem(refIdx, alimento, quantidade: quantidade, unidade: unidade);
          }
        },
      ),
    );
  }

  void _mostrarDialogNovaRefeicao() {
    String nomeRef    = '';
    String horarioRef = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Nova Refeição',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome da Refeição',
                hintText: 'Ex: Ceia, Pré-treino...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) => nomeRef = v,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Horário (opcional)',
                hintText: '21:00',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (v) => horarioRef = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeRef.isNotEmpty) {
                _ctrl.adicionarRefeicao(
                  nomeRef,
                  horario: horarioRef.isEmpty ? null : horarioRef,
                );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Adicionar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Widget _titulo(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _campo({
    required String label,
    String? hint,
    TextEditingController? controller,
    IconData? icon,
    int maxLines = 1,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: _primary, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _infoBox(String texto, IconData icon, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {Color? cor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

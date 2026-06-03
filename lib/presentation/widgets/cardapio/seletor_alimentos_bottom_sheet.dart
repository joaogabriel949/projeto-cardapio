import 'package:flutter/material.dart';
import '../../../../database/db_helper.dart';
import '../../../../data/models/alimento_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet para selecionar alimento e definir quantidade
// ─────────────────────────────────────────────────────────────────────────────
class SeletorAlimentosBottomSheet extends StatefulWidget {
  final void Function(AlimentoModel alimento, double quantidade)
      onAlimentoSelecionado;

  const SeletorAlimentosBottomSheet({
    super.key,
    required this.onAlimentoSelecionado,
  });

  @override
  State<SeletorAlimentosBottomSheet> createState() =>
      _SeletorAlimentosBottomSheetState();
}

class _SeletorAlimentosBottomSheetState
    extends State<SeletorAlimentosBottomSheet> {
  static const _primary = Color(0xFF6200EE);

  final _db        = DatabaseHelper();
  final _buscaCtrl = TextEditingController();

  List<Map<String, dynamic>> _alimentos  = [];
  bool    _isLoading       = false;
  String? _filtroTipo;
  String? _filtroNutriScore;

  final _tipos = ['Bebida', 'Proteína', 'Carboidrato', 'Fruta', 'Grão'];
  final _nutriScores = ['A', 'B', 'C', 'D', 'E'];

  static const _nutriColors = {
    'A': Color(0xFF1B7A2B),
    'B': Color(0xFF50A63A),
    'C': Color(0xFFF5C400),
    'D': Color(0xFFE07800),
    'E': Color(0xFFD32F2F),
  };

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() => _isLoading = true);
    try {
      _alimentos = await _db.getAlimentos(
        searchTerm: _buscaCtrl.text,
        tipo:       _filtroTipo,
        nutriScore: _filtroNutriScore,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _abrirDialogQuantidade(Map<String, dynamic> alimentoMap) {
    final alimento  = AlimentoModel.fromMap(alimentoMap);
    final ctrl      = TextEditingController(text: '100');
    double quantidade = 100.0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            double kcal = ((alimento.calorias ?? 0) * quantidade / 100.0);
            double prot = ((alimento.proteinas ?? 0) * quantidade / 100.0);
            double carb = ((alimento.carboidratos ?? 0) * quantidade / 100.0);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _primary.withValues(alpha: 0.1),
                    backgroundImage: (alimento.foto?.startsWith('http') == true)
                        ? NetworkImage(alimento.foto!)
                        : null,
                    child: (alimento.foto?.startsWith('http') != true)
                        ? const Icon(Icons.fastfood,
                            color: _primary, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alimento.nome,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      suffixText: 'g',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: _primary, width: 2),
                      ),
                    ),
                    onChanged: (v) {
                      setLocalState(
                          () => quantidade = double.tryParse(v) ?? 100.0);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Preview nutricional
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: _primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _previewMacro('🔥',
                            kcal.toStringAsFixed(0), 'kcal',
                            const Color(0xFFFF6B35)),
                        _previewMacro('💪',
                            prot.toStringAsFixed(1), 'prot',
                            const Color(0xFF4CAF50)),
                        _previewMacro('🌾',
                            carb.toStringAsFixed(1), 'carb',
                            const Color(0xFF2196F3)),
                      ],
                    ),
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
                    widget.onAlimentoSelecionado(alimento, quantidade);
                    Navigator.pop(ctx);      // fecha dialog
                    Navigator.pop(context);  // fecha bottom sheet
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
            );
          },
        );
      },
    );
  }

  Widget _previewMacro(
      String emoji, String valor, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(valor,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _nutriBadge(String? score) {
    final color =
        _nutriColors[score?.toUpperCase()] ?? Colors.grey.shade400;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        score?.toUpperCase() ?? '?',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.87,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Handle ──────────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Adicionar Alimento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // ── Busca ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _buscaCtrl,
                  decoration: InputDecoration(
                    hintText: 'Buscar alimento...',
                    prefixIcon: const Icon(Icons.search, color: _primary),
                    suffixIcon: _buscaCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _buscaCtrl.clear();
                              _buscar();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _primary, width: 2),
                    ),
                  ),
                  onChanged: (_) => _buscar(),
                ),
              ),
              const SizedBox(height: 10),

              // ── Chips de filtro ──────────────────────────────────────────
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ..._tipos.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(t),
                            selected: _filtroTipo == t,
                            selectedColor: _primary,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _filtroTipo == t
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 13,
                            ),
                            onSelected: (sel) {
                              setState(
                                  () => _filtroTipo = sel ? t : null);
                              _buscar();
                            },
                          ),
                        )),
                    ..._nutriScores.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('Score $s'),
                            selected: _filtroNutriScore == s,
                            selectedColor: _nutriColors[s] ?? Colors.grey,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _filtroNutriScore == s
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 13,
                            ),
                            onSelected: (sel) {
                              setState(
                                  () => _filtroNutriScore = sel ? s : null);
                              _buscar();
                            },
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // ── Lista ────────────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primary))
                    : _alimentos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum alimento encontrado',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollCtrl,
                            itemCount: _alimentos.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 72),
                            itemBuilder: (ctx, i) {
                              final a = _alimentos[i];
                              final foto = a['foto']?.toString() ?? '';
                              final temFoto =
                                  foto.startsWith('http');
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      _primary.withValues(alpha: 0.1),
                                  backgroundImage: temFoto
                                      ? NetworkImage(foto)
                                      : null,
                                  child: !temFoto
                                      ? const Icon(Icons.fastfood,
                                          color: _primary, size: 20)
                                      : null,
                                ),
                                title: Text(
                                  a['nome'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${(a['calorias'] as num?)?.toStringAsFixed(0) ?? '?'} kcal/100g'
                                  ' · ${a['categoria'] ?? ''}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (a['nutri_score'] != null &&
                                        a['nutri_score']
                                            .toString()
                                            .isNotEmpty)
                                      _nutriBadge(
                                          a['nutri_score'].toString()),
                                    const SizedBox(width: 8),
                                    const Icon(
                                        Icons.add_circle_outline,
                                        color: _primary,
                                        size: 22),
                                  ],
                                ),
                                onTap: () =>
                                    _abrirDialogQuantidade(a),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

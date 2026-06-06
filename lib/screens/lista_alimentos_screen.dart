import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/alimento.dart';

class ListaAlimentosScreen extends StatefulWidget {
  const ListaAlimentosScreen({super.key});

  @override
  State<ListaAlimentosScreen> createState() => _ListaAlimentosScreenState();
}

class _ListaAlimentosScreenState extends State<ListaAlimentosScreen> {
  List<Alimento> _todos = [];
  List<Alimento> _filtrados = [];
  bool _isLoading = true;
  String? _erro;
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(_filtrar);
    _carregarAlimentos();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarAlimentos() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final lista = (await DatabaseHelper().getAlimentos())
          .map(Alimento.fromMap)
          .toList();
      if (!mounted) return;
      setState(() {
        _todos = lista;
        _filtrados = lista;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar alimentos.';
        _isLoading = false;
      });
    }
  }

  void _filtrar() {
    final q = _buscaController.text.toLowerCase();
    setState(() {
      _filtrados =
          _todos.where((a) => a.nome.toLowerCase().contains(q)).toList();
    });
  }

  Widget _buildFoto(String? foto) {
    if (foto == null || foto.trim().isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.fastfood, color: Colors.white),
      );
    }
    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(foto),
        onBackgroundImageError: (_, __) {},
      );
    }
    return const CircleAvatar(
      backgroundColor: Colors.orangeAccent,
      child: Icon(Icons.fastfood, color: Colors.white),
    );
  }

  void _mostrarDetalhesNutricionais(BuildContext context, Alimento a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildFoto(a.foto),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.nome,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${a.categoria} • ${a.tipo}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
                          ),
                          if (a.unidadeMedida != null)
                            Text(
                              'Medição: ${a.unidadeMedida}',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                const Text('Informações Nutricionais',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildNutriRow('Calorias', a.calorias, 'kcal'),
                        _buildNutriRow('Proteínas', a.proteinas, 'g'),
                        _buildNutriRow('Carboidratos', a.carboidratos, 'g'),
                        _buildNutriRow(
                            'Gorduras Totais', a.gordurasTotais, 'g'),
                        _buildNutriRow('Sódio', a.sodio, 'mg'),
                        _buildNutriRow('Cálcio', a.calcio, 'mg'),
                        _buildNutriRow('Ferro', a.ferro, 'mg'),
                        if (a.nutriScore != null &&
                            a.nutriScore!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Nutri-Score',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16)),
                                Semantics(
                                  label: 'Nutri-Score: ${a.nutriScore!.toUpperCase()}',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _nutriScoreColor(a.nutriScore),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ExcludeSemantics(
                                      child: Text(
                                        a.nutriScore!.toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutriRow(String label, double? value, String unit) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, color: Colors.black87)),
          Text('$value $unit',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Color _nutriScoreColor(String? score) {
    switch (score?.toUpperCase()) {
      case 'A': return Colors.green.shade800;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.yellow.shade700;
      case 'D': return Colors.orange;
      case 'E': return Colors.red;
      default:  return Colors.grey;
    }
  }

  Future<void> _confirmarExclusao(Alimento alimento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir alimento'),
        content: Text('Deseja excluir "${alimento.nome}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('CANCELAR')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('EXCLUIR',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    await DatabaseHelper().deleteAlimento(alimento.id!);
    await _carregarAlimentos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${alimento.nome}" excluído com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimentos Cadastrados'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar alimento...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: _buildCorpo(textTheme)),
        ],
      ),
    );
  }

  Widget _buildCorpo(TextTheme textTheme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _carregarAlimentos,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_filtrados.isEmpty) {
      return Center(
        child: Text(
          _buscaController.text.isEmpty
              ? 'Nenhum alimento cadastrado ainda.'
              : 'Nenhum resultado para "${_buscaController.text}".',
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filtrados.length,
      itemBuilder: (context, index) {
        final a = _filtrados[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => _mostrarDetalhesNutricionais(context, a),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildFoto(a.foto),
            title: Text(a.nome,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categoria: ${a.categoria}',
                    style: TextStyle(color: Colors.grey.shade700)),
                if (a.unidadeMedida != null)
                  Text(
                    'Medição: ${a.unidadeMedida}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Excluir',
              onPressed: () => _confirmarExclusao(a),
            ),
          ),
        );
      },
    );
  }
}

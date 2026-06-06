import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/alimento.dart';
import 'lista_alimentos_screen.dart';

class ConsultarScreen extends StatefulWidget {
  const ConsultarScreen({super.key});

  @override
  State<ConsultarScreen> createState() => _ConsultarScreenState();
}

class _ConsultarScreenState extends State<ConsultarScreen> {
  List<Alimento> _todos = [];
  List<Alimento> _filtrados = [];
  bool _isLoading = true;
  String? _erro;
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(_filtrar);
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
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
    final termo = _buscaController.text.toLowerCase();
    setState(() {
      _filtrados =
          _todos.where((a) => a.nome.toLowerCase().contains(termo)).toList();
    });
  }

  String _formatarKcal(double? valor) {
    if (valor == null) return '—';
    return '${valor.toStringAsFixed(0)} kcal';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Consultar Alimentos', style: textTheme.displaySmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Gerenciar alimentos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ListaAlimentosScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Encontre informações nutricionais.',
                style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar alimento...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildCorpo(textTheme)),
          ],
        ),
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
            Text(_erro!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _carregar,
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

    return ListView.separated(
      itemCount: _filtrados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final a = _filtrados[index];
        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              a.nome,
              style: textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: a.tipo.isNotEmpty
                ? Text(a.tipo, style: textTheme.bodySmall)
                : null,
            trailing: Chip(
              label: Text(
                _formatarKcal(a.calorias),
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

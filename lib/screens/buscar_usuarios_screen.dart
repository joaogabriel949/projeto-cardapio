import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../data/models/usuario_model.dart';

class BuscarUsuariosScreen extends StatefulWidget {
  const BuscarUsuariosScreen({super.key});

  @override
  State<BuscarUsuariosScreen> createState() => _BuscarUsuariosScreenState();
}

class _BuscarUsuariosScreenState extends State<BuscarUsuariosScreen> {
  List<Usuario> _todos = [];
  List<Usuario> _filtrados = [];
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
      final lista = (await DatabaseHelper().getTodosUsuarios())
          .map(Usuario.fromMap)
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
        _erro = 'Erro ao carregar pacientes.';
        _isLoading = false;
      });
    }
  }

  void _filtrar() {
    final q = _buscaController.text.toLowerCase();
    setState(() {
      _filtrados =
          _todos.where((u) => u.nome.toLowerCase().contains(q)).toList();
    });
  }

  String _formatarData(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pacientes', style: textTheme.displaySmall),
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
                labelText: 'Buscar paciente...',
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
              ? 'Nenhum paciente cadastrado ainda.'
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
        final u = _filtrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).primaryColor.withValues(alpha: 0.15),
              child: Text(
                u.nome.isNotEmpty ? u.nome[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(u.nome,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Nascimento: ${_formatarData(u.dataNascimento)}'),
          ),
        );
      },
    );
  }
}

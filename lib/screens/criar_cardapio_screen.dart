import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/alimento.dart';
import '../models/usuario.dart';
import '../core/user_session.dart';

class CriarCardapioScreen extends StatefulWidget {
  const CriarCardapioScreen({super.key});

  @override
  State<CriarCardapioScreen> createState() => _CriarCardapioScreenState();
}

class _CriarCardapioScreenState extends State<CriarCardapioScreen> {
  List<Alimento> _alimentos = [];
  List<Usuario> _pacientes = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _erro;

  Alimento? _cafeSelecionado;
  Alimento? _almocoSelecionado;
  Alimento? _jantaSelecionada;
  Usuario? _pacienteSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final alimentos = (await DatabaseHelper().getAlimentos())
          .map(Alimento.fromMap)
          .toList();
      final pacientes = (await DatabaseHelper().getTodosUsuarios())
          .map(Usuario.fromMap)
          .toList();
      if (!mounted) return;
      final sessionId = UserSession.instance.usuarioId;
      setState(() {
        _alimentos = alimentos;
        _pacientes = pacientes;
        _isLoading = false;
        if (sessionId != null && _pacienteSelecionado == null) {
          _pacienteSelecionado =
              pacientes.where((p) => p.id == sessionId).firstOrNull;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _salvar() async {
    if (_cafeSelecionado == null &&
        _almocoSelecionado == null &&
        _jantaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos uma refeição.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await DatabaseHelper().insertCardapio({
        'usuario_id': _pacienteSelecionado?.id,
        'cafe_id': _cafeSelecionado?.id,
        'almoco_id': _almocoSelecionado?.id,
        'janta_id': _jantaSelecionada?.id,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cardápio salvo com sucesso!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Cardápio', style: textTheme.displaySmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? _buildErro()
              : _alimentos.isEmpty
                  ? _buildVazio()
                  : _buildFormulario(textTheme),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_erro!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _carregarDados,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildVazio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Nenhum alimento cadastrado.\nCadastre alimentos antes de criar um cardápio.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFormulario(TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_pacientes.isNotEmpty) ...[
            Text('Paciente (opcional)', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildSeletorPaciente(),
            const SizedBox(height: 24),
          ],
          Text('Refeições', style: textTheme.titleMedium),
          const SizedBox(height: 16),
          _buildCardRefeicao(
            icone: Icons.coffee_outlined,
            titulo: 'Café da Manhã',
            selecionado: _cafeSelecionado,
            onSelecionado: (a) => setState(() => _cafeSelecionado = a),
          ),
          const SizedBox(height: 12),
          _buildCardRefeicao(
            icone: Icons.restaurant_outlined,
            titulo: 'Almoço',
            selecionado: _almocoSelecionado,
            onSelecionado: (a) => setState(() => _almocoSelecionado = a),
          ),
          const SizedBox(height: 12),
          _buildCardRefeicao(
            icone: Icons.dinner_dining_outlined,
            titulo: 'Jantar',
            selecionado: _jantaSelecionada,
            onSelecionado: (a) => setState(() => _jantaSelecionada = a),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSaving ? null : _salvar,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('SALVAR CARDÁPIO'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRefeicao({
    required IconData icone,
    required String titulo,
    required Alimento? selecionado,
    required ValueChanged<Alimento?> onSelecionado,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icone, color: Theme.of(context).primaryColor),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: selecionado != null
            ? Text(selecionado.nome,
                style: const TextStyle(color: Colors.black54))
            : const Text('Nenhum alimento selecionado',
                style: TextStyle(color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selecionado != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                onPressed: () => onSelecionado(null),
                tooltip: 'Remover',
              ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _abrirSeletorAlimento(onSelecionado),
              tooltip: 'Selecionar alimento',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeletorPaciente() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(_pacienteSelecionado != null
            ? _pacienteSelecionado!.nome
            : 'Selecionar paciente'),
        trailing: _pacienteSelecionado != null
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                tooltip: 'Remover paciente',
                onPressed: () =>
                    setState(() => _pacienteSelecionado = null),
              )
            : const Icon(Icons.arrow_drop_down),
        onTap: _abrirSeletorPaciente,
      ),
    );
  }

  Future<void> _abrirSeletorAlimento(
      ValueChanged<Alimento?> onSelecionado) async {
    final resultado = await showModalBottomSheet<Alimento>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SeletorAlimentoSheet(alimentos: _alimentos),
    );
    if (resultado != null) onSelecionado(resultado);
  }

  Future<void> _abrirSeletorPaciente() async {
    final resultado = await showModalBottomSheet<Usuario>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SeletorPacienteSheet(pacientes: _pacientes),
    );
    if (resultado != null) setState(() => _pacienteSelecionado = resultado);
  }
}

// ─── Sheet de seleção de alimento com busca ───────────────────────────────

class _SeletorAlimentoSheet extends StatefulWidget {
  final List<Alimento> alimentos;
  const _SeletorAlimentoSheet({required this.alimentos});

  @override
  State<_SeletorAlimentoSheet> createState() => _SeletorAlimentoSheetState();
}

class _SeletorAlimentoSheetState extends State<_SeletorAlimentoSheet> {
  final _buscaController = TextEditingController();
  List<Alimento> _filtrados = [];

  @override
  void initState() {
    super.initState();
    _filtrados = widget.alimentos;
    _buscaController.addListener(_filtrar);
  }

  void _filtrar() {
    final q = _buscaController.text.toLowerCase();
    setState(() {
      _filtrados = widget.alimentos
          .where((a) => a.nome.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (ctx, scrollController) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar alimento',
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtrados.length,
                itemBuilder: (ctx, i) {
                  final a = _filtrados[i];
                  return ListTile(
                    title: Text(a.nome),
                    subtitle: Text(
                        '${a.categoria} • ${a.calorias?.toStringAsFixed(0) ?? '-'} kcal'),
                    onTap: () => Navigator.of(ctx).pop(a),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet de seleção de paciente ─────────────────────────────────────────

class _SeletorPacienteSheet extends StatelessWidget {
  final List<Usuario> pacientes;
  const _SeletorPacienteSheet({required this.pacientes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pacientes.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(pacientes[i].nome),
                onTap: () => Navigator.of(ctx).pop(pacientes[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

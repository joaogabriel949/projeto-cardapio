import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../core/user_session.dart';

class NovoPacienteScreen extends StatefulWidget {
  const NovoPacienteScreen({super.key});

  @override
  State<NovoPacienteScreen> createState() => _NovoPacienteScreenState();
}

class _NovoPacienteScreenState extends State<NovoPacienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _fotoController = TextEditingController();
  DateTime? _dataNascimento;
  bool _isSaving = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year - 20),
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: 'Data de nascimento',
    );
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final nome = _nomeController.text.trim();
      final id = await DatabaseHelper().insertUsuario({
        'nome': nome,
        'foto': _fotoController.text.trim().isEmpty ? null : _fotoController.text.trim(),
        'data_nascimento': _dataNascimento!.toIso8601String(),
      });
      UserSession.instance.set(id, nome);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paciente "$nome" cadastrado!')),
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
        title: Text('Novo Paciente', style: textTheme.displaySmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Dados do paciente', style: textTheme.titleLarge),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o nome';
                  if (v.trim().length < 3) return 'Nome muito curto';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selecionarData,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Data de nascimento *',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      hintText: _dataNascimento == null
                          ? 'Toque para selecionar'
                          : _formatarData(_dataNascimento!),
                    ),
                    controller: TextEditingController(
                      text: _dataNascimento == null ? '' : _formatarData(_dataNascimento!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fotoController,
                decoration: const InputDecoration(
                  labelText: 'URL da foto (opcional)',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
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
                    : const Text('SALVAR PACIENTE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

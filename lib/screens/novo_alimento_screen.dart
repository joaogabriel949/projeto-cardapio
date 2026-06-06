import 'dart:io';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../services/alimento_service.dart';

class NovoAlimentoScreen extends StatefulWidget {
  const NovoAlimentoScreen({super.key});

  @override
  State<NovoAlimentoScreen> createState() => _NovoAlimentoScreenState();
}

class _NovoAlimentoScreenState extends State<NovoAlimentoScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  final TextEditingController _caloriasCtrl = TextEditingController();
  final TextEditingController _proteinasCtrl = TextEditingController();
  final TextEditingController _carboidratosCtrl = TextEditingController();
  final TextEditingController _gordurasTotaisCtrl = TextEditingController();
  final TextEditingController _sodioCtrl = TextEditingController();
  final TextEditingController _calcioCtrl = TextEditingController();
  final TextEditingController _ferroCtrl = TextEditingController();

  final List<String> _categoriasSelecionadas = [];
  String? _tipoSelecionado;
  String? _nutriScore;
  bool _isLoading = false;
  bool _mostrarDetalhes = false;

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  List<Map<String, dynamic>> _unidadesDisponiveis = [
    {'descricao': '100g', 'gramas': 100.0},
    {'descricao': '1 porção', 'gramas': 100.0},
    {'descricao': '1 unidade', 'gramas': 100.0},
    {'descricao': 'g', 'gramas': 1.0},
    {'descricao': 'ml', 'gramas': 1.0},
  ];
  Map<String, dynamic>? _unidadeSelecionada;
  Map<String, double> _valoresPor100g = {};

  final List<String> _categorias = ['Café da manhã', 'Almoço', 'Lanche', 'Janta'];
  final List<String> _tipos = ['Bebida', 'Proteína', 'Carboidrato', 'Fruta', 'Grão'];

  final Color purplePrimary = const Color(0xFF6200EE);
  final Color purpleLight = const Color(0xFFEDE7F6);

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _unidadeSelecionada = _unidadesDisponiveis.first;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _fotoController.dispose();
    _caloriasCtrl.dispose();
    _proteinasCtrl.dispose();
    _carboidratosCtrl.dispose();
    _gordurasTotaisCtrl.dispose();
    _sodioCtrl.dispose();
    _calcioCtrl.dispose();
    _ferroCtrl.dispose();
    _expandController.dispose();
    super.dispose();
  }

  // =========================================================
  // LÓGICA DE BUSCA
  // =========================================================
  Future<void> _buscarDadosDaApi(String nome) async {
    if (nome.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final resultado = await AlimentoService().buscar(nome);
      if (!mounted) return;

      if (resultado == null) {
        _mostrarSnack('Nenhum alimento encontrado. Preencha manualmente.');
        return;
      }

      setState(() {
        _nomeController.text = resultado.nome;
        if (resultado.foto != null) _fotoController.text = resultado.foto!;
        if (resultado.tipoSugerido != null) {
          _tipoSelecionado = resultado.tipoSugerido;
        }
        _nutriScore = resultado.nutriScore;
        _valoresPor100g = resultado.valoresPor100g;

        _preencherCampoNutricional(_caloriasCtrl, _valoresPor100g['calorias']);
        _preencherCampoNutricional(_proteinasCtrl, _valoresPor100g['proteinas']);
        _preencherCampoNutricional(_carboidratosCtrl, _valoresPor100g['carboidratos']);
        _preencherCampoNutricional(_gordurasTotaisCtrl, _valoresPor100g['gorduras_totais']);
        _preencherCampoNutricional(_sodioCtrl, _valoresPor100g['sodio']);
        _preencherCampoNutricional(_calcioCtrl, _valoresPor100g['calcio']);
        _preencherCampoNutricional(_ferroCtrl, _valoresPor100g['ferro']);

        _unidadesDisponiveis = resultado.unidades;
        _unidadeSelecionada =
            _unidadesDisponiveis.isNotEmpty ? _unidadesDisponiveis.first : null;

        if (!_mostrarDetalhes) {
          _mostrarDetalhes = true;
          _expandController.forward();
        }
      });

      final fonte = resultado.fonte == 'taco' ? 'TACO' : 'OpenFoodFacts';
      _mostrarSnack('Dados importados de $fonte com sucesso!');
    } on SocketException {
      if (!mounted) return;
      _mostrarSnack('Sem conexão. Preencha os dados manualmente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarSnack('Erro ao buscar dados. Preencha os campos manualmente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _preencherCampoNutricional(TextEditingController ctrl, double? valor) {
    if (valor != null) ctrl.text = valor.toStringAsFixed(2);
  }

  void _mostrarSnack(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // =========================================================
  // SALVAR
  // =========================================================
  Future<void> _salvarAlimento() async {
    if (_nomeController.text.isEmpty ||
        _categoriasSelecionadas.isEmpty ||
        _tipoSelecionado == null) {
      _mostrarSnack('Por favor, preencha nome, categoria e tipo.');
      return;
    }

    double? parseDouble(TextEditingController c) =>
        double.tryParse(c.text.replaceAll(',', '.'));

    final novoAlimento = {
      'nome': _nomeController.text,
      'foto': _fotoController.text,
      'categoria': _categoriasSelecionadas.join(', '),
      'tipo': _tipoSelecionado,
      'calorias': parseDouble(_caloriasCtrl),
      'proteinas': parseDouble(_proteinasCtrl),
      'carboidratos': parseDouble(_carboidratosCtrl),
      'gorduras_totais': parseDouble(_gordurasTotaisCtrl),
      'sodio': parseDouble(_sodioCtrl),
      'calcio': parseDouble(_calcioCtrl),
      'ferro': parseDouble(_ferroCtrl),
      'nutri_score': _nutriScore,
      'unidade_medida': _unidadeSelecionada?['descricao'] ?? '100g',
    };

    await DatabaseHelper().insertAlimento(novoAlimento);

    if (mounted) {
      _mostrarSnack('Alimento salvo com sucesso!');
      Navigator.pop(context);
    }
  }

  // =========================================================
  // HELPERS DE INTERFACE
  // =========================================================
  Color _corNutriScore(String? grade) {
    switch (grade?.toUpperCase()) {
      case 'A': return const Color(0xFF1B7A2B);
      case 'B': return const Color(0xFF50A63A);
      case 'C': return const Color(0xFFF5C400);
      case 'D': return const Color(0xFFE07800);
      case 'E': return const Color(0xFFD32F2F);
      default:  return Colors.grey;
    }
  }

  Widget _campoNutricional({
    required String label,
    required TextEditingController controller,
    String unidade = 'g',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: unidade,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _secaoNutricional(String titulo, List<Widget> campos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: purplePrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...campos,
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Novo Cadastro', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Adicionar Alimento',
                style: textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Preencha os dados do novo alimento.',
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey)),
            const SizedBox(height: 32),

            // Campo Nome com busca
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Alimento',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search),
                  onPressed: () => _buscarDadosDaApi(_nomeController.text),
                ),
              ),
              onSubmitted: _buscarDadosDaApi,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _fotoController,
              decoration: const InputDecoration(
                labelText: 'Caminho da Foto (URL ou local)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Multi-Select Categoria
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Categoria (refeição)',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _categorias.map((cat) {
                  final isSelected = _categoriasSelecionadas.contains(cat);
                  return FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : purplePrimary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _categoriasSelecionadas.add(cat);
                        } else {
                          _categoriasSelecionadas.remove(cat);
                        }
                      });
                    },
                    selectedColor: purplePrimary,
                    checkmarkColor: Colors.white,
                    backgroundColor: purpleLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? purplePrimary
                            : purplePrimary.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown Tipo
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tipo',
                labelStyle: TextStyle(color: purplePrimary),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: purplePrimary, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: purplePrimary, width: 2)),
                border: const OutlineInputBorder(),
              ),
              initialValue: _tipoSelecionado,
              items: _tipos
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _tipoSelecionado = val),
            ),
            const SizedBox(height: 16),

            // Dropdown Unidade de Medida
            if (_unidadesDisponiveis.isNotEmpty) ...[
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'Unidade de Medida (Referência)',
                  labelStyle: TextStyle(color: purplePrimary),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: purplePrimary, width: 2)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: purplePrimary, width: 2)),
                  border: const OutlineInputBorder(),
                ),
                initialValue: _unidadeSelecionada,
                items: _unidadesDisponiveis.map((u) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: u,
                    child: Text(u['descricao'] as String),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    _unidadeSelecionada = val;
                    if (_valoresPor100g.isNotEmpty) {
                      final multiplier =
                          (val['gramas'] as num).toDouble() / 100.0;
                      _preencherCampoNutricional(
                          _caloriasCtrl, _valoresPor100g['calorias']! * multiplier);
                      _preencherCampoNutricional(
                          _proteinasCtrl, _valoresPor100g['proteinas']! * multiplier);
                      _preencherCampoNutricional(
                          _carboidratosCtrl, _valoresPor100g['carboidratos']! * multiplier);
                      _preencherCampoNutricional(
                          _gordurasTotaisCtrl, _valoresPor100g['gorduras_totais']! * multiplier);
                      _preencherCampoNutricional(
                          _sodioCtrl, _valoresPor100g['sodio']! * multiplier);
                      _preencherCampoNutricional(
                          _calcioCtrl, _valoresPor100g['calcio']! * multiplier);
                      _preencherCampoNutricional(
                          _ferroCtrl, _valoresPor100g['ferro']! * multiplier);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            _buildDetalhesTile(),
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: _buildPainelNutricional(),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _salvarAlimento,
              style: ElevatedButton.styleFrom(
                backgroundColor: purplePrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'SALVAR ALIMENTO',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalhesTile() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _mostrarDetalhes = !_mostrarDetalhes;
          if (_mostrarDetalhes) {
            _expandController.forward();
          } else {
            _expandController.reverse();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: purpleLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: purplePrimary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.monitor_heart_outlined, color: purplePrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Detalhes Nutricionais',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: purplePrimary,
                ),
              ),
            ),
            Text(
              'por 100g',
              style: TextStyle(
                  fontSize: 11, color: purplePrimary.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _mostrarDetalhes ? 0.5 : 0,
              duration: const Duration(milliseconds: 350),
              child: Icon(Icons.keyboard_arrow_down, color: purplePrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainelNutricional() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(color: purplePrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_nutriScore != null && _nutriScore!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Nutri-Score:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _corNutriScore(_nutriScore),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _nutriScore!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Nutri-Score:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('?',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18)),
                ),
                const SizedBox(width: 8),
                Text('Não disponível',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ],
          _secaoNutricional('⚡ Energia', [
            _campoNutricional(
                label: 'Valor Calórico',
                controller: _caloriasCtrl,
                unidade: 'kcal'),
          ]),
          _secaoNutricional('🥩 Macronutrientes', [
            _campoNutricional(label: 'Proteínas', controller: _proteinasCtrl),
            _campoNutricional(
                label: 'Carboidratos', controller: _carboidratosCtrl),
            _campoNutricional(
                label: 'Gorduras Totais', controller: _gordurasTotaisCtrl),
          ]),
          _secaoNutricional('🧪 Micronutrientes', [
            _campoNutricional(
                label: 'Sódio', controller: _sodioCtrl, unidade: 'mg'),
            _campoNutricional(
                label: 'Cálcio', controller: _calcioCtrl, unidade: 'mg'),
            _campoNutricional(
                label: 'Ferro', controller: _ferroCtrl, unidade: 'mg'),
          ]),
        ],
      ),
    );
  }
}

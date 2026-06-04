import 'package:flutter/material.dart';
import 'package:goomer_nutri/data/models/alimento_model.dart';
import 'package:goomer_nutri/data/models/repositories/alimento_repository.dart';
import 'package:goomer_nutri/data/models/services/alimento_service.dart';
import 'package:goomer_nutri/presentation/widgets/cardapio/alimento/campo_nutricional.dart';
import 'package:goomer_nutri/presentation/widgets/cardapio/alimento/secao_nutricional.dart';
import 'package:goomer_nutri/presentation/widgets/cardapio/alimento/nutri_score_badge.dart';

class NovoAlimentoScreen extends StatefulWidget {
  const NovoAlimentoScreen({super.key});

  @override
  State<NovoAlimentoScreen> createState() => _NovoAlimentoScreenState();
}

class _NovoAlimentoScreenState extends State<NovoAlimentoScreen>
    with SingleTickerProviderStateMixin {
  // --- Controladores de texto básicos ---
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();

  // --- Controladores nutricionais ---
  final TextEditingController _caloriasCtrl = TextEditingController();
  final TextEditingController _proteinasCtrl = TextEditingController();
  final TextEditingController _carboidratosCtrl = TextEditingController();
  final TextEditingController _gordurasTotaisCtrl = TextEditingController();
  final TextEditingController _sodioCtrl = TextEditingController();
  final TextEditingController _calcioCtrl = TextEditingController();
  final TextEditingController _ferroCtrl = TextEditingController();

  // --- Estado da tela ---
  final List<String> _categoriasSelecionadas = [];
  String? _tipoSelecionado;
  String? _nutriScore;
  bool _isLoading = false;
  bool _mostrarDetalhes = false;

  // --- Animação do painel expansível ---
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // --- Controle de Unidade de Medida ---
  List<Map<String, dynamic>> _unidadesDisponiveis = [
    {'descricao': '100g', 'gramas': 100.0},
    {'descricao': '1 porção', 'gramas': 100.0},
    {'descricao': '1 unidade', 'gramas': 100.0},
    {'descricao': 'g', 'gramas': 1.0},
    {'descricao': 'ml', 'gramas': 1.0},
  ];
  Map<String, dynamic>? _unidadeSelecionada;
  Map<String, double> _valoresPor100g = {};

  // --- Listas de opções ---
  final List<String> _categorias = [
    'Café da manhã',
    'Almoço',
    'Lanche',
    'Janta'
  ];
  final List<String> _tipos = [
    'Bebida',
    'Proteína',
    'Carboidrato',
    'Fruta',
    'Grão'
  ];

  // --- Paleta de cores ---
  final Color purplePrimary = const Color(0xFF6200EE);
  final Color purpleLight = const Color(0xFFEDE7F6);

  // --- Serviços e Repositórios ---
  final AlimentoService _alimentoService = AlimentoService();
  final AlimentoRepository _alimentoRepository = AlimentoRepository();

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

    // Inicializa valores baseline com zeros para segurança
    _valoresPor100g = {
      'calorias': 0.0,
      'proteinas': 0.0,
      'carboidratos': 0.0,
      'gorduras_totais': 0.0,
      'sodio': 0.0,
      'calcio': 0.0,
      'ferro': 0.0,
    };
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
  // LÓGICA DE NEGÓCIO E INTERAÇÃO COM SERVIÇOS
  // =========================================================

  void _limparCamposNutricionais() {
    _caloriasCtrl.clear();
    _proteinasCtrl.clear();
    _carboidratosCtrl.clear();
    _gordurasTotaisCtrl.clear();
    _sodioCtrl.clear();
    _calcioCtrl.clear();
    _ferroCtrl.clear();
    _valoresPor100g = {
      'calorias': 0.0,
      'proteinas': 0.0,
      'carboidratos': 0.0,
      'gorduras_totais': 0.0,
      'sodio': 0.0,
      'calcio': 0.0,
      'ferro': 0.0,
    };
  }

  Future<void> _buscarDadosDaApi(String nome) async {
    if (nome.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _tipoSelecionado = null;
      _nutriScore = null;
      _limparCamposNutricionais();
    });

    try {
      final resultado = await _alimentoService.buscarAlimento(nome);
      final alimento = resultado['alimento'] as AlimentoModel?;

      if (alimento != null) {
        setState(() {
          _nomeController.text = alimento.nome;
          _fotoController.text = alimento.foto ?? '';

          if (alimento.tipo.isNotEmpty && _tipos.contains(alimento.tipo)) {
            _tipoSelecionado = alimento.tipo;
          }

          _nutriScore = alimento.nutriScore;
          _valoresPor100g = alimento.valoresPor100g;

          final unidadesTaco = resultado['unidades'];
          if (unidadesTaco != null && unidadesTaco is List) {
            _unidadesDisponiveis = [];
            final Set<String> descricoesVistas = {'100g'};
            _unidadesDisponiveis.add({'descricao': '100g', 'gramas': 100.0});

            for (var u in unidadesTaco) {
              if (u['descricao'] != null) {
                String desc = u['descricao'].toString().trim();
                if (!descricoesVistas.contains(desc) && desc.isNotEmpty) {
                  descricoesVistas.add(desc);
                  _unidadesDisponiveis.add({
                    'descricao': desc,
                    'gramas': (u['gramas'] as num).toDouble()
                  });
                }
              }
            }
          } else {
            _unidadesDisponiveis =
                List<Map<String, dynamic>>.from(alimento.unidadesDisponiveis);
          }

          _unidadeSelecionada = _unidadesDisponiveis.first;

          _atualizarCamposNutricionais();

          if (!_mostrarDetalhes) {
            _mostrarDetalhes = true;
            _expandController.forward();
          }
        });
        _mostrarSnack('✅ Dados importados com sucesso!');
      } else {
        setState(() {
          _unidadesDisponiveis = [
            {'descricao': '100g', 'gramas': 100.0},
            {'descricao': 'g', 'gramas': 1.0},
            {'descricao': 'ml', 'gramas': 1.0},
          ];
          _unidadeSelecionada = _unidadesDisponiveis.first;
        });
        _mostrarSnack('⚠️ Nenhum alimento encontrado. Preencha manualmente.');
      }
    } catch (e) {
      _mostrarSnack('❌ Erro ao buscar alimento. Tente novamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _preencherCampoNutricional(TextEditingController ctrl, double? valor) {
    if (valor != null) {
      ctrl.text = valor.toStringAsFixed(2);
    }
  }

  void _atualizarCamposNutricionais() {
    final val = _unidadeSelecionada;
    if (val != null && _valoresPor100g.isNotEmpty) {
      double multiplier = (val['gramas'] as num).toDouble() / 100.0;
      _preencherCampoNutricional(
          _caloriasCtrl, (_valoresPor100g['calorias'] ?? 0.0) * multiplier);
      _preencherCampoNutricional(
          _proteinasCtrl, (_valoresPor100g['proteinas'] ?? 0.0) * multiplier);
      _preencherCampoNutricional(_carboidratosCtrl,
          (_valoresPor100g['carboidratos'] ?? 0.0) * multiplier);
      _preencherCampoNutricional(_gordurasTotaisCtrl,
          (_valoresPor100g['gorduras_totais'] ?? 0.0) * multiplier);
      _preencherCampoNutricional(
          _sodioCtrl, (_valoresPor100g['sodio'] ?? 0.0) * multiplier);
      _preencherCampoNutricional(
          _calcioCtrl, (_valoresPor100g['calcio'] ?? 0.0) * multiplier);
      _preencherCampoNutricional(
          _ferroCtrl, (_valoresPor100g['ferro'] ?? 0.0) * multiplier);
    }
  }

  void _onNutrientChanged(String key, String value) {
    final textVal = value.replaceAll(',', '.');
    final doubleVal = double.tryParse(textVal);
    if (doubleVal != null) {
      final val = _unidadeSelecionada;
      double multiplier = 1.0;
      if (val != null) {
        multiplier = (val['gramas'] as num).toDouble() / 100.0;
      }
      if (multiplier > 0) {
        _valoresPor100g[key] = doubleVal / multiplier;
      } else {
        _valoresPor100g[key] = doubleVal;
      }
    } else {
      _valoresPor100g[key] = 0.0;
    }
  }

  void _mostrarSnack(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _salvarAlimento() async {
    if (_nomeController.text.isEmpty ||
        _categoriasSelecionadas.isEmpty ||
        _tipoSelecionado == null) {
      _mostrarSnack('Por favor, preencha nome, categoria e tipo.');
      return;
    }

    final alimento = AlimentoModel(
      nome: _nomeController.text,
      foto: _fotoController.text.isNotEmpty ? _fotoController.text : null,
      categoria: _categoriasSelecionadas.join(', '),
      tipo: _tipoSelecionado!,
      calorias: _valoresPor100g['calorias'],
      proteinas: _valoresPor100g['proteinas'],
      carboidratos: _valoresPor100g['carboidratos'],
      gordurasTotais: _valoresPor100g['gorduras_totais'],
      sodio: _valoresPor100g['sodio'],
      calcio: _valoresPor100g['calcio'],
      ferro: _valoresPor100g['ferro'],
      nutriScore: _nutriScore,
      unidadeMedida: _unidadeSelecionada?['descricao'] ?? '100g',
    );

    try {
      await _alimentoRepository.salvarAlimento(alimento);
      if (mounted) {
        _mostrarSnack('✅ Alimento salvo com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      _mostrarSnack('❌ Erro ao salvar alimento.');
    }
  }

  // =========================================================
  // BUILD AND UI METHODS
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Novo Cadastro', style: TextStyle(color: Colors.black)),
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

            // --- Campo Nome com botão de busca ---
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

            // --- Campo Foto ---
            TextField(
              controller: _fotoController,
              decoration: const InputDecoration(
                labelText: 'Caminho da Foto (URL ou local)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // --- Multi-Select Categoria (refeição) ---
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
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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

            // --- Dropdown Tipo ---
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

            // --- Dropdown Unidade de Medida ---
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
                    child: Text(u['descricao']),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _unidadeSelecionada = val;
                      _atualizarCamposNutricionais();
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
            ],

            // =========================================================
            // SEÇÃO DETALHES NUTRICIONAIS
            // =========================================================
            _buildDetalhesTile(),
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: _buildPainelNutricional(),
            ),

            const SizedBox(height: 32),

            // --- Botão Salvar ---
            ElevatedButton(
              onPressed: _isLoading ? null : _salvarAlimento,
              style: ElevatedButton.styleFrom(
                backgroundColor: purplePrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('SALVAR ALIMENTO',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho clicável da seção de detalhes
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
                fontSize: 11,
                color: purplePrimary.withValues(alpha: 0.6),
              ),
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

  /// Conteúdo expandido com todos os campos nutricionais
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
          // --- Nutri-Score Badge ---
          const SizedBox(height: 12),
          NutriScoreBadge(nutriScore: _nutriScore),
          const SizedBox(height: 12),

          // --- Calorias ---
          SecaoNutricional(
            titulo: '⚡ Energia',
            corPrimaria: purplePrimary,
            campos: [
              CampoNutricional(
                label: 'Valor Calórico',
                controller: _caloriasCtrl,
                unidade: 'kcal',
                onChanged: (v) => _onNutrientChanged('calorias', v),
              ),
            ],
          ),

          // --- Macronutrientes ---
          SecaoNutricional(
            titulo: '🥩 Macronutrientes',
            corPrimaria: purplePrimary,
            campos: [
              CampoNutricional(
                label: 'Proteínas',
                controller: _proteinasCtrl,
                onChanged: (v) => _onNutrientChanged('proteinas', v),
              ),
              CampoNutricional(
                label: 'Carboidratos',
                controller: _carboidratosCtrl,
                onChanged: (v) => _onNutrientChanged('carboidratos', v),
              ),
              CampoNutricional(
                label: 'Gorduras Totais',
                controller: _gordurasTotaisCtrl,
                onChanged: (v) => _onNutrientChanged('gorduras_totais', v),
              ),
            ],
          ),

          // --- Micronutrientes ---
          SecaoNutricional(
            titulo: '🧪 Micronutrientes',
            corPrimaria: purplePrimary,
            campos: [
              CampoNutricional(
                label: 'Sódio',
                controller: _sodioCtrl,
                unidade: 'mg',
                onChanged: (v) => _onNutrientChanged('sodio', v),
              ),
              CampoNutricional(
                label: 'Cálcio',
                controller: _calcioCtrl,
                unidade: 'mg',
                onChanged: (v) => _onNutrientChanged('calcio', v),
              ),
              CampoNutricional(
                label: 'Ferro',
                controller: _ferroCtrl,
                unidade: 'mg',
                onChanged: (v) => _onNutrientChanged('ferro', v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../database/db_helper.dart';

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
  final TextEditingController _acucaresCtrl = TextEditingController();
  final TextEditingController _gordurasTotaisCtrl = TextEditingController();
  final TextEditingController _gordurasSaturadasCtrl = TextEditingController();
  final TextEditingController _gordutasTransCtrl = TextEditingController();
  final TextEditingController _sodioCtrl = TextEditingController();
  final TextEditingController _fibrasCtrl = TextEditingController();
  final TextEditingController _vitACtrl = TextEditingController();
  final TextEditingController _vitCCtrl = TextEditingController();
  final TextEditingController _calcioCtrl = TextEditingController();
  final TextEditingController _ferroCtrl = TextEditingController();

  // --- Estado da tela ---
  String? _categoriaSelecionada;
  String? _tipoSelecionado;
  String? _nutriScore;
  bool _isLoading = false;
  bool _mostrarDetalhes = false;

  // --- Animação do painel expansível ---
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // --- Listas de opções ---
  final List<String> _categorias = ['Café', 'Almoço', 'Janta'];
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

  @override
  void initState() {
    super.initState();

    // Configuração obrigatória da API Open Food Facts
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'GoomerNutri',
      version: '1.0.0',
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _fotoController.dispose();
    _caloriasCtrl.dispose();
    _proteinasCtrl.dispose();
    _carboidratosCtrl.dispose();
    _acucaresCtrl.dispose();
    _gordurasTotaisCtrl.dispose();
    _gordurasSaturadasCtrl.dispose();
    _gordutasTransCtrl.dispose();
    _sodioCtrl.dispose();
    _fibrasCtrl.dispose();
    _vitACtrl.dispose();
    _vitCCtrl.dispose();
    _calcioCtrl.dispose();
    _ferroCtrl.dispose();
    _expandController.dispose();
    super.dispose();
  }

  // =========================================================
  // LÓGICA DA API OPEN FOOD FACTS (corrigida para v3)
  // =========================================================
  Future<void> _buscarDadosDaApi(String nome) async {
    if (nome.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final configuration = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [nome]),
          const PageNumber(page: 1),
          const PageSize(size: 5),
        ],
        language: OpenFoodFactsLanguage.PORTUGUESE,
        fields: [
          ProductField.NAME,
          ProductField.IMAGE_FRONT_URL,
          ProductField.CATEGORIES_TAGS,
          ProductField.NUTRIMENTS,
          ProductField.NUTRISCORE,
        ],
        version: ProductQueryVersion.v3,
      );

      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        null,
        configuration,
      );

      if (result.products != null && result.products!.isNotEmpty) {
        final produto = result.products!.first;

        setState(() {
          // Campos básicos
          _nomeController.text = produto.productName ?? _nomeController.text;
          _fotoController.text = produto.imageFrontUrl ?? '';

          // Mapeamento automático de tipo pelas tags de categoria
          final tags = produto.categoriesTags ?? [];
          _autoMapearTipo(tags);

          // Nutri-Score
          _nutriScore = produto.nutriscore?.toUpperCase();

          // Campos nutricionais (por 100g)
          final n = produto.nutriments;
          if (n != null) {
            _preencherCampoNutricional(_caloriasCtrl,
                n.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_proteinasCtrl,
                n.getValue(Nutrient.proteins, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_carboidratosCtrl,
                n.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_acucaresCtrl,
                n.getValue(Nutrient.sugars, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_gordurasTotaisCtrl,
                n.getValue(Nutrient.fat, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_gordurasSaturadasCtrl,
                n.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_gordutasTransCtrl,
                n.getValue(Nutrient.transFat, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_sodioCtrl,
                n.getValue(Nutrient.sodium, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_fibrasCtrl,
                n.getValue(Nutrient.fiber, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_vitACtrl,
                n.getValue(Nutrient.vitaminA, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_vitCCtrl,
                n.getValue(Nutrient.vitaminC, PerSize.oneHundredGrams));
            _preencherCampoNutricional(_calcioCtrl,
                n.getValue(Nutrient.calcium, PerSize.oneHundredGrams));
            _preencherCampoNutricional(
                _ferroCtrl, n.getValue(Nutrient.iron, PerSize.oneHundredGrams));
          }

          // Abre o painel automaticamente ao receber dados
          if (!_mostrarDetalhes) {
            _mostrarDetalhes = true;
            _expandController.forward();
          }
        });

        _mostrarSnack('✅ Dados importados com sucesso!');
      } else {
        _mostrarSnack('⚠️ Nenhum alimento encontrado. Preencha manualmente.');
      }
    } catch (e) {
      _mostrarSnack('❌ Erro ao conectar na API. Verifique a internet.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _preencherCampoNutricional(TextEditingController ctrl, double? valor) {
    if (valor != null) {
      ctrl.text = valor.toStringAsFixed(2);
    }
  }

  void _autoMapearTipo(List<String> tags) {
    const mapeamento = {
      'Bebida': ['en:beverages', 'drink', 'suco', 'juice', 'water', 'milk'],
      'Proteína': [
        'en:meats',
        'en:fish',
        'en:eggs',
        'carne',
        'frango',
        'peixe',
        'ovo',
        'queijo'
      ],
      'Carboidrato': [
        'en:breads',
        'en:pastas',
        'pão',
        'arroz',
        'massa',
        'farinha',
        'bread'
      ],
      'Fruta': ['en:fruits', 'fruta', 'fruit'],
      'Grão': [
        'en:legumes',
        'en:cereals',
        'feijão',
        'lentilha',
        'aveia',
        'grain'
      ],
    };

    for (String tag in tags) {
      final tagLow = tag.toLowerCase();
      for (var entry in mapeamento.entries) {
        for (String palavra in entry.value) {
          if (tagLow.contains(palavra)) {
            _tipoSelecionado = entry.key;
            return;
          }
        }
      }
    }
  }

  void _mostrarSnack(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // =========================================================
  // SALVAR NO BANCO (com dados nutricionais)
  // =========================================================
  Future<void> _salvarAlimento() async {
    if (_nomeController.text.isEmpty ||
        _categoriaSelecionada == null ||
        _tipoSelecionado == null) {
      _mostrarSnack('Por favor, preencha nome, categoria e tipo.');
      return;
    }

    double? parseDouble(TextEditingController c) =>
        double.tryParse(c.text.replaceAll(',', '.'));

    final novoAlimento = {
      'nome': _nomeController.text,
      'foto': _fotoController.text,
      'categoria': _categoriaSelecionada,
      'tipo': _tipoSelecionado,
      'calorias': parseDouble(_caloriasCtrl),
      'proteinas': parseDouble(_proteinasCtrl),
      'carboidratos': parseDouble(_carboidratosCtrl),
      'acucares': parseDouble(_acucaresCtrl),
      'gorduras_totais': parseDouble(_gordurasTotaisCtrl),
      'gorduras_saturadas': parseDouble(_gordurasSaturadasCtrl),
      'gorduras_trans': parseDouble(_gordutasTransCtrl),
      'sodio': parseDouble(_sodioCtrl),
      'fibras': parseDouble(_fibrasCtrl),
      'vitamina_a': parseDouble(_vitACtrl),
      'vitamina_c': parseDouble(_vitCCtrl),
      'calcio': parseDouble(_calcioCtrl),
      'ferro': parseDouble(_ferroCtrl),
      'nutri_score': _nutriScore,
    };

    await DatabaseHelper().insertAlimento(novoAlimento);

    if (mounted) {
      _mostrarSnack('✅ Alimento salvo com sucesso!');
      Navigator.pop(context);
    }
  }

  // =========================================================
  // HELPERS DE INTERFACE
  // =========================================================

  /// Retorna a cor do Nutri-Score (A=verde escuro ... E=vermelho)
  Color _corNutriScore(String? grade) {
    switch (grade?.toUpperCase()) {
      case 'A':
        return const Color(0xFF1B7A2B);
      case 'B':
        return const Color(0xFF50A63A);
      case 'C':
        return const Color(0xFFF5C400);
      case 'D':
        return const Color(0xFFE07800);
      case 'E':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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

            // --- Dropdown Categoria ---
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              initialValue: _categoriaSelecionada,
              items: _categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _categoriaSelecionada = val),
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
            const SizedBox(height: 24),

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
          // --- Nutri-Score ---
          if (_nutriScore != null && _nutriScore!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Nutri-Score:',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                      fontSize: 18,
                    ),
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
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Não disponível',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ],

          // --- Calorias ---
          _secaoNutricional('⚡ Energia', [
            _campoNutricional(
                label: 'Valor Calórico',
                controller: _caloriasCtrl,
                unidade: 'kcal'),
          ]),

          // --- Macronutrientes ---
          _secaoNutricional('🥩 Macronutrientes', [
            _campoNutricional(label: 'Proteínas', controller: _proteinasCtrl),
            _campoNutricional(
                label: 'Carboidratos', controller: _carboidratosCtrl),
            _campoNutricional(label: '↳ Açúcares', controller: _acucaresCtrl),
            _campoNutricional(
                label: 'Gorduras Totais', controller: _gordurasTotaisCtrl),
            _campoNutricional(
                label: '↳ Gorduras Saturadas',
                controller: _gordurasSaturadasCtrl),
            _campoNutricional(
                label: '↳ Gorduras Trans', controller: _gordutasTransCtrl),
          ]),

          // --- Micronutrientes ---
          _secaoNutricional('🧪 Micronutrientes', [
            _campoNutricional(
                label: 'Sódio', controller: _sodioCtrl, unidade: 'mg'),
            _campoNutricional(
                label: 'Fibras Alimentares', controller: _fibrasCtrl),
            _campoNutricional(
                label: 'Vitamina A', controller: _vitACtrl, unidade: 'mcg'),
            _campoNutricional(
                label: 'Vitamina C', controller: _vitCCtrl, unidade: 'mg'),
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

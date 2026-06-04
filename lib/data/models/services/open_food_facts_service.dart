import 'package:openfoodfacts/openfoodfacts.dart';
import '../alimento_model.dart';

class OpenFoodFactsService {
  OpenFoodFactsService() {
    // Configura o User-Agent necessário pela API se ainda não configurado
    OpenFoodAPIConfiguration.userAgent ??= UserAgent(
      name: 'GoomerNutri',
      version: '1.0.0',
    );
  }

  Future<AlimentoModel?> buscarAlimentoRemoto(String nome) async {
    return buscarAlimentoPorNome(nome);
  }

  Future<AlimentoModel?> buscarAlimentoPorNome(String nome) async {
    if (nome.trim().isEmpty) return null;
    try {
      final configuration = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [nome]),
          const PageNumber(page: 1),
          const PageSize(size: 5),
        ],
        language: OpenFoodAPIConfiguration.globalLanguages != null && OpenFoodAPIConfiguration.globalLanguages!.isNotEmpty
            ? OpenFoodAPIConfiguration.globalLanguages!.first
            : OpenFoodFactsLanguage.PORTUGUESE,
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
        return AlimentoModel.fromOpenFoodFacts(produto);
      }
    } catch (e) {
      // Registrar log em ambiente de debug se necessário
    }
    return null;
  }
}

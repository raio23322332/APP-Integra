// lib/core/contracts/search_service_contract.dart



import 'package:integra_app/data/models/category_model.dart' as models;

/// Contrato abstrato para serviços de busca
/// Define a interface que todos os serviços de busca devem implementar
abstract class SearchServiceContract {
  /// Busca serviços por termo de pesquisa
  Future<List<models.Service>> searchServices(String searchTerm, String token);
}

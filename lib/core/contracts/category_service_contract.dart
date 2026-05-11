// lib/core/contracts/category_service_contract.dart


import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/tenant_model.dart';

/// Contrato abstrato para serviços de categoria
/// Define a interface que todos os serviços de categoria devem implementar
abstract class CategoryServiceContract {
  /// Busca categorias e serviços agrupados por categoria para um tenant específico
  Future<List<models.Category>> getCategories(
    Tenant tenant,
    String token,
  );
}

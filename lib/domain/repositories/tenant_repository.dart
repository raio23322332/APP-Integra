// lib/domain/repositories/tenant_repository.dart

import 'package:integra_app/domain/entities/tenant_entity.dart';

/// Contrato abstrato para repositório de tenant
/// Define a interface que todos os repositórios de tenant devem implementar
abstract class TenantRepository {
  /// Lista todos os tenants disponíveis
  Future<List<TenantEntity>> getTenants();

  /// Salva o tenant selecionado
  Future<void> saveSelectedTenant(TenantEntity tenant);

  /// Recupera o tenant selecionado
  Future<TenantEntity?> getSelectedTenant();

  /// Limpa a seleção de tenant
  Future<void> clearSelectedTenant();
}

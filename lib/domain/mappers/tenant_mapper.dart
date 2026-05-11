// lib/domain/mappers/tenant_mapper.dart

import 'package:integra_app/data/models/domain_model.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/domain/entities/tenant_entity.dart';

/// Classe responsável por mapeamentos entre Entity e Model do domínio Tenant
class TenantMapper {
  /// Converte TenantEntity para Tenant (Model usado pela View)
  static Tenant toModel(TenantEntity entity) {
    return Tenant(
      id: entity.id,
      domains: entity.domains
          .map((domainEntity) => DomainModel(
                id: domainEntity.domain, // Usando domain como id
                domain: domainEntity.domain,
              ))
          .toList(),
    );
  }

  /// Converte Tenant para TenantEntity (Entity usado pelo Domain)
  static TenantEntity toEntity(Tenant model) {
    return TenantEntity(
      id: model.id,
      name: model.tenancyDbName ?? model.urlSubdomainBase ?? model.id,
      descricao: model.descricao,
      domains: model.domains
          .map((domainModel) => Domain(
                domain: domainModel.domain ?? '',
              ))
          .toList(),
    );
  }

  /// Converte lista de TenantEntity para lista de Tenant
  static List<Tenant> toModelList(List<TenantEntity> entities) {
    return entities.map(toModel).toList();
  }

  /// Converte lista de Tenant para lista de TenantEntity
  static List<TenantEntity> toEntityList(List<Tenant> models) {
    return models.map(toEntity).toList();
  }
}

// lib/domain/entities/tenant_entity.dart
class TenantEntity {
  final String id;
  final String name;
  final List<Domain> domains;
  final String? descricao;

  const TenantEntity({
    required this.id,
    required this.name,
    required this.domains,
    this.descricao,
  });
}

class Domain {
  final String domain;
  final String? alias;

  const Domain({
    required this.domain,
    this.alias,
  });
}
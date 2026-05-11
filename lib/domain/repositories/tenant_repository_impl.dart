// lib/domain/repositories/tenant_repository_impl.dart

import 'package:flutter/foundation.dart';
import 'package:integra_app/data/dao/tenant_config_dao.dart';
import 'package:integra_app/data/dao/category_dao.dart';
import 'package:integra_app/domain/entities/tenant_entity.dart';
import 'package:integra_app/domain/mappers/tenant_mapper.dart';
import 'package:integra_app/domain/repositories/tenant_repository.dart';
import 'package:integra_app/services/domain/domain_service.dart';

class TenantRepositoryImpl implements TenantRepository {
  final DomainService _domainService;
  final TenantConfigDao _tenantConfigDao;
  final CategoryDao _categoryDao;

  TenantRepositoryImpl({
    required DomainService domainService,
    required TenantConfigDao tenantConfigDao,
    required CategoryDao categoryDao,
  })  : _domainService = domainService,
        _tenantConfigDao = tenantConfigDao,
        _categoryDao = categoryDao;

  @override
  Future<List<TenantEntity>> getTenants() async {
    final tenants = await _domainService.listTenants();
    return TenantMapper.toEntityList(tenants);
  }

  @override
  Future<void> saveSelectedTenant(TenantEntity tenant) async {
    // Limpar categorias do tenant anterior antes de salvar o novo
    final currentTenant = await getSelectedTenant();
    if (currentTenant != null && currentTenant.domains.isNotEmpty) {
      final currentDomain = currentTenant.domains.first.domain;
      await _categoryDao.deleteCategories(currentDomain);
      debugPrint('[TenantRepository] Categorias do tenant anterior ($currentDomain) foram limpas');
    }
    
    final tenantModel = TenantMapper.toModel(tenant);
    await _tenantConfigDao.saveTenantSelection(tenantModel);
  }

  @override
  Future<TenantEntity?> getSelectedTenant() async {
    final tenantModel = await _tenantConfigDao.getSelectedTenant();
    return tenantModel != null ? TenantMapper.toEntity(tenantModel) : null;
  }

  @override
  Future<void> clearSelectedTenant() async {
    await _tenantConfigDao.clearTenantConfig();
  }
}

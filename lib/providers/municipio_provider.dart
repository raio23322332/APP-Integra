import 'package:flutter/material.dart';
import 'package:integra_app/data/dao/tenant_config_dao.dart';
import 'package:integra_app/data/models/tenant_model.dart' show Tenant;
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/services/domain/domain_service.dart';
import 'package:integra_app/services/storage/domain_storage.dart';

import '../core/navigation/navigation_constants.dart';
import '../domain/mappers/tenant_mapper.dart';
import '../domain/usecases/tenant/save_selected_tenant_usecase.dart';
import '../services/navigation_service.dart';

class MunicipioProvider extends ChangeNotifier {
  final DomainStorage _domainStorage;
  final DomainService _domainService;
  final SaveSelectedTenantUseCase _saveSelectedTenantUseCase;
  final TenantConfigDao _tenantConfigDao;

  MunicipioProvider({
    required DomainStorage domainStorage,
    required DomainService domainService,
    required SaveSelectedTenantUseCase saveSelectedTenantUseCase,
    required TenantConfigDao tenantConfigDao,
  })  : _domainStorage = domainStorage,
        _domainService = domainService,
        _saveSelectedTenantUseCase = saveSelectedTenantUseCase,
        _tenantConfigDao = tenantConfigDao;

  Tenant? _tenantSelecionado;
  Tenant? get tenantSelecionado => _tenantSelecionado;

  List<Tenant> _tenants = [];
  List<Tenant> get tenants => _tenants;

  Tenant? _lastSelectedTenant;
  Tenant? get lastSelectedTenant => _lastSelectedTenant;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> init() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _tenants = await _domainService.listTenants();
      _tenants.sort((a, b) => a.id.compareTo(b.id));

      _lastSelectedTenant = await _tenantConfigDao.getSelectedTenant();
      _tenantSelecionado = _lastSelectedTenant;

      if (_lastSelectedTenant != null) {
        _tenantSelecionado = _tenants.firstWhere(
          (tenant) => tenant.id == _lastSelectedTenant!.id,
          orElse: () => _lastSelectedTenant!,
        );

        ConsoleLog.debug(
          'MunicipioProvider.init: tenant selecionado $_tenantSelecionado',
        );

        _lastSelectedTenant = _tenantSelecionado;
        _tenants.removeWhere(
          (tenant) => tenant.id == _lastSelectedTenant!.id,
        );

        _tenants.insert(0, _lastSelectedTenant!);

        ConsoleLog.debug(
          'MunicipioProvider.init: último tenant $_lastSelectedTenant',
        );
      }
    } catch (err) {
      ConsoleLog.error('MunicipioProvider.init: $err');
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectAndSaveTenant(Tenant tenant) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _domainStorage.saveTenantSelection(tenant);

      final tenantEntity = TenantMapper.toEntity(tenant);
      await _saveSelectedTenantUseCase.execute(tenantEntity);

      _tenantSelecionado = tenant;
      _lastSelectedTenant = tenant;

      _tenants.removeWhere((t) => t.id == tenant.id);
      _tenants.insert(0, tenant);

      notifyListeners();

      NavigationService.instance.pushTo(
        NavigationConstants.login,
        extra: tenant,
      );
    } catch (err) {
      ConsoleLog.error('MunicipioProvider.selectAndSaveTenant: $err');
      _error = err.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
// lib/presentation/providers/tenant_providers.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/usecases/tenant/get_tenants_usecase.dart';
import '../../domain/usecases/tenant/save_selected_tenant_usecase.dart';
import '../../domain/repositories/tenant_repository_impl.dart';
import '../../services/domain/domain_service.dart';
import '../../services/http/domain_http.dart';
import '../../data/dao/tenant_config_dao.dart';
import '../../data/dao/category_dao.dart';
import '../../services/logout_service_impl.dart';
import '../viewmodels/tenant_select_viewmodel.dart';
import '../viewmodels/auth/auth_viewmodel.dart';

/// ✅ MVVM: Container de Injeção de Dependências para o módulo Tenant
/// Centraliza criação de dependências, removendo lógica da View
class TenantProviders {
  // ✅ Factory method para criar ViewModel com todas as dependências
  static TenantSelectViewModel createViewModel(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    // Criar dependências em ordem de injeção
    final tenantConfigDao = TenantConfigDao();
    final categoryDao = CategoryDao();
    final domainHttp = DomainHttp();
    final domainService = DomainService(
      tenantConfigDao: tenantConfigDao,
      domainHttp: domainHttp,
    );

    final tenantRepository = TenantRepositoryImpl(
      domainService: domainService,
      tenantConfigDao: tenantConfigDao,
      categoryDao: categoryDao,
    );

    final getTenantsUseCase = GetTenantsUseCase(tenantRepository);
    final saveSelectedTenantUseCase = SaveSelectedTenantUseCase(
      tenantRepository,
    );
    final logoutService = LogoutServiceImpl(authViewModel);

    return TenantSelectViewModel(
      getTenantsUseCase: getTenantsUseCase,
      saveSelectedTenantUseCase: saveSelectedTenantUseCase,
      logoutService: logoutService,
      tenantConfigDao: tenantConfigDao,
    );
  }

  static ChangeNotifierProvider<TenantSelectViewModel> viewModelProvider({
    required Widget child,
  }) {
    return ChangeNotifierProvider<TenantSelectViewModel>(
      create: createViewModel,
      child: child,
    );
  }
}

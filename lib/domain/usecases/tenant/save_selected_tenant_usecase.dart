// lib/domain/usecases/tenant/save_selected_tenant_usecase.dart

import 'package:integra_app/domain/entities/tenant_entity.dart';
import 'package:integra_app/domain/repositories/tenant_repository.dart';

class SaveSelectedTenantUseCase {
  final TenantRepository _repository;

  SaveSelectedTenantUseCase(this._repository);

  Future<void> execute(TenantEntity tenant) async {
    return await _repository.saveSelectedTenant(tenant);
  }
}

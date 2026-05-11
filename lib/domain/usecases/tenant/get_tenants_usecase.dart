// lib/domain/usecases/tenant/get_tenants_usecase.dart

import 'package:integra_app/domain/entities/tenant_entity.dart';
import 'package:integra_app/domain/repositories/tenant_repository.dart';

class GetTenantsUseCase {
  final TenantRepository _repository;

  GetTenantsUseCase(this._repository);

  Future<List<TenantEntity>> execute() async {
    return await _repository.getTenants();
  }
}

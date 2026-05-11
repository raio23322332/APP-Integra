// lib/core/contracts/domain_service_contract.dart

import 'package:integra_app/data/models/tenant_model.dart';

/// Contrato abstrato para serviços de domínio/tenant
/// Define a interface que todos os serviços de domínio devem implementar
abstract class DomainServiceContract {
  Future<List<Tenant>> listTenants();
}

// lib/core/contracts/domain_http_contract.dart

import 'package:http/http.dart' as http;

/// Contrato para comunicação HTTP com serviços de domínio
abstract class DomainHttpContract {
  /// Busca lista de tenants/domínios disponíveis
  Future<http.Response> fetchTenants();
}

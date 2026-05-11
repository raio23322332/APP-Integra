import 'package:integra_app/core/contracts/domain_http_contract.dart';

import '../../core/helpers/console_log.dart';
import 'base_service.dart';
import 'package:http/http.dart' as http;

class DomainHttp implements DomainHttpContract {
  Future<http.Response> fetchTenants() async {
    final uri = Uri.parse(
      '${BaseService.BASE_URL}/api/v1/configuration/domains',
    );

    ConsoleLog.debug("uri: ${uri.toString()}");

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }
}

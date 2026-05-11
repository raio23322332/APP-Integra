import 'dart:convert';
import 'package:integra_app/core/contracts/domain_service_contract.dart';
import 'package:integra_app/core/contracts/domain_http_contract.dart';
import 'package:integra_app/data/dao/tenant_config_dao.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/core/helpers/console_log.dart';

class DomainService implements DomainServiceContract {
  final TenantConfigDao _tenantConfigDao;
  final DomainHttpContract _domainHttp;

  DomainService({
    required TenantConfigDao tenantConfigDao,
    required DomainHttpContract domainHttp,
  }) : _tenantConfigDao = tenantConfigDao,
       _domainHttp = domainHttp;

  Future<List<Tenant>> listTenants() async {
    final response = await _domainHttp.fetchTenants();
    List<Tenant> tenants = [];

    final jsonResponse = json.decode(response.body);

    try {
      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        ConsoleLog.error(
          "DomainService.listTenants: ${response.statusCode} - ${jsonEncode(errorData)}",
        );
        ConsoleLog.sucesso("jsonResponse: $jsonResponse");
        return tenants;
      }
      final List<dynamic> tenantsList = jsonResponse['tenants'] ?? [];

      tenants = tenantsList
          .map((item) => Tenant.fromMap(item as Map<String, dynamic>))
          .toList();

      ConsoleLog.sucesso("DomainService.listTenants: ${tenants.length} tenants loaded");

      return tenants;
    } catch (err) {
      ConsoleLog.error("DomainService.listTenants: $err");
      return tenants;
    }
  }
}

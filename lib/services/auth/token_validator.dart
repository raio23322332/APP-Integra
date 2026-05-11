import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/services/category_service.dart';

/// Valida tokens com a API e oferece fallback por domínio do tenant
class TokenValidator {
  final DomainStorage _storage;

  TokenValidator(this._storage);

  /// Valida o token atual com a API e sincroniza dados locais
  /// Retorna `true` se o token for válido, `false` se inválido/expirado
  Future<Map<String, dynamic>> validateAndSync() async {
    try {
      final authToken = await _storage.getAuthToken();
      debugPrint(
        '[TokenValidator] validateAndSync: token present? ${authToken != null}',
      );

      if (authToken != null) {
        debugPrint(
          '[TokenValidator] validateAndSync: token len=${authToken.length}',
        );
      }

      final tenant = await _storage.getSelectedTenant();
      debugPrint(
        '[TokenValidator] validateAndSync: tenant present? ${tenant != null}',
      );

      if (authToken == null || tenant == null) {
        return {
          'valid': false,
          'statusCode': null,
          'reason': 'no_token_or_tenant',
        };
      }

      return await _validateAgainstApi(authToken, tenant);
    } catch (e) {
      debugPrint('[TokenValidator] Erro validateAndSync: $e');
      return {'valid': false, 'statusCode': null, 'reason': 'exception'};
    }
  }

  Future<Map<String, dynamic>> _validateAgainstApi(
    String authToken,
    Tenant tenant,
  ) async {
    final String? baseFromEnv = dotenv.env['URL_BASE_API'];
    if (baseFromEnv == null) {
      debugPrint('[TokenValidator] URL_BASE_API não definida');
      return {'valid': false, 'statusCode': null, 'reason': 'no_base_url'};
    }

    final String baseUrl = baseFromEnv.endsWith('/')
        ? baseFromEnv.substring(0, baseFromEnv.length - 1)
        : baseFromEnv;

    final tenantDomain =
        tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;
    if (tenantDomain == null || tenantDomain.isEmpty) {
      return {'valid': false, 'statusCode': null, 'reason': 'no_tenant_domain'};
    }

    // Primeira tentativa com base URL da API
    final Uri meUrl = Uri.parse('$baseUrl/api/v1/auth/login');
    debugPrint(
      '[TokenValidator] validateAndSync: POSTing to $meUrl with Host=$tenantDomain',
    );

    final response = await http.post(
      meUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Host': tenantDomain,
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(<String, String>{}),
    );

    debugPrint(
      '[TokenValidator] validateAndSync: statusCode=${response.statusCode}',
    );

    if (response.statusCode == 200) {
      // Sincroniza categorias em background após login/validação bem-sucedida
      _syncCategories(tenant, authToken);
      return {'valid': true, 'statusCode': 200, 'reason': 'ok'};
    } else if (response.statusCode == 401) {
      debugPrint(
        '[TokenValidator] validateAndSync: 401 received, token inválido.',
      );
      return {'valid': false, 'statusCode': 401, 'reason': 'unauthorized'};
    }

    // Fallback: Se 404, tenta domínio específico do tenant
    if (response.statusCode == 404) {
      return await _tryTenantFallback(authToken, tenant, tenantDomain);
    }

    return {
      'valid': false,
      'statusCode': response.statusCode,
      'reason': 'unexpected_status',
    };
  }

  Future<Map<String, dynamic>> _tryTenantFallback(
    String authToken,
    Tenant tenant,
    String tenantDomain,
  ) async {
    try {
      final tenantBaseRaw = tenant.urlSubdomainBase ?? '';
      if (tenantBaseRaw.isNotEmpty &&
          (tenantBaseRaw.startsWith('http://') ||
              tenantBaseRaw.startsWith('https://'))) {
        final tenantBase = tenantBaseRaw.endsWith('/')
            ? tenantBaseRaw
            : '$tenantBaseRaw/';
        final Uri tenantMe = Uri.parse('${tenantBase}v1/auth/login');

        // debugPrint(
        //   '[TokenValidator] validateAndSync: retrying POST against tenant base: $tenantMe',
        // );

        final secondResp = await http.post(
          tenantMe,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            'Host': tenantDomain,
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode(<String, String>{}),
        );

        if (secondResp.statusCode != 200) {
          if (secondResp.statusCode == 401) {
            ConsoleLog.error(
              "TokenValidator._tryTenantFallback: validateAndSync: tenant retry returned ${secondResp.statusCode.toString()}",
            );
            return {
              'valid': false,
              'statusCode': 401,
              'reason': 'unauthorized',
            };
          }
          return {
            'valid': false,
            'statusCode': secondResp.statusCode,
            'reason': 'tenant_retry_failed',
          };
        }

        // Sincroniza categorias em background após login/validação bem-sucedida
        _syncCategories(tenant, authToken);
        return {
          'valid': true,
          'statusCode': 200,
          'reason': 'ok_tenant_fallback',
        };
      }
    } catch (err) {
      ConsoleLog.error("TokenValidator._tryTenantFallback: $err");
    }

    return {'valid': false, 'statusCode': null, 'reason': 'fallback_failed'};
  }

  /// Sincroniza as categorias do tenant em background
  void _syncCategories(Tenant tenant, String token) {
    try {
      debugPrint('[TokenValidator] Iniciando sincronização de categorias em background...');
      CategoryService().getCategories(tenant, token).then((_) {
        debugPrint('[TokenValidator] Sincronização de categorias concluída com sucesso.');
      }).catchError((e) {
        debugPrint('[TokenValidator] Erro na sincronização de categorias em background: $e');
      });
    } catch (e) {
      debugPrint('[TokenValidator] Falha ao disparar sincronização de categorias: $e');
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/tenant_model.dart';

class ServiceService {
  /// Busca um serviço específico por ID
  Future<models.Service?> getServiceById(int serviceId, Tenant tenant, String token) async {
    // Obtém domínio do tenant
    final String? tenantDomain =
        tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;

    if (tenantDomain == null || tenantDomain.isEmpty) {
      throw Exception('Tenant sem domínio configurado para buscar serviço.');
    }

    // Obter a URL base da API a partir do .env
    final String? baseFromEnv = dotenv.env['URL_BASE_API'];
    if (baseFromEnv == null) {
      throw Exception('URL_BASE_API não definida no arquivo .env');
    }

    // Construir a URL final da requisição
    final Uri serviceUrl = Uri.parse('$baseFromEnv/api/v1/services/$serviceId');
    debugPrint('🔗 Buscando serviço em: $serviceUrl');
    debugPrint('🌐 Para o Host: $tenantDomain');

    try {
      final response = await http.get(
        serviceUrl,
        headers: {
          'Accept': 'application/json',
          'Host': tenantDomain, // ESSENCIAL para identificar o tenant
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Status Code Serviço: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ConsoleLog.sucesso('Dados do serviço: ${responseData.toString()}');
        
        // Parse do serviço
        final service = models.Service.fromJson(responseData);
        debugPrint('✅ Serviço encontrado: ${service.title}');
        return service;
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ Serviço não encontrado (404)');
        return null;
      } else {
        throw Exception(
          'Falha ao buscar serviço. Status: ${response.statusCode}. Body: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('🌐 Erro ao buscar serviço: $e');
      return null;
    }
  }

  /// Busca múltiplos serviços por uma lista de IDs
  Future<List<models.Service>> getServicesByIds(List<int> serviceIds, Tenant tenant, String token) async {
    final List<models.Service> services = [];
    
    for (final serviceId in serviceIds) {
      try {
        final service = await getServiceById(serviceId, tenant, token);
        if (service != null) {
          services.add(service);
        }
      } catch (e) {
        debugPrint('❌ Erro ao buscar serviço $serviceId: $e');
        // Continua para o próximo serviço mesmo que um falhe
      }
    }
    
    return services;
  }
}

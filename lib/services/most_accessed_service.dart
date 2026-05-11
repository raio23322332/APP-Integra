import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:integra_app/core/helpers/console_log.dart';
import '../data/models/category_model.dart' as models;

class MostAccessedService {
  Future<List<models.Service>> getMostAccessedServices({
    required String tenantDomain,
    required String token,
    int limit = 10,
  }) async {
    final String? baseFromEnv = dotenv.env['URL_BASE_API'];
    if (baseFromEnv == null) {
      throw Exception('URL_BASE_API não definida no arquivo .env');
    }

    final Uri url = Uri.parse('$baseFromEnv/api/v1/services/most-accessed?limit=$limit');
    debugPrint('🔗 Buscando serviços mais acessados em: $url');
    debugPrint('🌐 Para o Host: $tenantDomain');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Host': tenantDomain,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Status Code Most Accessed: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData is List 
            ? responseData 
            : (responseData['data'] as List<dynamic>? ?? []);
        
        ConsoleLog.sucesso('Serviços mais acessados: ${data.length}');
        
        List<models.Service> services = data
            .map((s) => models.Service.fromJson(s))
            .toList();

        return services;
      } else {
        throw Exception(
          'Falha ao carregar serviços mais acessados. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('🌐 Erro ao buscar serviços mais acessados: $e');
      throw Exception('Erro ao buscar serviços mais acessados: $e');
    }
  }

  /// Incrementa o contador de acessos de um serviço
  Future<void> incrementServiceAccess({
    required int serviceId,
    required String tenantDomain,
    required String token,
  }) async {
    final String? baseFromEnv = dotenv.env['URL_BASE_API'];
    if (baseFromEnv == null) {
      throw Exception('URL_BASE_API não definida no arquivo .env');
    }

    final Uri url = Uri.parse('$baseFromEnv/api/v1/services/$serviceId/access');
    debugPrint('🔗 Incrementando acessos do serviço $serviceId em: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Host': tenantDomain,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      debugPrint('Status Code Increment Access: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception(
          'Falha ao incrementar acessos. Status: ${response.statusCode}',
        );
      }
      
      debugPrint('✅ Contador de acessos incrementado com sucesso');
    } catch (e) {
      debugPrint('🌐 Erro ao incrementar acessos: $e');
      throw Exception('Erro ao incrementar acessos: $e');
    }
  }
}

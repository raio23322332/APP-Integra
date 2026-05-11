import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../shared_preference_service.dart';
import '../../data/models/sector_model.dart';

class SectorHttp {
  final SharedPreferenceService _pref = SharedPreferenceService();

  Future<http.Response> _request(String endpoint, {String? method, Map<String, dynamic>? body}) async {
    await _pref.init();
    final token = _pref.getAccessToken();
    final tenant = _pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];

    if (token == null || baseUrl == null) throw Exception('Dados de autenticação ausentes');

    final url = '$baseUrl/$endpoint';
    final request = http.Request(method ?? 'GET', Uri.parse(url))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Host': tenant ?? '',
        'Accept': 'application/json',
      });

    if (body != null && method != 'GET') request.body = json.encode(body);

    final response = await request.send();
    return await http.Response.fromStream(response);
  }

  Future<List<SectorModel>> getSectors({bool? isActive, String? search, int maxRetries = 2}) async {
    final params = <String, String>{};
    if (isActive != null) params['is_active'] = isActive.toString();
    if (search != null) params['q'] = search;

    final endpoint = 'api/v1/sectors${params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'}';
    
    int attempts = 0;
    Exception? lastException;
    
    while (attempts <= maxRetries) {
      try {
        final response = await _request(endpoint);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final sectorsResponse = data['sectors'];
          
          // Se for paginado (Laravel), pega os dados de 'data'
          List<dynamic> sectorsData;
          if (sectorsResponse is Map && sectorsResponse.containsKey('data')) {
            sectorsData = sectorsResponse['data'] as List<dynamic>;
          } else if (sectorsResponse is List) {
            sectorsData = sectorsResponse;
          } else {
            sectorsData = [];
          }
          
          // Converte explicitamente para List<SectorModel>
          final List<SectorModel> sectorsList = [];
          for (var i = 0; i < sectorsData.length; i++) {
            final item = sectorsData[i];
            if (item is Map<String, dynamic>) {
              sectorsList.add(SectorModel.fromJson(item));
            }
          }
          
          return sectorsList;
        } else if (response.statusCode == 503) {
          // Serviço indisponível - tenta novamente
          attempts++;
          if (attempts <= maxRetries) {
            print('DEBUG: Serviço indisponível (503), tentando novamente ($attempts/$maxRetries)...');
            await Future.delayed(Duration(seconds: attempts * 2)); // Backoff exponencial
            continue;
          }
          throw Exception('Serviço temporariamente indisponível. Tente novamente em alguns minutos. (503)');
        } else {
          throw Exception('Erro: ${response.statusCode}');
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        // Se já tentou o máximo de vezes ou é outro tipo de erro, retorna
        if (attempts >= maxRetries || !(e.toString().contains('SocketException') || e.toString().contains('TimeoutException'))) {
          print('DEBUG: Erro em getSectors após $attempts tentativas: $e');
          throw lastException!;
        }
        
        attempts++;
        print('DEBUG: Erro de conexão em getSectors, tentando novamente ($attempts/$maxRetries)...');
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    if (lastException != null) {
      throw lastException;
    }
    throw Exception('Erro desconhecido ao carregar setores');
  }

  Future<SectorModel> createSector({required String name, required int code, bool isActive = true}) async {
    final response = await _request('api/v1/sectors', method: 'POST', body: {
      'name': name,
      'code': code,
      'is_active': isActive,
    });

    if (response.statusCode != 201) throw Exception('Erro: ${response.statusCode}');
    return SectorModel.fromJson(json.decode(response.body));
  }

  Future<SectorModel> updateSector({required String id, String? name, int? code, bool? isActive}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (code != null) body['code'] = code;
    if (isActive != null) body['is_active'] = isActive;

    final response = await _request('api/v1/sectors/$id', method: 'PUT', body: body);
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    return SectorModel.fromJson(json.decode(response.body));
  }

  Future<bool> deleteSector(String id) async {
    final response = await _request('api/v1/sectors/$id', method: 'DELETE');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}

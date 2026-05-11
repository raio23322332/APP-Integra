import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared_preference_service.dart';
import '../../data/models/protocol_model.dart';
import '../../data/models/protocol_appendix_model.dart';
import '../../data/models/protocol_attachment_model.dart';
import '../../data/models/protocol_notification_model.dart';

class ProtocolHttp {
  final SharedPreferenceService _pref = SharedPreferenceService();

  Future<http.Response> _request(String endpoint, {String? method, Map<String, dynamic>? body}) async {
    await _pref.init();
    final token = _pref.getAccessToken();
    final tenant = _pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];

    if (token == null || baseUrl == null) {
      throw Exception('Dados de autenticação ausentes. Verifique a configuração da API.');
    }

    final url = '$baseUrl/$endpoint';
    final request = http.Request(method ?? 'GET', Uri.parse(url))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Host': tenant ?? '',
        'Accept': 'application/json',
      });

    if (body != null && method != 'GET') request.body = json.encode(body);

    try {
      final response = await request.send();
      final httpResponse = await http.Response.fromStream(response);
      
      // Log para debug
      print('API Request: $method $url');
      print('Response Status: ${httpResponse.statusCode}');
      if (httpResponse.statusCode >= 400) {
        print('Response Body: ${httpResponse.body}');
      }
      
      return httpResponse;
    } catch (e) {
      throw Exception('Erro de conexão com a API: $e');
    }
  }

  String _extractErrorMessage(http.Response response, {String defaultMessage = 'Erro inesperado'}) {
    final body = response.body;
    if (body.trim().isEmpty) return defaultMessage;

    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['error'] ?? decoded['message'] ?? defaultMessage;
      }
      return defaultMessage;
    } on FormatException {
      final trimmed = body.trimLeft();
      final lowercased = trimmed.toLowerCase();
      if (lowercased.startsWith('<!doctype html') || lowercased.startsWith('<html')) {
        return 'Resposta HTML inesperada do servidor. O arquivo pode ser maior do que o limite aceito ou o servidor retornou uma página de erro.';
      }
      final preview = trimmed.length <= 160 ? trimmed : '${trimmed.substring(0, 160)}...';
      return 'Resposta inválida do servidor: $preview';
    } catch (_) {
      return defaultMessage;
    }
  }

  Future<List<ProtocolModel>> getProtocols() async {
    final response = await _request('api/v1/protocolos');
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    
    final data = json.decode(response.body) as List;
    return data.map((json) => ProtocolModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<ProtocolModel> createProtocol({
    required String sectorId,
    required String direction,
    required String subject,
    String? documentType,
    String? notes,
    String? originProtocol,
    String? originAgency,
    bool isConfidential = false,
    bool isEmergency = false,
    String? registeredAt,
  }) async {
    final body = {
      'sector_id': sectorId,
      'direction': direction,
      'subject': subject,
      'document_type': documentType,
      'notes': notes,
      'origin_protocol': originProtocol,
      'origin_agency': originAgency,
      'is_confidential': isConfidential,
      'is_emergency': isEmergency,
      if (registeredAt != null) 'registered_at': registeredAt,
    };
    
    // Debug: verificar o que está sendo enviado
    print('📤 Enviando para backend: $body');
    
    final response = await _request('api/v1/protocolos', method: 'POST', body: body);

    if (response.statusCode != 201) throw Exception('Erro: ${response.statusCode}');
    return ProtocolModel.fromJson(json.decode(response.body));
  }

  Future<ProtocolModel> cancelProtocol(String id, {required String reason}) async {
    final response = await _request('api/v1/protocolos/$id/cancelar', method: 'POST', 
      body: {'reason': reason});
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    return ProtocolModel.fromJson(json.decode(response.body));
  }

  Future<ProtocolModel> archiveProtocol(String id, {String? message}) async {
    final response = await _request('api/v1/protocolos/$id/arquivar', method: 'POST', 
      body: message != null ? {'message': message} : {});
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    return ProtocolModel.fromJson(json.decode(response.body));
  }

  Future<ProtocolModel> forwardProtocol(String id, {required String toSectorId, String? message}) async {
    final response = await _request('api/v1/protocolos/$id/tramitar', method: 'POST', 
      body: {'to_sector_id': toSectorId, if (message != null) 'message': message});
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    return ProtocolModel.fromJson(json.decode(response.body));
  }

  Future<ProtocolModel> receiveProtocol(String id, {String? message}) async {
    final response = await _request('api/v1/protocolos/$id/receber', method: 'POST', 
      body: message != null ? {'message': message} : {});
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    return ProtocolModel.fromJson(json.decode(response.body));
  }

  Future<ProtocolModel> commentProtocol(String id, {required String message}) async {
    final response = await _request('api/v1/protocolos/$id/comentar', method: 'POST', 
      body: {'message': message});
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    return ProtocolModel.fromJson(json.decode(response.body));
  }

  // Apensos
  Future<List<ProtocolAppendixModel>> getAppendices(String protocolId) async {
    final response = await _request('api/v1/protocolos/$protocolId/apensos');
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    
    final decodedData = json.decode(response.body);
    print('Resposta getAppendices: ${response.body}');
    
    try {
      List<dynamic> dataList = [];
      
      // O backend retorna uma lista direta de ProtocolAppendixResource
      if (decodedData is List) {
        dataList = decodedData;
      } else if (decodedData is Map<String, dynamic>) {
        // Se for um mapa, tenta extrair a lista de apensos
        if (decodedData.containsKey('data') && decodedData['data'] is List) {
          dataList = decodedData['data'] as List<dynamic>;
        } else {
          // Fallback: procura por qualquer valor que seja uma lista
          dataList = decodedData.values
              .where((value) => value is List)
              .cast<List<dynamic>>()
              .firstWhere((list) => list.isNotEmpty, orElse: () => []);
        }
      }
      
      return dataList
          .where((item) => item is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .map((json) => ProtocolAppendixModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao fazer parse dos apensos: $e');
      throw Exception('Erro ao processar resposta da API: $e');
    }
  }

  Future<ProtocolAppendixModel> createAppendix({
    required String protocolId,
    required String title,
    String? documentType,
    String? notes,
    required String sectorId,
  }) async {
    final response = await _request('api/v1/protocolos/$protocolId/apensos', method: 'POST', body: {
      'title': title,
      'document_type': documentType,
      'notes': notes,
      'sector_id': sectorId,
    });

    print('Create Appendix - Status: ${response.statusCode}');
    print('Create Appendix - Response: ${response.body}');

    if (response.statusCode != 201) {
      final errorMessage = _extractErrorMessage(response, defaultMessage: 'Erro ao criar apenso');
      throw Exception('Erro ${response.statusCode}: $errorMessage');
    }
    
    return ProtocolAppendixModel.fromJson(json.decode(response.body));
  }

  Future<ProtocolAppendixModel> createAppendixWithFiles({
    required String protocolId,
    required String title,
    String? documentType,
    String? notes,
    required String sectorId,
    List<File>? files,
  }) async {
    await _pref.init();
    final token = _pref.getAccessToken();
    final tenant = _pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];

    if (token == null || baseUrl == null) throw Exception('Dados de autenticação ausentes');

    final endpoint = '$baseUrl/api/v1/protocolos/$protocolId/apensos';

    final request = http.MultipartRequest('POST', Uri.parse(endpoint))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      })
      ..fields['title'] = title
      ..fields['sector_id'] = sectorId;

    if (documentType != null && documentType.isNotEmpty) {
      request.fields['document_type'] = documentType;
    }
    if (notes != null && notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }

    // Adicionar arquivos se fornecidos
    if (files != null && files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        request.files.add(await http.MultipartFile.fromPath(
          'files[$i]',
          file.path,
        ));
      }
    }

    // Configura o header Host para ambientes de desenvolvimento
    if (baseUrl.contains('192.168') || baseUrl.contains('localhost')) {
      if (tenant != null && tenant.isNotEmpty) {
        request.headers['Host'] = tenant.contains('.') ? tenant : '$tenant.localhost';
      }
    } else {
      // Configuração para ambiente de produção
      if (tenant != null && tenant.isNotEmpty) {
        request.headers['Host'] = tenant.contains('.') ? tenant : '$tenant.integradigital.com.br';
      }
    }

    print('Create Appendix with Files - Endpoint: $endpoint');
    print('Create Appendix with Files - Files count: ${files?.length ?? 0}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Create Appendix with Files - Status: ${response.statusCode}');
    print('Create Appendix with Files - Response: ${response.body}');

    if (response.statusCode != 201) {
      final errorMessage = _extractErrorMessage(response, defaultMessage: 'Erro ao criar apenso');
      throw Exception('Erro ${response.statusCode}: $errorMessage');
    }
    
    return ProtocolAppendixModel.fromJson(json.decode(response.body));
  }

  Future<ProtocolAppendixModel> updateAppendix({
    required String protocolId,
    required String appendixId,
    String? title,
    String? documentType,
    String? notes,
    String? sectorId,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (documentType != null) body['document_type'] = documentType;
    if (notes != null) body['notes'] = notes;
    if (sectorId != null) body['sector_id'] = sectorId;

    final response = await _request('api/v1/protocolos/$protocolId/apensos/$appendixId', method: 'PUT', body: body);

    print('Update Appendix - Status: ${response.statusCode}');
    print('Update Appendix - Response: ${response.body}');

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Erro ao atualizar apenso';
      throw Exception('Erro ${response.statusCode}: $errorMessage');
    }
    
    return ProtocolAppendixModel.fromJson(json.decode(response.body));
  }

  Future<void> deleteAppendix(String protocolId, String appendixId) async {
    final response = await _request('api/v1/protocolos/$protocolId/apensos/$appendixId', method: 'DELETE');
    
    print('Delete Appendix - Status: ${response.statusCode}');
    print('Delete Appendix - Response: ${response.body}');
    
    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Erro ao excluir apenso';
      throw Exception('Erro ${response.statusCode}: $errorMessage');
    }
  }

  // Anexos
  Future<List<ProtocolAttachmentModel>> getAttachments(String protocolId, {String? appendixId}) async {
    final endpoint = appendixId != null 
        ? 'api/v1/protocolos/$protocolId/apensos/$appendixId/anexos'
        : 'api/v1/protocolos/$protocolId/anexos';
    
    final response = await _request(endpoint);
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
    
    final decodedData = json.decode(response.body);
    print('Resposta getAttachments: ${response.body}');
    
    try {
      List<dynamic> dataList = [];
      
      // O backend sempre retorna uma lista direta de ProtocolAttachmentResource
      if (decodedData is List) {
        dataList = decodedData;
      } else if (decodedData is Map<String, dynamic>) {
        // Se for um mapa, tenta extrair a lista de anexos
        if (decodedData.containsKey('data') && decodedData['data'] is List) {
          dataList = decodedData['data'] as List<dynamic>;
        } else {
          // Fallback: procura por qualquer valor que seja uma lista
          dataList = decodedData.values
              .where((value) => value is List)
              .cast<List<dynamic>>()
              .firstWhere((list) => list.isNotEmpty, orElse: () => []);
        }
      }
      
      final result = dataList
          .where((item) => item is Map<String, dynamic>)
          .cast<Map<String, dynamic>>()
          .map((json) => ProtocolAttachmentModel.fromJson(json))
          .toList();
          
      print('Anexos carregados: ${result.length}');
      return result;
      
    } catch (e) {
      print('Erro ao fazer parse dos anexos: $e');
      throw Exception('Erro ao processar resposta da API: $e');
    }
  }

  Future<ProtocolAttachmentModel> uploadAttachment({
    required String protocolId,
    required File file,
    String category = 'Documento',
    String? appendixId,
  }) async {
    await _pref.init();
    final token = _pref.getAccessToken();
    final tenant = _pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];

    if (token == null || baseUrl == null) throw Exception('Dados de autenticação ausentes');

    final endpoint = appendixId != null 
        ? '$baseUrl/api/v1/protocolos/$protocolId/apensos/$appendixId/anexos'
        : '$baseUrl/api/v1/protocolos/$protocolId/anexos';

    final request = http.MultipartRequest('POST', Uri.parse(endpoint))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      })
      ..files.add(await http.MultipartFile.fromPath('file', file.path))
      ..fields['category'] = category;

    // Configura o header Host para ambientes de desenvolvimento
    if (baseUrl.contains('192.168') || baseUrl.contains('localhost')) {
      if (tenant != null && tenant.isNotEmpty) {
        request.headers['Host'] = tenant.contains('.') ? tenant : '$tenant.localhost';
      }
    } else {
      // Configuração para ambiente de produção
      if (tenant != null && tenant.isNotEmpty) {
        request.headers['Host'] = tenant.contains('.') ? tenant : '$tenant.integradigital.com.br';
      }
    }

    print('Upload - Endpoint: $endpoint');
    print('Upload - Category: $category');
    print('Upload - File: ${file.path}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Upload - Status: ${response.statusCode}');
    print('Upload - Response: ${response.body}');

    if (response.statusCode != 201) {
      final errorMessage = _extractErrorMessage(response, defaultMessage: 'Erro ao fazer upload do anexo');
      throw Exception('Erro ${response.statusCode}: $errorMessage');
    }
    
    return ProtocolAttachmentModel.fromJson(json.decode(response.body));
  }

  Future<void> deleteAttachment(String protocolId, String attachmentId, {String? appendixId}) async {
    final endpoint = appendixId != null 
        ? 'api/v1/protocolos/$protocolId/apensos/$appendixId/anexos/$attachmentId'
        : 'api/v1/protocolos/$protocolId/anexos/$attachmentId';
    
    final response = await _request(endpoint, method: 'DELETE');
    if (response.statusCode != 200) throw Exception('Erro: ${response.statusCode}');
  }

  // Métodos de download e visualização simplificados
  Future<String> downloadAttachment(String protocolId, String attachmentId, {String? appendixId}) async {
    try {
      // Obtém a URL direta do anexo
      final viewUrl = await getAttachmentViewUrl(protocolId, attachmentId, appendixId: appendixId);
      
      // Tenta abrir a URL para download
      final uri = Uri.parse(viewUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return viewUrl;
      } else {
        throw Exception('Não foi possível abrir o URL para download');
      }
    } catch (e) {
      throw Exception('Erro ao baixar arquivo: $e');
    }
  }

  Future<bool> viewAttachment(String protocolId, String attachmentId, {String? appendixId}) async {
    try {
      final viewUrl = await getAttachmentViewUrl(protocolId, attachmentId, appendixId: appendixId);
      
      final uri = Uri.parse(viewUrl);
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      throw Exception('Não foi possível abrir o arquivo para visualização: $e');
    }
  }

  Future<String> getAttachmentViewUrl(String protocolId, String attachmentId, {String? appendixId}) async {
    final endpoint = appendixId != null 
        ? 'api/v1/protocolos/$protocolId/apensos/$appendixId/anexos/$attachmentId'
        : 'api/v1/protocolos/$protocolId/anexos/$attachmentId';
    
    print('Buscando URL do anexo em: $endpoint');
    
    final attachmentResponse = await _request(endpoint);
    print('Status code: ${attachmentResponse.statusCode}');
    
    if (attachmentResponse.statusCode != 200) {
      throw Exception('Erro ao obter informações do anexo: ${attachmentResponse.statusCode}');
    }

    final attachmentData = json.decode(attachmentResponse.body);
    print('Dados do anexo: $attachmentData');
    
    // O backend retorna o ProtocolAttachmentResource aninhado em 'data'
    final String? attachmentUrl = attachmentData['data']?['url'];

    if (attachmentUrl == null || attachmentUrl.isEmpty) {
      print('URL não encontrada nos dados. Campos disponíveis: ${attachmentData.keys.toList()}');
      throw Exception('URL do anexo não encontrada. Verifique se o anexo possui uma URL válida.');
    }
    
    print('URL do anexo: $attachmentUrl');
    return attachmentUrl;
  }

  Future<void> updateProtocol(
    String protocolId, {
    required String documentType,
    required String subject,
    String? notes,
    bool? isConfidential,
    bool? isEmergency,
  }) async {
    final body = <String, dynamic>{
      'document_type': documentType,
      'subject': subject,
      'notes': notes,
      if (isConfidential != null) 'is_confidential': isConfidential,
      if (isEmergency != null) 'is_emergency': isEmergency,
    };
    
    final response = await _request(
      'api/v1/protocolos/$protocolId',
      method: 'PUT',
      body: body,
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? errorData['message'] ?? 'Erro ao atualizar protocolo');
    }
  }

  // Helper para obter diretório de downloads
  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Para Android, tenta usar o diretório de Downloads
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory;
      }
      // Fallback para o diretório de documentos do app
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      // Para iOS, usa o diretório de documentos
      return await getApplicationDocumentsDirectory();
    } else {
      // Para outras plataformas, usa o diretório temporário
      return await getTemporaryDirectory();
    }
  }

  // Métodos de notificação
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    try {
      final response = await _request('api/v1/protocolos/avisos?page=$page');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final List<dynamic> notificationsData = responseData['data'];
          final notifications = notificationsData
              .map((json) => ProtocolNotificationModel.fromJson(json))
              .toList();
          
          return {
            'success': true,
            'data': notifications,
            'pagination': responseData['pagination'],
          };
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao carregar notificações');
        }
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao buscar notificações: $e');
    }
  }

  Future<ProtocolNotificationModel> markNotificationAsRead(String notificationId) async {
    try {
      print('DEBUG HTTP: Enviando requisição para marcar notificação $notificationId como lida...');
      final response = await _request(
        'api/v1/protocolos/avisos/$notificationId/read',
        method: 'POST',
      );
      
      print('DEBUG HTTP: Status code: ${response.statusCode}');
      print('DEBUG HTTP: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('DEBUG HTTP: Response data: $responseData');
        
        if (responseData['success'] == true) {
          final notification = ProtocolNotificationModel.fromJson(responseData['data']);
          print('DEBUG HTTP: Notificação parseada: isRead=${notification.isRead}');
          return notification;
        } else {
          throw Exception(responseData['message'] ?? 'Erro ao marcar notificação como lida');
        }
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('DEBUG HTTP: Erro na requisição: $e');
      throw Exception('Falha ao marcar notificação como lida: $e');
    }
  }

  Future<void> markMultipleNotificationsAsRead(List<String> notificationIds) async {
    try {
      final response = await _request(
        'api/v1/protocolos/avisos/mark-many-read',
        method: 'POST',
        body: {
          'notification_ids': notificationIds,
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] != true) {
          throw Exception(responseData['message'] ?? 'Erro ao marcar notificações como lidas');
        }
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Falha ao marcar notificações como lidas: $e');
    }
  }
}

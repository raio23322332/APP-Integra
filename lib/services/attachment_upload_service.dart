import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../../services/shared_preference_service.dart';

class AttachmentUploadService {
  final SharedPreferenceService _pref = SharedPreferenceService();

  Future<void> init() async {
    await _pref.init();
  }

  Future<bool> testConnection() async {
    await init();
    final token = _pref.getAccessToken();
    
    if (token == null) {
      throw Exception('Token de autenticação ausente');
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['URL_BASE_API']}/api/v1/health'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('Health check status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> uploadAttachment(
    String protocolId, 
    File file, {
    String? appendixId,
    String category = 'Documento',
  }) async {
    await init();
    final token = _pref.getAccessToken();
    final tenant = _pref.getTenantDomain();
    
    if (token == null) {
      throw Exception('Token de autenticação ausente');
    }

    final baseUrl = dotenv.env['URL_BASE_API'] ?? '';
    if (baseUrl.isEmpty) {
      throw Exception('URL_BASE_API não configurada no .env');
    }

    // Validar tamanho do arquivo antes do upload
    final fileSize = await file.length();
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxFileSize) {
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      throw Exception('Arquivo muito grande ($fileSizeMB MB). Tamanho máximo permitido: 10MB');
    }

    String endpoint;
    
    if (appendixId != null) {
      // Upload para anexo de apenso
      endpoint = 'api/v1/protocolos/$protocolId/apensos/$appendixId/anexos';
    } else {
      // Upload para anexo do protocolo principal
      endpoint = 'api/v1/protocolos/$protocolId/anexos';
    }

    final url = '$baseUrl/$endpoint';
    debugPrint('Upload endpoint: $url');
    debugPrint('File path: ${file.path}');
    debugPrint('File exists: ${await file.exists()}');
    debugPrint('File size: ${await file.length()} bytes');

    // Criar multipart request
    final request = http.MultipartRequest('POST', Uri.parse(url));
    
    // Adicionar headers seguindo o padrão do ProtocolHttp
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Host': tenant ?? '',
    });

    // Verificar se o arquivo existe antes de ler
    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: ${file.path}');
    }

    // Adicionar o arquivo
    final fileBytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    );
    request.files.add(multipartFile);

    // Adicionar campos adicionais
    request.fields['category'] = category;

    debugPrint('Request headers: ${request.headers}');
    debugPrint('Request fields: ${request.fields}');
    debugPrint('Files count: ${request.files.length}');

    try {
      // Enviar requisição
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
        final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Erro ao fazer upload do arquivo';
        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadAttachmentAlternative(
    String protocolId, 
    File file, {
    String? appendixId,
    String category = 'Documento',
  }) async {
    await init();
    final token = _pref.getAccessToken();
    final tenant = _pref.getTenantDomain();
    
    if (token == null) {
      throw Exception('Token de autenticação ausente');
    }

    final baseUrl = dotenv.env['URL_BASE_API'] ?? '';
    if (baseUrl.isEmpty) {
      throw Exception('URL_BASE_API não configurada no .env');
    }

    // Validar tamanho do arquivo antes do upload
    final fileSize = await file.length();
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxFileSize) {
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      throw Exception('Arquivo muito grande ($fileSizeMB MB). Tamanho máximo permitido: 10MB');
    }

    // Tentar endpoint alternativo (sem versionamento)
    String endpoint = 'api/v1/protocolos/$protocolId/anexos';
    if (appendixId != null) {
      endpoint = 'api/v1/protocolos/$protocolId/apensos/$appendixId/anexos';
    }

    final url = '$baseUrl/$endpoint';
    debugPrint('Alternative upload endpoint: $url');

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Host': tenant ?? '',
    });

    if (!await file.exists()) {
      throw Exception('Arquivo não encontrado: ${file.path}');
    }

    final fileBytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
    );
    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Alternative response status: ${response.statusCode}');
      debugPrint('Alternative response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
        final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Erro no upload alternativo';
        throw Exception('$errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Alternative upload error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createAppendix(
    String protocolId, {
    required String title,
    required String sectorId,
    String? documentType,
    String? notes,
  }) async {
    await init();
    final token = _pref.getAccessToken();
    final tenant = _pref.getTenantDomain();
    
    if (token == null) {
      throw Exception('Token de autenticação ausente');
    }

    final baseUrl = dotenv.env['URL_BASE_API'] ?? '';
    final endpoint = '$baseUrl/api/v1/protocolos/$protocolId/apensos';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Host': tenant ?? '',
      },
      body: json.encode({
        'title': title,
        'document_type': documentType,
        'notes': notes,
        'sector_id': sectorId,
      }),
    );

    debugPrint('Create appendix response status: ${response.statusCode}');
    debugPrint('Create appendix response body: ${response.body}');

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(errorData['error'] ?? errorData['message'] ?? 'Erro ao criar apenso');
    }
  }

  Future<void> deleteAttachment(
    String protocolId, 
    String attachmentId, {
    String? appendixId,
  }) async {
    await init();
    final token = _pref.getAccessToken();
    
    if (token == null) {
      throw Exception('Token de autenticação ausente');
    }

    final baseUrl = dotenv.env['URL_BASE_API'] ?? '';
    String endpoint;
    
    if (appendixId != null) {
      endpoint = '$baseUrl/api/v1/protocolos/$protocolId/apensos/$appendixId/anexos/$attachmentId';
    } else {
      endpoint = '$baseUrl/api/v1/protocolos/$protocolId/anexos/$attachmentId';
    }

    final response = await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(errorData['error'] ?? 'Erro ao excluir anexo');
    }
  }

  Future<void> deleteAppendix(String protocolId, String appendixId) async {
    await init();
    final token = _pref.getAccessToken();
    
    if (token == null) {
      throw Exception('Token de autenticação ausente');
    }

    final baseUrl = dotenv.env['URL_BASE_API'] ?? '';
    final endpoint = '$baseUrl/api/v1/protocolos/$protocolId/apensos/$appendixId';

    final response = await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(errorData['error'] ?? 'Erro ao excluir apenso');
    }
  }
}

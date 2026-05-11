// lib/data/datasources/remote/auth_remote_datasource_impl.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:integra_app/data/datasources/auth_remote_datasource.dart';


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client _client;
  final Duration _timeout;

  AuthRemoteDataSourceImpl({
    required http.Client client,
    Duration? timeout,
  }) : _client = client,
       _timeout = timeout ?? const Duration(seconds: 30);

  @override
  Future<Map<String, dynamic>> login({
    required String baseUrl,
    required String tenantDomain,
    required Map<String, dynamic> credentials,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '$baseUrl/api/v1/auth/login',
        headers: _buildHeaders(tenantDomain),
        body: credentials,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String baseUrl,
    required String tenantDomain,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _makeRequest(
        'POST',
        '$baseUrl/api/v1/auth/register',
        headers: _buildHeaders(tenantDomain),
        body: userData,
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  Future<http.Response> _makeRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(url);
    final requestBody = body != null ? jsonEncode(body) : null;

    final request = http.Request(method, uri);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (requestBody != null) {
      request.body = requestBody;
    }

    final streamedResponse = await _client.send(request).timeout(_timeout);
    return await http.Response.fromStream(streamedResponse);
  }

  Map<String, dynamic> _handleNetworkError(dynamic error) {
    String message = 'Erro de conexão. Verifique sua internet e tente novamente.';

    if (error is SocketException) {
      message = 'Sem conexão com a internet. Verifique sua rede.';
    } else if (error is TimeoutException) {
      message = 'Tempo limite excedido. Verifique sua conexão e tente novamente.';
    } else if (error is FormatException) {
      message = 'Resposta inválida do servidor.';
    } else if (error is http.ClientException) {
      message = 'Erro de comunicação com o servidor.';
    }

    return {
      'success': false,
      'data': {},
      'statusCode': 0,
      'message': message,
    };
  }

  Map<String, String> _buildHeaders([String? tenantDomain]) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (tenantDomain != null) {
      headers['Host'] = tenantDomain;
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Melhorar extração de mensagens para erros de validação (422)
    String message = data['message'] ?? '';

    if (response.statusCode == 422) {
      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final errorMessages = <String>[];
        errors.forEach((field, fieldErrors) {
          if (fieldErrors is List) {
            errorMessages.addAll(fieldErrors.map((e) => _translateErrorMessage(e.toString())));
          } else if (fieldErrors is String) {
            errorMessages.add(_translateErrorMessage(fieldErrors));
          }
        });
        if (errorMessages.isNotEmpty) {
          message = errorMessages.join('; ');
        }
      }
    }

    // Traduzir mensagens gerais de erro
    message = _translateErrorMessage(message);

    return {
      'success': response.statusCode >= 200 && response.statusCode < 300,
      'data': data,
      'statusCode': response.statusCode,
      'message': message,
    };
  }

  String _translateErrorMessage(String message) {
    // Converter para minúsculas para comparação
    final lowerMessage = message.toLowerCase();
    
    // Traduzir mensagens comuns de erro
    if (lowerMessage.contains('email has already been taken')) {
      return 'Este e-mail já está cadastrado. Por favor, use outro e-mail ou faça login.';
    }
    if (lowerMessage.contains('the email has already been taken')) {
      return 'Este e-mail já está cadastrado. Por favor, use outro e-mail ou faça login.';
    }
    if (lowerMessage.contains('email already exists')) {
      return 'Este e-mail já está cadastrado. Por favor, use outro e-mail ou faça login.';
    }
    if (lowerMessage.contains('the password field is required')) {
      return 'O campo senha é obrigatório.';
    }
    if (lowerMessage.contains('the email field is required')) {
      return 'O campo e-mail é obrigatório.';
    }
    if (lowerMessage.contains('the name field is required')) {
      return 'O campo nome é obrigatório.';
    }
    if (lowerMessage.contains('password confirmation does not match')) {
      return 'A confirmação de senha não coincide com a senha.';
    }
    if (lowerMessage.contains('password must be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (lowerMessage.contains('invalid credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (lowerMessage.contains('unauthorized')) {
      return 'Não autorizado. Verifique suas credenciais.';
    }
    
    // Se não houver tradução específica, retorna a mensagem original
    return message;
  }
}

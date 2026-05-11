// services/http/solicitacao_http.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../shared_preference_service.dart';
import 'package:http/http.dart' as http;
import 'package:integra_app/core/helpers/console_log.dart';

class SolicitacaoHttp {
  final pref = SharedPreferenceService();

  Future<http.Response> solicitacoes({required String slug}) async {
    ConsoleLog.debug('=== HTTP GET SOLICITAÇÕES ===');
    ConsoleLog.debug('Slug: $slug');

    await pref.init();
    String? tenantDomain = pref.getTenantDomain();
    String? token = pref.getAccessToken();

    ConsoleLog.debug('Token: ${token?.substring(0, 10)}...');
    ConsoleLog.debug('Tenant: $tenantDomain');
    ConsoleLog.debug('token: $token');
    final String? baseFromEnv = dotenv.env['URL_BASE_API'];

    if (baseFromEnv == null) {
      throw Exception('URL_BASE_API não definida no arquivo .env');
    }

    if (token == null || token.isEmpty) {
      throw Exception('Token de autenticação não encontrado');
    }

    String route = normalizeUrl(baseFromEnv, 'api/v1/solicitacoes/slug/$slug');
    ConsoleLog.debug('URL completa: $route');

    final response = await http.get(
      Uri.parse(route),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Host': tenantDomain ?? '',
      },
    ).timeout(
      Duration(seconds: 15),
      onTimeout: () {
        ConsoleLog.error('Timeout na listagem de solicitações');
        throw Exception('Tempo limite excedido na listagem (15s)');
      },
    );

    ConsoleLog.informacao('Status Code: ${response.statusCode}');
    ConsoleLog.informacao('Response Body: ${response.body}');

    return response;
  }

  Future<http.StreamedResponse> criarSolicitacaoComImagens(
    Map<String, String> dados, {
    List<File>? imagens,
  }) async {
    await pref.init();

    final token = pref.getAccessToken();
    final tenantDomain = pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    ConsoleLog.debug("token -> $token");
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    final uri = Uri.parse(normalizeUrl(baseUrl, 'api/v1/solicitacoes'));
    ConsoleLog.informacao('URL criação: $uri');

    final request = http.MultipartRequest('POST', uri);

    // Headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Host': tenantDomain ?? '',
    });
    
    ConsoleLog.informacao('Headers configurados');
    
    // Fields
    request.fields.addAll(dados);
    ConsoleLog.informacao('Fields adicionados: ${request.fields.length}');

    // Arquivos - processamento otimizado
    if (imagens != null && imagens.isNotEmpty) {
      ConsoleLog.informacao('Processando ${imagens.length} imagens...');
      
      for (int i = 0; i < imagens.length; i++) {
        final file = imagens[i];
        ConsoleLog.informacao('Processando imagem ${i + 1}: ${file.path}');

        final ext = p.extension(file.path).toLowerCase();
        final mime = {
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg',
          '.png': 'image/png',
          '.gif': 'image/gif',
        }[ext];

        if (mime == null) {
          ConsoleLog.error('Formato inválido: $ext');
          continue; // Pular inválidos em vez de lançar exceção
        }

        try {
          final multipartFile = await http.MultipartFile.fromPath(
            'imagens[$i]',
            file.path,
            contentType: MediaType.parse(mime),
          );
          request.files.add(multipartFile);
          ConsoleLog.informacao('Imagem ${i + 1} adicionada (${multipartFile.length} bytes)');
        } catch (e) {
          ConsoleLog.error('Erro ao processar imagem ${i + 1}: $e');
          continue; // Continuar com outras imagens
        }
      }
    }

    ConsoleLog.informacao('Enviando requisição com ${request.files.length} arquivos...');
    final response = await request.send().timeout(
      Duration(seconds: 45), // Aumentado para 45 segundos
      onTimeout: () {
        ConsoleLog.error('Timeout na requisição de criação');
        throw Exception('Tempo limite excedido na requisição (45s)');
      },
    );
    ConsoleLog.informacao('Resposta recebida: ${response.statusCode}');
    
    return response;
  }

  Future<http.Response> deletarSolicitacao(int solicitacaoId) async {
    await pref.init();

    final token = pref.getAccessToken();
    final tenantDomain = pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    final uri = Uri.parse(normalizeUrl(baseUrl, 'api/v1/solicitacoes/$solicitacaoId'));
    ConsoleLog.informacao('URL exclusão: $uri');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Host': tenantDomain ?? '',
      },
    ).timeout(
      Duration(seconds: 15),
      onTimeout: () {
        ConsoleLog.error('Timeout na exclusão de solicitação');
        throw Exception('Tempo limite excedido na exclusão (15s)');
      },
    );

    ConsoleLog.informacao('Status Code: ${response.statusCode}');
    ConsoleLog.informacao('Response Body: ${response.body}');

    return response;
  }

  String normalizeUrl(String baseUrl, String path) {
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$cleanBaseUrl/$cleanPath';
  }

  Future<dynamic> solicitacoesComFiltros({int? tipoId, int? subtipoId, String? userId}) async {}

  Future<http.StreamedResponse> atualizarSolicitacao(
    int solicitacaoId,
    Map<String, String> dados, {
    List<File>? imagens,
  }) async {
    await pref.init();

    final token = pref.getAccessToken();
    final tenantDomain = pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    final uri = Uri.parse(normalizeUrl(baseUrl, 'api/v1/solicitacoes/$solicitacaoId'));
    ConsoleLog.informacao('URL atualização: $uri');

    // Usar POST + _method=PUT para compatibilidade com uploads multipart
    final request = http.MultipartRequest('POST', uri);
    request.fields['_method'] = 'PUT';

    // Headers
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Host': tenantDomain ?? '',
    });

    // Fields
    request.fields.addAll(dados);
    ConsoleLog.informacao('Fields de atualização: ${request.fields.length}');

    // Arquivos - processamento otimizado
    if (imagens != null && imagens.isNotEmpty) {
      ConsoleLog.informacao('Adicionando ${imagens.length} novas imagens...');
      
      for (int i = 0; i < imagens.length; i++) {
        final file = imagens[i];

        final ext = p.extension(file.path).toLowerCase();
        final mime = {
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg',
          '.png': 'image/png',
          '.gif': 'image/gif',
        }[ext];

        if (mime == null) {
          ConsoleLog.error('Formato inválido: $ext');
          continue;
        }

        try {
          request.files.add(
            await http.MultipartFile.fromPath(
              'imagens[$i]',
              file.path,
              contentType: MediaType.parse(mime),
            ),
          );
        } catch (e) {
          ConsoleLog.error('Erro ao processar imagem na atualização: $e');
          continue;
        }
      }
    }

    ConsoleLog.informacao('Enviando atualização...');
    final response = await request.send().timeout(
      Duration(seconds: 45),
      onTimeout: () {
        ConsoleLog.error('Timeout na atualização');
        throw Exception('Tempo limite excedido na atualização');
      },
    );
    
    return response;
  }
}

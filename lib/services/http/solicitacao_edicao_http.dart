// services/http/solicitacao_edicao_http.dart
// ✅ SERVIÇO LIMPO E OTIMIZADO PARA EDIÇÃO DE SOLICITAÇÕES

import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../shared_preference_service.dart';
import 'package:http/http.dart' as http;
import 'package:integra_app/core/helpers/console_log.dart';

class SolicitacaoEdicaoHttp {
  final SharedPreferenceService _pref = SharedPreferenceService();

  // MÉTODO PRINCIPAL DE EDIÇÃO
  Future<http.Response> editarSolicitacao({
    required int solicitacaoId,
    required String serviceSlug,
    required String descricao,
    String? observacao,
    String? status,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
    String? latitude,
    String? longitude,
    List<File>? imagens,
    List<String>? imagensParaRemover,
  }) async {
    await _pref.init();

    final token = _pref.getAccessToken();
    final tenantDomain = _pref.getTenantDomain();
    final baseUrl = dotenv.env['URL_BASE_API'];
    
    if (token == null || baseUrl == null) {
      throw Exception('Configuração inválida');
    }

    // ✅ Corrigir tenant domain
    final correctedTenant = _getCorrectedTenantDomain(tenantDomain);
    // Usar endpoint CORRETO: /api/v1/solicitacoes/{id}/edit
    final request = http.MultipartRequest('PUT', Uri.parse(_normalizeUrl(baseUrl, 'api/v1/solicitacoes/$solicitacaoId/edit')));

    _setHeaders(request, token, correctedTenant);
    _setFields(request, {
      'service_slug': serviceSlug,
      'descricao': descricao,
      if (observacao?.isNotEmpty == true) 'observacao': observacao!,
      if (status?.isNotEmpty == true) 'status': status!,
      if (cep?.isNotEmpty == true) 'cep': cep!,
      if (logradouro?.isNotEmpty == true) 'logradouro': logradouro!,
      if (numero?.isNotEmpty == true) 'numero': numero!,
      if (bairro?.isNotEmpty == true) 'bairro': bairro!,
      if (cidade?.isNotEmpty == true) 'cidade': cidade!,
      if (estado?.isNotEmpty == true) 'estado': estado!,
      // Sempre enviar coordenadas para preservar as existentes
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (complemento?.isNotEmpty == true) 'complemento': complemento!,
      ..._getImagesParaRemoverFields(imagensParaRemover),
    });

    // ✅ Processar imagens com validação (só se houver)
    final validImages = imagens != null && imagens.isNotEmpty 
        ? await _validateAndFilterImages(imagens)
        : <File>[];
    
    await _addImagesToRequest(request, validImages);

    ConsoleLog.informacao(' Enviando requisição: ${validImages.length} imagens');
    
    return await _sendRequest(request);
  }

  // MÉTODO APENAS PARA IMAGENS
  Future<http.Response> adicionarImagem({
    required int solicitacaoId,
    required String serviceSlug,
    required List<File> imagens,
  }) async {
    return await editarSolicitacao(
      solicitacaoId: solicitacaoId,
      serviceSlug: serviceSlug,
      descricao: '',
      imagens: imagens,
    );
  }

  // MÉTODO EM LOTES (EVITAR ERRO 413)
  // MÉTODO EM LOTES (EVITAR ERRO 413)
  Future<List<http.Response>> enviarImagensEmLotes({
    required int solicitacaoId,
    required String serviceSlug,
    required List<File> imagens,
    int maxPorLote = 2,
    int maxMBPorLote = 4,
  }) async {
    final responses = <http.Response>[];
    final lotes = _createBatches(imagens, maxPorLote, maxMBPorLote);
    
    ConsoleLog.informacao(' ${imagens.length} imagens em ${lotes.length} lotes');
    
    for (int i = 0; i < lotes.length; i++) {
      final lote = lotes[i];
      ConsoleLog.informacao(' Enviando lote ${i + 1}/${lotes.length} (${lote.length} imagens)');
      
      try {
        final response = await adicionarImagem(
          solicitacaoId: solicitacaoId,
          serviceSlug: serviceSlug,
          imagens: lote,
        );
        responses.add(response);
        
        if (response.statusCode == 200) {
          ConsoleLog.informacao(' Lote ${i + 1} sucesso');
          ConsoleLog.informacao('✅ Lote ${i + 1} sucesso');
        } else {
          ConsoleLog.error('❌ Lote ${i + 1} erro: ${response.statusCode}');
        }
        
        // Pausa entre lotes
        if (i < lotes.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        ConsoleLog.error('❌ Erro lote ${i + 1}: $e');
        responses.add(http.Response('Erro lote ${i + 1}: $e', 500));
      }
    }
    
    return responses;
  }

  // ✅ MÉTODOS PRIVADOS AUXILIARES

  String _getCorrectedTenantDomain(String? tenantDomain) {
    return (tenantDomain == null || 
        tenantDomain.isEmpty || 
        tenantDomain.contains(RegExp(r'\d+\.\d+\.\d+\.\d+'))) 
        ? 'testtt.localhost' 
        : tenantDomain;
  }

  void _setHeaders(http.MultipartRequest request, String token, String tenantDomain) {
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Host': tenantDomain,
    });
  }

  void _setFields(http.MultipartRequest request, Map<String, String> fields) {
    request.fields.addAll(fields);
    ConsoleLog.informacao('📋 Fields: ${request.fields.length}');
  }

  Map<String, String> _getImagesParaRemoverFields(List<String>? imagensParaRemover) {
    final fields = <String, String>{};
    if (imagensParaRemover?.isNotEmpty == true) {
      for (int i = 0; i < imagensParaRemover!.length; i++) {
        fields['imagens_para_remover[$i]'] = imagensParaRemover[i];
      }
    }
    return fields;
  }

  Future<List<File>> _validateAndFilterImages(List<File> imagens) async {
    if (imagens.isEmpty) {
      ConsoleLog.informacao('📷 Nenhuma imagem para validar');
      return [];
    }
    
    final validImages = <File>[];
    int totalSize = 0;
    
    for (final file in imagens) {
      try {
        final fileSize = await file.length();
        final fileExists = await file.exists();
        
        // Validações
        if (!fileExists) {
          ConsoleLog.error('❌ Arquivo não existe: ${file.path}');
          continue;
        }
        
        if (fileSize == 0) {
          ConsoleLog.error('❌ Arquivo vazio: ${file.path}');
          continue;
        }
        
        if (fileSize > 2 * 1024 * 1024) {
          ConsoleLog.error('❌ Imagem grande: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB > 2MB');
          continue;
        }
        
        if (totalSize + fileSize > 4 * 1024 * 1024) {
          ConsoleLog.error('❌ Limite excedido: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB');
          continue;
        }
        
        final ext = p.extension(file.path).toLowerCase();
        final validExtensions = {'.jpg', '.jpeg', '.png', '.gif'};
        
        if (!validExtensions.contains(ext)) {
          ConsoleLog.error('❌ Formato inválido: $ext');
          continue;
        }
        
        validImages.add(file);
        totalSize += fileSize;
        
      } catch (e) {
        ConsoleLog.error('❌ Erro imagem ${file.path}: $e');
      }
    }
    
    ConsoleLog.informacao('✅ Imagens válidas: ${validImages.length}/${imagens.length}');
    ConsoleLog.informacao('✅ Tamanho total: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB');
    
    // Apenas lança exceção se houver imagens para processar mas nenhuma for válida
    if (imagens.isNotEmpty && validImages.isEmpty) {
      throw Exception('Nenhuma imagem válida. Use imagens < 2MB.');
    }
    
    return validImages;
  }

  Future<void> _addImagesToRequest(http.MultipartRequest request, List<File> images) async {
    for (int i = 0; i < images.length; i++) {
      final file = images[i];
      final ext = p.extension(file.path).toLowerCase();
      final mime = {
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.png': 'image/png',
        '.gif': 'image/gif',
      }[ext]!;
      
      try {
        final multipartFile = await http.MultipartFile.fromPath(
          'imagens[$i]',
          file.path,
          contentType: MediaType.parse(mime),
        );
        request.files.add(multipartFile);
        ConsoleLog.informacao('✅ Imagem $i: ${multipartFile.filename}');
      } catch (e) {
        ConsoleLog.error('❌ Erro ao adicionar imagem $i: $e');
      }
    }
  }

  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw Exception('Timeout na requisição'),
      );

      final response = await http.Response.fromStream(streamedResponse);
      
      ConsoleLog.informacao('📥 Status: ${response.statusCode}');
      ConsoleLog.informacao('📥 Body: ${response.body}');
      
      if (response.statusCode == 422) {
        _handle422Error(response.body);
      }
      
      return response;
    } catch (e) {
      ConsoleLog.error('❌ Erro requisição: $e');
      rethrow;
    }
  }

  void _handle422Error(String responseBody) {
    try {
      final errorData = json.decode(responseBody);
      ConsoleLog.error('❌ Erro 422: ${errorData['message']}');
      if (errorData['errors'] != null) {
        errorData['errors'].forEach((key, value) {
          ConsoleLog.error('  - $key: $value');
        });
      }
    } catch (e) {
      ConsoleLog.error('❌ Erro ao parsear 422: $e');
    }
  }

  List<List<File>> _createBatches(List<File> imagens, int maxPorLote, int maxMBPorLote) {
    final lotes = <List<File>>[];
    final loteAtual = <File>[];
    int tamanhoLoteAtual = 0;
    
    for (final imagem in imagens) {
      final tamanho = imagem.lengthSync();
      
      if (loteAtual.length >= maxPorLote || 
          tamanhoLoteAtual + tamanho > maxMBPorLote * 1024 * 1024) {
        if (loteAtual.isNotEmpty) {
          lotes.add(List.from(loteAtual));
          loteAtual.clear();
          tamanhoLoteAtual = 0;
        }
      }
      
      loteAtual.add(imagem);
      tamanhoLoteAtual += tamanho;
    }
    
    if (loteAtual.isNotEmpty) {
      lotes.add(loteAtual);
    }
    
    return lotes;
  }

  String _normalizeUrl(String baseUrl, String path) {
    if (!baseUrl.startsWith('http')) {
      baseUrl = baseUrl.contains('localhost') ? 'http://$baseUrl' : 'https://$baseUrl';
    }
    
    if (baseUrl.contains('localhost') && !baseUrl.contains(':8002')) {
      baseUrl = baseUrl.contains(':') ? baseUrl : '$baseUrl:8002';
    }
    
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    return '$cleanBaseUrl/$cleanPath';
  }
}

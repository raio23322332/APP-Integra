// services/solicitacao/solicitacao_servico.dart
import 'dart:convert';
import 'dart:io';

import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/services/http/solicitacao_http.dart';
import 'package:integra_app/data/models/solicitacao_model.dart';
import 'package:http/http.dart' as http;

import 'solicitacao_validator.dart';
import 'solicitacao_payload.dart';
import 'solicitacao_parser.dart';

class SolicitacaoServico {
  final SolicitacaoHttp _http = SolicitacaoHttp();

  Future<List<SolicitacaoModel>> getDataSolicitacoes({
    required String slug,
  }) async {
    try {
      final response = await _http.solicitacoes(slug: slug);

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final list = SolicitacaoParser.parseLista(data);

      return SolicitacaoModel.fromJsonList(list);
    } catch (e, s) {
      ConsoleLog.error('Erro getDataSolicitacoes: $e');
      ConsoleLog.error('$s');
      return [];
    }
  }

  Future<Map<String, dynamic>> criarSolicitacao({
    required String serviceSlug, // Alterado para service_slug obrigatório
    required String descricao,
    required int userId,
    String? observacao,
    bool privacidade = false,
    String? latitude,
    String? longitude,
    String? cep,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? logradouro,
    List<File>? imagens,
  }) async {
    final validation = SolicitacaoValidator.validarCriacao(
      serviceSlug: serviceSlug, // Atualizar validação
      userId: userId,
    );

    if (!validation['success']) return validation;

    final payload = SolicitacaoPayload.criar(
      serviceSlug: serviceSlug, // Enviar service_slug
      descricao: descricao,
      userId: userId,
      observacao: observacao,
      privacidade: privacidade,
      latitude: latitude,
      longitude: longitude,
      cep: cep,
      numero: numero,
      bairro: bairro,
      cidade: cidade,
      estado: estado,
      logradouro: logradouro,
    );

    // 🔥 RECEBE StreamedResponse
    final streamedResponse = await _http.criarSolicitacaoComImagens(
      payload,
      imagens: imagens,
    );

    // 🔥 CONVERTE PARA Response NORMAL
    final response = await http.Response.fromStream(streamedResponse);

    ConsoleLog.debug('Status Code: ${response.statusCode}');
    ConsoleLog.debug('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      return {'success': true, 'data': json.decode(response.body)};
    }

    return SolicitacaoParser.parseErro(response);
  }
}

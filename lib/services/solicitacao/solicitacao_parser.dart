// services/solicitacao/solicitacao_parser.dart
import 'dart:convert';
import 'package:integra_app/core/helpers/console_log.dart';

class SolicitacaoParser {
  static List<dynamic> parseLista(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final solicitacoes = data['solicitacoes'];

      if (solicitacoes is String) {
        return json.decode(solicitacoes);
      }

      if (solicitacoes is List) {
        return solicitacoes;
      }
    }

    return [];
  }

  static Map<String, dynamic> parseErro(dynamic response) {
    try {
      final body = response.body;
      ConsoleLog.debug('Parsing error response: $body');
      
      // 🔥 TRATAR ERRO 413 - Payload Too Large
      if (response.statusCode == 413) {
        return {
          'success': false,
          'message': 'Arquivos muito grandes. Cada imagem deve ter até 5MB (máx. 15MB total)',
        };
      }
      
      final decoded = json.decode(body);
      ConsoleLog.debug('Decoded response: $decoded');

      if (decoded is Map && decoded['errors'] is Map) {
        final errors = decoded['errors'] as Map;
        final message = errors.values
            .expand((e) => e is List ? e : [e])
            .join(', ');

        return {'success': false, 'message': message};
      }

      return {
        'success': false,
        'message': decoded['message'] ?? 'Erro ao criar solicitação (${response.statusCode})',
      };
    } catch (e) {
      ConsoleLog.error('Error parsing response: $e');
      ConsoleLog.error('Response body was: ${response.body}');
      
      // 🔥 TRATAR ERRO 413 MESMO SE FALHAR PARSING
      if (response.statusCode == 413) {
        return {
          'success': false,
          'message': 'Arquivos muito grandes. Cada imagem deve ter até 5MB (máx. 15MB total)',
        };
      }
      
      return {
        'success': false,
        'message': 'Erro inesperado na resposta da API (${response.statusCode})',
      };
    }
  }
}

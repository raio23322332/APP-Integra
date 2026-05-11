// services/solicitacao/solicitacao_payload.dart
class SolicitacaoPayload {
  static Map<String, String> criar({
    required String serviceSlug, //  Alterado para service_slug obrigatório
    required String descricao,
    required int userId, // Enviado como user_id para compatibilidade com API
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
  }) {
    final payload = <String, String>{
      'service_slug': serviceSlug, //  Campo obrigatório que a API espera
      'descricao': descricao,
      'user_id': userId.toString(), //  Incluindo user_id obrigatório
      'privacidade': privacidade.toString(),
    };

    void add(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        payload[key] = value;
      }
    }

    add('observacao', observacao);
    add('latitude', latitude);
    add('longitude', longitude);
    add('cep', cep);
    add('logradouro', logradouro);
    add('numero', numero);
    add('bairro', bairro);
    add('cidade', cidade);
    add('estado', _normalizarEstado(estado));

    return payload;
  }

  static String? _normalizarEstado(String? estado) {
    if (estado == null || estado.isEmpty) return null;
    return estado.length > 2
        ? estado.substring(0, 2).toUpperCase()
        : estado.toUpperCase();
  }
}

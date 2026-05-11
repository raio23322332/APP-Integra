// services/solicitacao/solicitacao_validator.dart
class SolicitacaoValidator {
  static Map<String, dynamic> validarCriacao({
    required String serviceSlug, 
    required int userId,
  }) {
    if (serviceSlug.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Service slug é obrigatório.',
      };
    }

    if (userId <= 0) {
      return {'success': false, 'message': 'Usuário não autenticado.'};
    }

    return {'success': true};
  }
}

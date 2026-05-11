// lib/core/errors/tenant_errors.dart
// 🎯 MVVM: Tratamento de Erros Tipados
// Permite tratamento específico baseado no tipo de erro

/// Classe base para erros relacionados a tenants
class TenantError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const TenantError(this.message, {this.code, this.originalError});

  @override
  String toString() => 'TenantError: $message${code != null ? ' ($code)' : ''}';
}

/// Erro de rede/conectividade
class NetworkError extends TenantError {
  const NetworkError([String message = 'Erro de conexão'])
      : super(message, code: 'NETWORK_ERROR');
}

/// Erro de timeout
class TimeoutError extends TenantError {
  const TimeoutError([String message = 'Tempo limite excedido'])
      : super(message, code: 'TIMEOUT_ERROR');
}

/// Erro do servidor (5xx)
class ServerError extends TenantError {
  const ServerError([String message = 'Erro do servidor'])
      : super(message, code: 'SERVER_ERROR');
}

/// Erro de validação de dados
class ValidationError extends TenantError {
  const ValidationError([String message = 'Dados inválidos'])
      : super(message, code: 'VALIDATION_ERROR');
}

/// Erro desconhecido/não categorizado
class UnknownError extends TenantError {
  UnknownError(dynamic error)
      : super('Erro desconhecido: ${error.toString()}', code: 'UNKNOWN_ERROR', originalError: error);
}

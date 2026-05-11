// lib/domain/contracts/logout_service.dart

/// Contrato abstrato para serviço de logout
/// Melhora o isolamento do ViewModel permitindo injeção de dependências
abstract class LogoutService {
  Future<void> logout();
}

// lib/domain/usecases/auth/register_usecase.dart

import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<RegisterResult> execute({
    required Tenant tenant,
    required String name,
    required String email,
    required String password,
    String cpf = '',
    String phone = '',
  }) async {
    try {
      await _repository.register(
        tenant: tenant,
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
      );

      return const RegisterResult.success();
    } catch (e) {
      String errorMessage = e.toString();
      
      // Remover "Exception:" ou "exception:" da mensagem
      if (errorMessage.toLowerCase().startsWith('exception:')) {
        errorMessage = errorMessage.substring(10).trim();
      }
      
      return RegisterResult.failure(errorMessage);
    }
  }
}

class RegisterResult {
  final bool success;
  final String? error;

  const RegisterResult.success()
      : success = true,
        error = null;

  const RegisterResult.failure(this.error)
      : success = false;
}

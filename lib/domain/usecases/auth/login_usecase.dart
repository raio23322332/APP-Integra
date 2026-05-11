// lib/domain/usecases/auth/login_usecase.dart

import 'package:flutter/foundation.dart';
import 'package:integra_app/data/models/user_model.dart';
import 'package:integra_app/domain/services/login_authentication_service.dart';


/// Use Case para lógica de negócio de login
/// Segue diretrizes MVVM: encapsula regras de negócio
class LoginUseCase {
  final LoginAuthenticationService _authenticationService;

  LoginUseCase(this._authenticationService);

  /// Executa o fluxo completo de login
  /// Retorna resultado estruturado com sucesso/erro
  Future<LoginResult> execute({
    required String email,
    required String password,
    required dynamic tenant,
  }) async {
    print('🎯 LoginUseCase.execute: INÍCIO - email=$email');
    debugPrint('🔍 LoginUseCase.execute: INÍCIO - email=$email');
    
    // ✅ MVVM: Lógica de negócio encapsulada no Use Case
    print('🔄 LoginUseCase: Chamando _authenticationService.authenticate...');
    final result = await _authenticationService.authenticate(
      tenant: tenant,
      email: email,
      password: password,
    );

    print('📊 LoginUseCase: Resultado success=${result.success} error=${result.error}');
    debugPrint('🔍 LoginUseCase: Resultado success=${result.success} error=${result.error}');

    return LoginResult(
      success: result.success,
      message: result.message,
      error: result.error,
      type: result.type,
      user: result.user, // Adicionar user
    );
  }
}

/// Resultado estruturado do login
/// Facilita tratamento de sucesso/erro na UI
class LoginResult {
  final bool success;
  final String? message;
  final String? error;
  final AuthType? type;
  final User? user;

  const LoginResult({
    required this.success,
    this.message,
    this.error,
    this.type,
    this.user,
  });

  bool get hasError => error != null && error!.isNotEmpty;
}

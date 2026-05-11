import 'package:flutter/material.dart';

import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class LoginStatusWidget extends StatefulWidget {
  const LoginStatusWidget({super.key});

  @override
  State<LoginStatusWidget> createState() => _LoginStatusWidgetState();
}

class _LoginStatusWidgetState extends State<LoginStatusWidget> {
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.isAuthenticated) {
      // 🔹 Mostra apenas o ícone de sair
      return IconButton(
        onPressed: _isLoggingOut ? null : _handleLogout,
        icon: _isLoggingOut
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout, color: Color(0xFF1F2D3D), size: 24),
        tooltip: 'Sair',
      );
    } else {
      // 🔹 Botão de "Entrar" desativado (comentado)
      return const SizedBox(); // Não mostra nada quando não estiver logado
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

    // Mostrar diálogo de confirmação
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Sair da Conta',
      message: 'Tem certeza que deseja sair da sua conta?',
      warningText: 'Você precisará fazer login novamente para acessar o aplicativo.',
      icon: Icons.exit_to_app,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red,
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
      confirmColor: Colors.red,
    );

    // Se o usuário confirmou, prossegue com o logout
    if (confirmed == true) {
      setState(() => _isLoggingOut = true);

      try {
        // Aguarda o logout remoto/local
        await context.read<AuthViewModel>().logout();

        // Só navega se o widget ainda estiver montado
        if (mounted) {
          NavigationService.instance.navigateTo('/login');
        }
      } catch (e) {
        debugPrint('Erro durante logout: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoggingOut = false);
        }
      }
    }
  }
}

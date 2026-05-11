import 'package:flutter/material.dart';
import 'confirmation_dialog.dart';

/// Exemplo de como implementar logout com confirmação
class LogoutExample extends StatelessWidget {
  const LogoutExample({super.key});

  Future<void> _handleLogout(BuildContext context) async {
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
      // Aqui vai a lógica de logout
      print('Usuário confirmou logout');
      
      // Exemplo de navegação após logout
      // Navigator.of(context).pushReplacementNamed('/login');
      // context.go('/login');
      // NavigationService.instance.navigateTo('/login');
    } else {
      // Usuário cancelou - não faz nada
      print('Usuário cancelou logout');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exemplo de Logout')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Exemplo de implementação de logout com confirmação',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da Conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de exemplo para testar diferentes tipos de diálogos
class DialogTestScreen extends StatelessWidget {
  const DialogTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste de Diálogos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Diálogo de Logout
            ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context: context,
                  title: 'Sair da Conta',
                  message: 'Tem certeza que deseja sair?',
                  warningText: 'Você precisará fazer login novamente.',
                  icon: Icons.exit_to_app,
                  iconColor: Colors.red,
                  confirmText: 'Confirmar',
                  cancelText: 'Cancelar',
                  confirmColor: Colors.red,
                );
                print('Logout: $confirmed');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Testar Logout'),
            ),
            
            const SizedBox(height: 16),
            
            // Diálogo de Exclusão
            ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context: context,
                  title: 'Excluir Item',
                  message: 'Tem certeza que deseja excluir este item?',
                  detailText: 'Este é um item importante que será removido permanentemente.',
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  confirmColor: Colors.red,
                );
                print('Excluir: $confirmed');
              },
              icon: const Icon(Icons.delete),
              label: const Text('Testar Exclusão'),
            ),
            
            const SizedBox(height: 16),
            
            // Diálogo de Confirmação
            ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context: context,
                  title: 'Salvar Alterações',
                  message: 'Deseja salvar as alterações feitas?',
                  icon: Icons.save,
                  iconColor: Colors.blue,
                  confirmColor: Colors.blue,
                  showWarning: false,
                );
                print('Salvar: $confirmed');
              },
              icon: const Icon(Icons.save),
              label: const Text('Testar Confirmação'),
            ),
            
            const SizedBox(height: 16),
            
            // Diálogo de Aviso
            ElevatedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context: context,
                  title: 'Atenção',
                  message: 'Esta ação afetará outros dados relacionados.',
                  warningText: 'Verifique todas as informações antes de continuar.',
                  icon: Icons.warning_rounded,
                  iconColor: Colors.orange,
                  confirmColor: Colors.orange,
                );
                print('Aviso: $confirmed');
              },
              icon: const Icon(Icons.warning),
              label: const Text('Testar Aviso'),
            ),
          ],
        ),
      ),
    );
  }
}

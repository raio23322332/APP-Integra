import 'package:flutter/material.dart';
import 'package:integra_app/data/models/user_model.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/user_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega os usuários ao iniciar a tela, se o usuário tiver permissão
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.hasPermission('manage-users')) {
        Provider.of<UserViewModel>(context, listen: false).fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    // Verifica se o usuário tem a permissão necessária para acessar a tela
    // Assumindo que a permissão para gerenciar usuários é 'manage-users'
    if (!authViewModel.hasPermission('manage-users')) {
      // Se não tiver permissão, exibe uma tela de erro ou redireciona
      return Scaffold(
        appBar: AppBar(title: const Text('Gerenciamento de Usuários')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Acesso negado.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Você não tem permissão para gerenciar usuários.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                child: const Text('Voltar para a Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implementar tela de criação de usuário
              CustomSnackBar.showInfo(context, 'Funcionalidade de criação de usuário em desenvolvimento.');
            },
          ),
        ],
      ),
      body: userViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userViewModel.errorMessage != null
              ? Center(child: Text('Erro: ${userViewModel.errorMessage}'))
              : RefreshIndicator(
                  onRefresh: userViewModel.fetchUsers,
                  child: ListView.builder(
                    itemCount: userViewModel.users.length,
                    itemBuilder: (context, index) {
                      final user = userViewModel.users[index];
                      return _buildUserTile(context, user, userViewModel);
                    },
                  ),
                ),
    );
  }

  Widget _buildUserTile(BuildContext context, User user, UserViewModel userViewModel) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(FontAwesomeIcons.user),
      ),
      title: Text(user.name ?? user.email),
      subtitle: Text('Email: ${user.email}\nRoles: ${user.roles.join(', ')}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // TODO: Implementar tela de edição de usuário
              CustomSnackBar.showInfo(context, 'Funcionalidade de edição de usuário em desenvolvimento.');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context, user, userViewModel),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  void _confirmDelete(BuildContext context, User user, UserViewModel userViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o usuário ${user.name ?? user.email}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                context.pop();
                final success = await userViewModel.deleteUser(user.id!);
                if (success) {
                  CustomSnackBar.showSuccess(context, 'Usuário excluído com sucesso!');
                } else {
                  CustomSnackBar.showError(context, userViewModel.errorMessage ?? 'Falha ao excluir usuário.');
                }
              },
            ),
          ],
        );
      },
    );
  }
}

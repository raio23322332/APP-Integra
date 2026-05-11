import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/tenant_model.dart';
import '../../../widgets/buttons/custom_login_button.dart';
import '../../../widgets/fields/custom_email_field.dart';
import '../../../widgets/fields/custom_password_field.dart';
import '../../../widgets/fields/custom_name_field.dart';
import '../../../widgets/dialogs/confirmation_dialog.dart';
import '../../viewmodels/profile/profile_viewmodel.dart' show ProfileViewModel;
import '../../widgets/shared/custom_snack_bar.dart';
import '../../widgets/shared/view_model_event.dart';
import '../../../services/navigation_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';

// ✅ MVVM: View puramente declarativa com ViewModel próprio
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ MVVM: Usa Provider global de forma simplificada
    return const _ProfileView();
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  StreamSubscription? _eventSubscription;

  // Constantes de cor
  static const Color primaryBlue = Color(0xFF28669b);
  static const Color highlightTeal = Color(0xFF248e95);
  static const Color textDark = Color(0xFF263860);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ProfileViewModel>();
      _eventSubscription = viewModel.events.listen(_handleEvent);
      
      // Força atualização dos dados quando a tela é construída
      print('🔄 ProfileScreen: Forçando atualização de dados do usuário');
      viewModel.authViewModel.loadCurrentUser();
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  // ✅ MVVM: Handler centralizado de eventos
  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    switch (event) {
      case NavigateToLoginEvent():
        // ✅ Navegação via GoRouter (única responsabilidade da View)
        context.go(AppRoutes.login);
        break;
      case ShowSnackBarEvent():
        // Feedback para usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message),
            backgroundColor: event.isError ? Colors.red : Colors.green,
          ),
        );
        break;
      default:
        debugPrint('Evento não tratado: ${event.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ MVVM: Consumer para reatividade
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final user = viewModel.currentUser;
        print('🔄 ProfileScreen: Build chamado - Usuário: ${user?.toString()}');

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.go(AppRoutes.home);
          },
          child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: const Text('Meu Perfil'),
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            automaticallyImplyLeading:false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildUserInfo(user),
                const Divider(),
                _buildProfileOption(
                  context,
                  icon: FontAwesomeIcons.fileContract,
                  title: 'Meus Protocolos',
                  subtitle: 'Acompanhe e gerencie seus protocolos.',
                  onTap: () => context.push('/protocolos'),
                ),
                // Botão de Setores comentado - não aparece para usuários
                // _buildProfileOption(
                //   context,
                //   icon: FontAwesomeIcons.building,
                //   title: 'Setores',
                //   subtitle: 'Gerencie os setores do sistema.',
                //   onTap: () => context.push('/setores'),
                // ),
                const Divider(),
                _buildProfileOption(
                  context,
                  icon: FontAwesomeIcons.userPen,
                  title: 'Editar Dados Cadastrais',
                  subtitle: 'Atualize seu e-mail, telefone ou endereço.',
                  onTap: viewModel.navigateToProfileEdit, // ✅ Delega para ViewModel
                ),
                _buildProfileOption(
                  context,
                  icon: FontAwesomeIcons.shieldHalved,
                  title: 'Segurança e Senha',
                  subtitle: 'Altere sua senha e gerencie a segurança da conta.',
                  onTap: viewModel.navigateToSecuritySettings, // ✅ Delega para ViewModel
                ),
                const Divider(),
                _buildLogoutButton(context, viewModel),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(User? user) {
    print(' ProfileScreen: _buildUserInfo chamado com usuário: ${user?.toString()}');
    
    // Função para formatar nome com iniciais maiúsculas
    String formatName(String? name) {
      if (name == null || name.isEmpty) return 'Usuário Não Logado';
      
      final parts = name.trim().toLowerCase().split(' ');
      final formattedParts = parts.map((part) {
        if (part.isNotEmpty) {
          return part[0].toUpperCase() + part.substring(1);
        }
        return part;
      }).join(' ');
      
      return formattedParts;
    }

    // Função para extrair iniciais do nome (para o avatar)
    String getInitials(String? name) {
      if (name == null || name.isEmpty) return 'U';
      
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.length == 1) {
        return parts[0].substring(0, 1).toUpperCase();
      }
      return 'U';
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: highlightTeal,
            child: Text(
              getInitials(user?.name),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            formatName(user?.name),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Faça login para ver seus dados.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          
        ],
      ),
    );
  }



  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryBlue, size: 24),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textDark),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(FontAwesomeIcons.chevronRight, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton.icon(
        onPressed: () async {
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
          
          if (confirmed == true) {
            viewModel.logout();
          }
        },
        icon: const Icon(FontAwesomeIcons.rightFromBracket),
        label: const Text('Sair da Conta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

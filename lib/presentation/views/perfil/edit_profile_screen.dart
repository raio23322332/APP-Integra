import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/buttons/custom_login_button.dart';
import '../../../widgets/fields/custom_name_field.dart';
import '../../../widgets/fields/custom_email_field.dart';
import '../../../widgets/dialogs/password_confirmation_dialog.dart';
import '../../widgets/shared/custom_snack_bar.dart';
import '../../viewmodels/profile/edit_profile_viewmodel.dart';
import '../../widgets/shared/view_model_event.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EditProfileView(
      key: ValueKey('edit_profile_view'),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView({super.key});

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  StreamSubscription? _eventSubscription;
  late TextEditingController _emailController; // Controller local para o email

  // Constantes de cor
  static const Color primaryBlue = Color(0xFF28669b);
  static const Color highlightTeal = Color(0xFF248e95);
  static const Color textDark = Color(0xFF263860);
  static const Color dangerRed = Color(0xFFDC3545);

  @override
  void initState() {
    super.initState();
    
    // Inicializa o controller com valor vazio temporariamente
    _emailController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<EditProfileViewModel>();
      _eventSubscription = viewModel.events.listen(_handleEvent);
      
      // Atualiza o controller com o valor atual do usuário
      _emailController.text = viewModel.emailController.text;
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _emailController.dispose(); // Dispose do controller local
    super.dispose();
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    switch (event) {
      case ShowSnackBarEvent():
        if (mounted) {
          if (event.isError) {
            CustomSnackBar.showError(context, event.message);
          } else {
            CustomSnackBar.showSuccess(context, event.message);
          }
        }
        break;
      case ShowNoInternetDialogEvent():
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(event.message ?? 'Sem conexão com a internet. Verifique sua conexão e tente novamente.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        break;
      case NavigationEvent():
        if (mounted) {
          if (event.route == '/profile' || event.route == '/secondary-profile') {
            // Usa GoRouter para navegar para a tela de perfil
            context.go('/secondary-profile');
          } else {
            // Para outras rotas, usa comportamento padrão
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          }
        }
        break;
      case NavigateToLoginEvent():
        if (mounted) {
          context.go('/login');
        }
        break;
      default:
        debugPrint('Evento não tratado: ${event.runtimeType}');
    }
  }

  Future<void> _handleUpdateProfile() async {
    final viewModel = context.read<EditProfileViewModel>();
    
    // Sincroniza o valor do e-mail do controller local com o viewModel
    viewModel.emailController.text = _emailController.text;
    
    // Validações manuais
    if (viewModel.nameController.text.trim().isEmpty) {
      _showError('Por favor, digite seu nome');
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      _showError('Por favor, digite seu e-mail');
      return;
    }
    
    // Validação básica de e-mail
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Por favor, digite um e-mail válido');
      return;
    }

    // Se passou todas as validações, atualiza o perfil
    await viewModel.updateProfile();
  }

  Future<void> _handleDeleteAccount() async {
    final viewModel = context.read<EditProfileViewModel>();
    
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PasswordConfirmationDialog(
          title: 'Excluir Conta',
          message: 'Para excluir sua conta, precisamos confirmar sua identidade.',
          warningText: 'Esta ação não pode ser desfeita. Todos os seus dados serão permanentemente removidos.',
          confirmText: 'Excluir Conta',
          cancelText: 'Cancelar',
          onConfirm: () {}, // Será chamado internamente
          onCancel: () {}, // Será chamado internamente
        );
      },
    );
    
    if (password != null && password.isNotEmpty) {
      await viewModel.deleteAccount(password: password);
    }
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        // Verifica se o usuário mudou e atualiza os controllers se necessário
        final lastUserId = viewModel.lastUserId;
        viewModel.checkAndUpdateControllersIfNeeded();
        
        // Se o usuário mudou, força um rebuild da tela
        if (lastUserId != viewModel.lastUserId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
        
        // Sincroniza o controller local de email com o viewModel
        _emailController.text = viewModel.emailController.text;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: const Text('Editar Perfil'),
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 30),
                _buildProfileForm(viewModel),
                const SizedBox(height: 30),
                _buildUpdateButton(viewModel),
                const SizedBox(height: 20),
                _buildDeleteAccountButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          FontAwesomeIcons.userPen,
          size: 48,
          color: highlightTeal,
        ),
        const SizedBox(height: 16),
        Text(
          'Editar Dados Cadastrais',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Atualize suas informações pessoais mantendo seus dados sempre em dia.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(EditProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados Pessoais',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 20),
        CustomNameField(
          controller: viewModel.nameController,
          labelText: 'Nome Completo',
          hintText: 'Digite seu nome completo',
          onChanged: (value) {}, // Campo obrigatório mas não usado
        ),
        const SizedBox(height: 16),
        CustomEmailField(
          controller: _emailController,
          hintText: 'Digite seu e-mail',
          onChanged: (value) {
            _emailController.text = value;
          },
        ),
      ],
    );
  }

  Widget _buildUpdateButton(EditProfileViewModel viewModel) {
    return CustomLoginButton(
      text: viewModel.isLoading ? 'Atualizando...' : 'Salvar Alterações',
      onPressed: viewModel.isLoading ? null : _handleUpdateProfile,
      isLoading: viewModel.isLoading,
    );
  }

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleDeleteAccount,
        icon: const Icon(FontAwesomeIcons.trash, size: 20),
        label: const Text('Excluir Conta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: dangerRed,
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

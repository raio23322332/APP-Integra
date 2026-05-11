import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../widgets/buttons/custom_login_button.dart';
import '../../../widgets/fields/custom_password_field.dart';
import '../../widgets/shared/custom_snack_bar.dart';
import '../../viewmodels/profile/security_viewmodel.dart';
import '../../widgets/shared/view_model_event.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SecurityViewModel>(
      create: (context) => SecurityViewModel(),
      child: const _SecurityView(),
    );
  }
}

class _SecurityView extends StatefulWidget {
  const _SecurityView();

  @override
  State<_SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<_SecurityView> {
  StreamSubscription? _eventSubscription;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Estados para visibilidade das senhas
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  bool _isLoading = false;

  // Constantes de cor
  static const Color primaryBlue = Color(0xFF28669b);
  static const Color highlightTeal = Color(0xFF248e95);
  static const Color textDark = Color(0xFF263860);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<SecurityViewModel>();
      _eventSubscription = viewModel.events.listen(_handleEvent);
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

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
      case NavigateBackEvent():
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        break;
      default:
        debugPrint('Evento não tratado: ${event.runtimeType}');
    }
  }

  Future<void> _handlePasswordUpdate() async {
    // Validações manuais
    if (_currentPasswordController.text.isEmpty) {
      _showError('Por favor, digite sua senha atual');
      return;
    }
    
    if (_newPasswordController.text.isEmpty) {
      _showError('Por favor, digite sua nova senha');
      return;
    }
    
    if (_newPasswordController.text.length < 8) {
      _showError('A senha deve ter pelo menos 8 caracteres');
      return;
    }
    
    if (_confirmPasswordController.text.isEmpty) {
      _showError('Por favor, confirme sua nova senha');
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('As senhas não coincidem');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final viewModel = context.read<SecurityViewModel>();
    await viewModel.updatePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
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
    return Consumer<SecurityViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: const Text('Segurança e Senha'),
            foregroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              tooltip: 'Voltar',
              padding: EdgeInsets.zero,
              splashRadius: 20,
              onPressed: () => Navigator.of(context).pop(),
            ),
            titleSpacing: -16,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primaryBlue,
                    Color(0xFF4A90E2),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSecurityHeader(),
                  const SizedBox(height: 30),
                  _buildPasswordForm(),
                  const SizedBox(height: 30),
                  _buildSecurityTips(),
                  const SizedBox(height: 30),
                  _buildUpdateButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          FontAwesomeIcons.shieldHalved,
          size: 48,
          color: highlightTeal,
        ),
        const SizedBox(height: 16),
        Text(
          'Alterar Senha',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mantenha sua conta segura atualizando regularmente sua senha.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados da Senha',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 20),
        CustomPasswordField(
          controller: _currentPasswordController,
          labelText: 'Senha Atual',
          hintText: 'Digite sua senha atual',
          obscureText: _obscureCurrentPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomPasswordField(
          controller: _newPasswordController,
          labelText: 'Nova Senha',
          hintText: 'Digite sua nova senha',
          obscureText: _obscureNewPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
        const SizedBox(height: 16),
        CustomPasswordField(
          controller: _confirmPasswordController,
          labelText: 'Confirmar Nova Senha',
          hintText: 'Confirme sua nova senha',
          obscureText: _obscureConfirmPassword,
          onToggleVisibility: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.lightbulb,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dicas de Segurança',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            '• Use pelo menos 8 caracteres',
            '• Combine letras maiúsculas e minúsculas',
            '• Inclua números e caracteres especiais',
            '• Evite informações pessoais óbvias',
            '• Não reutilize senhas de outros serviços',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              tip,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.blue.shade700,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return CustomLoginButton(
      text: _isLoading ? 'Atualizando...' : 'Atualizar Senha',
      onPressed: _isLoading ? null : _handlePasswordUpdate,
      isLoading: _isLoading,
    );
  }
}

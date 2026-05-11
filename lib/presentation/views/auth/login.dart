import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/flavor_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/tenant_model.dart';
import '../../../widgets/buttons/custom_login_button.dart';
import '../../../widgets/fields/custom_email_field.dart';
import '../../../widgets/fields/custom_password_field.dart';
import '../../viewmodels/auth/login_viewmodel.dart' show LoginViewModel;
import '../../widgets/shared/custom_snack_bar.dart';
import '../../widgets/shared/view_model_event.dart';
import '../../../services/navigation_service.dart';
import '../../widgets/shared/webview_page.dart';

class LoginPage extends StatefulWidget {
  final Tenant tenant;
  const LoginPage({super.key, required this.tenant});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  StreamSubscription? _eventSubscription;
  String get _tenantName {
    final descricao = widget.tenant.descricao;
    if (descricao != null && descricao.trim().isNotEmpty) {
      return "Integra $descricao";
    }
    return widget.tenant.id.toUpperCase();
  }

  // Constrói a URL para "Esqueceu a senha" baseada no tenant
  String _buildForgotPasswordUrl() {
    // Usa o domínio de desenvolvimento se disponível, senão usa o domínio primário
    final domain = widget.tenant.devDomain ?? widget.tenant.primaryDomain;

    if (domain != null) {
      // Constrói URL no padrão: tenant.urlbase/forgot-password
      return 'https://$domain/forgot-password';
    }

    // Fallback: não faz nada se não tiver domínio
    return '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<LoginViewModel>();
      viewModel.initialize(widget.tenant);
      _eventSubscription = viewModel.events.listen(_handleEvent);
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;
    switch (event) {
      case ShowSnackBarEvent():
        if (event.isError) {
          CustomSnackBar.showError(context, event.message);
        }
        break;
      default:
        break;
    }
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      key: const Key('login_error_message'),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      key: const Key('login_consumer'),
      builder: (context, viewModel, child) {
        return Scaffold(
          key: const Key('login_scaffold'),
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              key: const Key('login_body_padding'),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                key: const Key('login_main_column'),
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('login_back_button'),
                      onPressed: () => NavigationService.instance.goBack(),
                      icon: const Icon(Icons.arrow_back,
                          size: 16, color: Colors.grey),
                      label: Text(
                        'Alterar município',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                    SizedBox(height:  MediaQuery.sizeOf(context).height * 0.9 * 0.05),
                  SizedBox(
                    key: const Key('login_logo_container'),
                    // height: MediaQuery.sizeOf(context).height * 0.26,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 92,
                          height: 92,
                          child: Image.asset(
                            FlavorConfig.logoAsset,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          _tenantName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightPrimaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Acesse sua conta',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 12),
                  Container(
                    key: const Key('login_divider'),
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.authPrimary,
                          AppColors.secondaryGreen,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    key: const Key('login_instructions'),
                    'Entre com suas credenciais para continuar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.getFieldError('general') != null)
                    _buildErrorMessage(viewModel.getFieldError('general')!),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const Key('login_form_scroll'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomEmailField(
                            key: const Key('login_email_field'),
                            errorText: viewModel.getFieldError('email'),
                            onChanged: viewModel.updateEmail,
                          ),
                          const SizedBox(height: 20),
                          CustomPasswordField(
                            key: const Key('login_password_field'),
                            obscureText: viewModel.obscurePassword,
                            onToggleVisibility:
                                viewModel.togglePasswordVisibility,
                            errorText: viewModel.getFieldError('password'),
                            onChanged: viewModel.updatePassword,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              key: const Key('login_forgot_password_button'),
                              onPressed: () {
                                final forgotPasswordUrl =
                                    _buildForgotPasswordUrl();
                                if (forgotPasswordUrl.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebViewPage(
                                        url: forgotPasswordUrl,
                                        title: 'Esqueceu a senha',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Esqueceu a senha?',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.lightSecondaryText
                                      .withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          CustomLoginButton(
                            key: const Key('login_submit_button'),
                            onPressed: viewModel.isLoading
                                ? null
                                : () => _onLoginPressed(viewModel),
                            isLoading: viewModel.isLoading,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            key: const Key('login_register_prompt'),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'Ainda não tem uma conta? ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Center(
                                child: TextButton(
                                  key: const Key('login_register_button'),
                                  onPressed: viewModel.navigateToRegister,
                                  child: Text(
                                    'Criar conta agora',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.authText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onLoginPressed(LoginViewModel viewModel) {
    FocusManager.instance.primaryFocus?.unfocus();
    viewModel.performLogin();
  }
}

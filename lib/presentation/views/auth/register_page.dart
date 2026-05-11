import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/flavor_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/tenant_model.dart';
import '../../../services/navigation_service.dart';
import '../../../widgets/buttons/custom_login_button.dart';
import '../../../widgets/fields/custom_confirm_password_field.dart';
import '../../../widgets/fields/custom_email_field.dart';
import '../../../widgets/fields/custom_name_field.dart';
import '../../../widgets/fields/custom_password_field.dart';
import '../../viewmodels/register_viewmodel.dart';
import '../../widgets/shared/custom_snack_bar.dart';
import '../../widgets/shared/view_model_event.dart';
class RegisterPage extends StatefulWidget {
  final Tenant tenant;
  const RegisterPage({
    super.key,
    required this.tenant,
  });
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  StreamSubscription? _eventSubscription;
  String get _tenantName {
    final descricao = widget.tenant.descricao;
    if (descricao != null && descricao.trim().isNotEmpty) {
      return "Integra $descricao";
    }
    return widget.tenant.id.toUpperCase();
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<RegisterViewModel>();
      viewModel.initialize(widget.tenant);
      _eventSubscription ??= viewModel.events.listen(_handleEvent);
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
        event.isError
            ? CustomSnackBar.showError(context, event.message)
            : CustomSnackBar.showSuccess(context, event.message);
        break;
      default:
        break;
    }
  }
  void _onRegisterPressed(RegisterViewModel viewModel) {
    FocusManager.instance.primaryFocus?.unfocus();
    viewModel.performRegister();
  }
  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => NavigationService.instance.goBack(),
            icon: const Icon(
              Icons.arrow_back,
              size: 16,
              color: Colors.grey,
            ),
            label: Text(
              'Voltar para login',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        Column(
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
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.authText,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'Crie sua conta',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.authText,
              ),
            ),
          ],
        ),
        Container(
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
        const SizedBox(height: 8),
        Text(
          'Preencha os dados abaixo para criar sua conta',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  Widget _buildForm(RegisterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (viewModel.getFieldError('general') != null)
          _buildErrorMessage(viewModel.getFieldError('general')!),
        CustomNameField(
          errorText: viewModel.getFieldError('name'),
          onChanged: viewModel.updateName,
          hintText: 'Digite seu nome completo',
          labelText: 'Nome completo',
        ),
        const SizedBox(height: 14),
        CustomEmailField(
          errorText: viewModel.getFieldError('email'),
          onChanged: viewModel.updateEmail,
        ),
        const SizedBox(height: 14),
        CustomPasswordField(
          obscureText: viewModel.obscurePassword,
          onToggleVisibility: viewModel.togglePasswordVisibility,
          errorText: viewModel.getFieldError('password'),
          onChanged: viewModel.updatePassword,
          labelText: 'Senha',
          hintText: 'Digite sua senha',
        ),
        const SizedBox(height: 14),
        CustomConfirmPasswordField(
          obscureText: viewModel.obscurePasswordConfirmation,
          onToggleVisibility: viewModel.togglePasswordConfirmationVisibility,
          errorText: viewModel.getFieldError('password_confirmation'),
          onChanged: viewModel.updatePasswordConfirmation,
        ),
        const SizedBox(height: 22),
        CustomLoginButton(
          onPressed:
              viewModel.isLoading ? null : () => _onRegisterPressed(viewModel),
          isLoading: viewModel.isLoading,
          text: 'Criar conta',
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Já tem uma conta?',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: viewModel.isLoading ? null : viewModel.navigateToLogin,
            child: Text(
              'Faça login agora',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.authText,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildForm(viewModel),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

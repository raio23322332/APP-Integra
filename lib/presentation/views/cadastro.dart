import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/domain/usecases/auth/register_usecase.dart';
import 'package:integra_app/domain/repositories/auth_repository_impl.dart';
import 'package:integra_app/data/datasources/auth_remote_datasource_impl.dart';
import 'package:integra_app/data/datasources/local/auth_local_datasource_impl.dart';
import 'package:integra_app/services/storage/domain_storage.dart';

import 'package:integra_app/presentation/viewmodels/cadastro_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:provider/provider.dart';


import '../routes/app_router.dart';

class CadastroPage extends StatelessWidget {
  final Tenant tenant;
  const CadastroPage({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CadastroViewModel(
        registerUseCase: RegisterUseCase(AuthRepositoryImpl(
          remoteDataSource: AuthRemoteDataSourceImpl(client: http.Client()),
          localDataSource: AuthLocalDataSourceImpl(context.read<DomainStorage>()),
        )),
        authViewModel: context.read<AuthViewModel>(),
      ),
      child: CriarContaScreen(tenant: tenant),
    );
  }
}

class CriarContaScreen extends StatefulWidget {
  final Tenant tenant;
  const CriarContaScreen({super.key, required this.tenant});

  @override
  State<CriarContaScreen> createState() => _CriarContaScreenState();
}

class _CriarContaScreenState extends State<CriarContaScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  StreamSubscription? _eventSub;

  @override
  void initState() {
    super.initState();

    // ✅ Escuta eventos do ViewModel (SnackBar / Navegação)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CadastroViewModel>();
      _eventSub = vm.events.listen(_handleVmEvent);
    });
  }

  void _handleVmEvent(ViewModelEvent event) async {
    if (!mounted) return;

    if (event is ShowSnackBarEvent) {
      if (event.isError) {
        CustomSnackBar.showError(context, event.message);
      } else {
        CustomSnackBar.showSuccess(context, event.message);
      }
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    nomeController.dispose();
    cpfController.dispose();
    celularController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(CadastroViewModel viewModel) async {
    final formIsValid = _formKey.currentState?.validate() ?? false;

    await viewModel.submit(
      tenant: widget.tenant,
      formIsValid: formIsValid,
      email: emailController.text.trim(),
      password: senhaController.text,
      name: nomeController.text.trim(),
      cpf: cpfController.text.trim(),
      phone: celularController.text.trim(),
    );
  }

  Widget _buildInput({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            onChanged: onChanged,
            obscureText: isPassword ? !isVisible : false,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[700],
                      ),
                      onPressed: onToggle,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRule(String text, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel,
            color: ok ? AppColors.primaryBlue : AppColors.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: ok ? Colors.black87 : AppColors.error,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CadastroViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            title: const Text(
              'Criar Conta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                          _buildInput(
                            label: 'Nome',
                            placeholder: 'Digite seu nome completo',
                            controller: nomeController,
                            validator: viewModel.validateName,
                          ),

                          _buildInput(
                            label: 'CPF',
                            placeholder: 'Digite seu CPF',
                            controller: cpfController,
                            keyboardType: TextInputType.number,
                            validator: viewModel.validateCpf,
                          ),

                          _buildInput(
                            label: 'Celular',
                            placeholder: 'Digite seu celular',
                            controller: celularController,
                            keyboardType: TextInputType.phone,
                            validator: viewModel.validatePhone,
                          ),

                          _buildInput(
                            label: 'E-mail',
                            placeholder: 'Digite seu e-mail',
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: viewModel.validateEmail,
                          ),

                          _buildInput(
                            label: 'Criar Senha',
                            placeholder: 'Digite sua senha',
                            controller: senhaController,
                            isPassword: true,
                            isVisible: _senhaVisivel,
                            onToggle: () => setState(
                              () => _senhaVisivel = !_senhaVisivel,
                            ),
                            onChanged: viewModel.onPasswordChanged,
                            validator: viewModel.validatePassword,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPasswordRule(
                                'Mínimo de 6 caracteres',
                                viewModel.rules.min6,
                              ),
                              _buildPasswordRule(
                                'Letra maiúscula e minúscula',
                                viewModel.rules.upperLower,
                              ),
                              _buildPasswordRule(
                                'Número (0-9)',
                                viewModel.rules.number,
                              ),
                              _buildPasswordRule(
                                'Caractere especial (@, ?, !, #, \$, &)',
                                viewModel.rules.special,
                              ),
                              _buildPasswordRule(
                                'As senhas coincidem',
                                viewModel.rules.match,
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          _buildInput(
                            label: 'Confirmar Senha',
                            placeholder: 'Confirme sua senha',
                            controller: confirmarSenhaController,
                            isPassword: true,
                            isVisible: _confirmarSenhaVisivel,
                            onToggle: () => setState(
                              () => _confirmarSenhaVisivel =
                                  !_confirmarSenhaVisivel,
                            ),
                            onChanged: viewModel.onConfirmPasswordChanged,
                            validator: viewModel.validateConfirmPassword,
                          ),

                          CheckboxListTile(
                            value: viewModel.termsAccepted,
                            onChanged: viewModel.isLoading
                                ? null
                                : (v) => viewModel.setTermsAccepted(v ?? false),
                            title: const Text(
                              'Aceito os Termos de Uso e Aviso de Privacidade',
                              style: TextStyle(fontSize: 14),
                            ),
                            activeColor: AppColors.primaryBlue,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 56, // Altura fixa consistente
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () => _onSubmit(viewModel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                disabledBackgroundColor: Colors.grey.shade400,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: viewModel.isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'CRIANDO...',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'CRIAR CONTA',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        );
      },
    );
  }
}

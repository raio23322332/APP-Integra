import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/viewmodels/veiculos_e_condutores/validar_certidao_viewmodel.dart';
import 'package:provider/provider.dart';

class ValidarCertidaoPage extends StatelessWidget {
  const ValidarCertidaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ValidarCertidaoViewModel(),
      child: Consumer<ValidarCertidaoViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8F6), // background-light
            body: SafeArea(
              child: Column(
                children: [
                 // TOP APPBAR
          // TOP APPBAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF28669B),
                  Color(0xFF3FA9F5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão Voltar
                SizedBox(
                  width: 48,
                  height: 48,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => context.go('/meu-ipva'),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Título
                const Expanded(
                  child: Center(
                    child: Text(
                      "Validar Certidão de Quitação",
                      style: TextStyle(
                        fontFamily: "Public Sans",
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Logo
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.network(
                    "https://lh3.googleusercontent.com/aida-public/AB6AXuAVx6VwOMKD7_xUndWTktvBVkPsY-54YSHOs1silab8Ri7s9oNnN9g4IJf8CoKfaiQ-H6SBqe-Fz5GeR1Fx6XUzmSRO2S2b-t1aZ8uGZybZrGBhmXRKrWpJQnwBcYB1FIJYg1i5POyJ2N8UDlDwLZQJO3QWcKj3YasxptuYenxFcYT13rpu1WOCQqKaWgXtmQVkIaOrG3dS0VUS4Mu-YDhUmOLW6FYjy54MeTRUshT8eAdufkOpQ1CPOgndN0p_G-XtSF2hJQOqUxLO",
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),


                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
                            child: Text(
                              "Meu IPVA > Certidão de Quitação",
                              style: TextStyle(
                                color: Color(0xFF618961),
                                fontSize: 14,
                                fontFamily: "Public Sans",
                              ),
                            ),
                          ),

                          // Headline
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Text(
                              "Valide a certidão de quitação do IPVA do veículo",
                              style: TextStyle(
                                fontFamily: "Public Sans",
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2D3D),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // INPUT: CHASSI
                          _CampoInput(
                            titulo: "Chassi",
                            placeholder: "Digite o chassi do veículo",
                            onChanged: (value) => viewModel.setChassi(value),
                          ),

                          // INPUT: CERTIDÃO DE QUITAÇÃO
                          _CampoInput(
                            titulo: "Certidão de Quitação",
                            placeholder: "Digite o número da certidão de quitação",
                            onChanged: (value) => viewModel.setCertidao(value),
                          ),

                          const SizedBox(height: 16),

                          // BOTÃO DESATIVADO
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFE0E0E0), // accent-light
                              ),
                              child: const Center(
                                child: Text(
                                  "Validar certidão",
                                  style: TextStyle(
                                    fontFamily: "Public Sans",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFFA3A3A3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// COMPONENTE DE INPUT
// =====================================================

class _CampoInput extends StatelessWidget {
  final String titulo;
  final String placeholder;
  final Function(String) onChanged;

  const _CampoInput({
    required this.titulo,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontFamily: "Public Sans",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111811),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFDbe6db),
              ),
            ),
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(
                  color: Color(0xFF618961),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF111811),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';

// Cores padrão do módulo Tapa Buraco
const Color primaryBlue = Color(0xFF28669b);
const Color lightBlue = Color(0xFF3FA9F5);

class TapaBuracoPage extends StatelessWidget {
  const TapaBuracoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TapaBuracoScreen();
  }
}

class TapaBuracoScreen extends StatelessWidget {
  const TapaBuracoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      // Volta usando o GoRouter principal
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/'); // ✅ Vai pra tela inicial principal
                      }
                    },
                  ),
                  // Título
                  const Text(
                    'Relatar Buraco',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  // Espaço para alinhamento
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informe o local do buraco',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arraste o marcador ou toque no mapa para informar a localização.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.lightSecondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBorder),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x0D000000),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.map, size: 60, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Localização inválida ou fora da área de cobertura.',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/'); // ✅ volta pra tela inicial real
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.primaryBlue,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Voltar',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Avançar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

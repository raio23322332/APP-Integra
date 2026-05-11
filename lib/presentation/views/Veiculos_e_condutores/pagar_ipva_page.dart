import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/viewmodels/veiculos_e_condutores/pagar_ipva_viewmodel.dart';
import 'package:provider/provider.dart';

class PagarIPVATela extends StatelessWidget {
  const PagarIPVATela({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => PagarIpvaViewModel(),
      child: Consumer<PagarIpvaViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF28669b), Color(0xFF3FA9F5)],
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
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => context.go('/veiculos-e-condutores'),
                        ),
                        const Text(
                          "Pagar IPVA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 40), // Espaçamento para centralizar
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumb
                  const Row(
                    children: [
                      Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      Text(
                        "Meu IPVA",
                        style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      Text(
                        "Pagamento",
                        style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Título
                  Text(
                    "Emita o boleto para pagar o IPVA do veículo",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CAMPO — PLACA
                  _textField(
                    context,
                    label: "Placa",
                    placeholder: "Digite a placa do veículo",
                    onChanged: (value) => viewModel.setPlaca(value),
                  ),
                  // CAMPO — RENAVAM
                  _textField(
                    context,
                    label: "Renavam",
                    placeholder: "Digite o renavam do veículo",
                    onChanged: (value) => viewModel.setRenavam(value),
                  ),
                  const SizedBox(height: 28),
                  // BOTÃO DESABILITADO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: null, // Botão desabilitado
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Continuar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // WIDGET TEXTFIELD
  // ------------------------------------------------------------
  Widget _textField(
    BuildContext context, {
    required String label,
    required String placeholder,
    required Function(String) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[200] : const Color(0xFF111418),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.grey.shade600
                      : const Color(0xFFDBE0E6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

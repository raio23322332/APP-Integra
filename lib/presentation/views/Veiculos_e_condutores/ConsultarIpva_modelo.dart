import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';

class ConsultarIpvaModeloPage extends StatefulWidget {
  const ConsultarIpvaModeloPage({super.key});

  @override
  State<ConsultarIpvaModeloPage> createState() =>
      _ConsultarIpvaModeloPageState();
}

class _ConsultarIpvaModeloPageState extends State<ConsultarIpvaModeloPage> {
  String? modeloSelecionado;
  String? anoSelecionado;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF3F4F6),
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
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const Text(
                    "Consultar IPVA por Modelo",
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
                  "Consulta por Modelo",
                  style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Título
            Text(
              "Consulte o IPVA de acordo com o modelo e o ano do veículo",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightPrimaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Campo modelo
            _DropDownCampo(
              context: context,
              titulo: "Escolha o veículo",
              placeholder: "Selecione o modelo",
              valor: modeloSelecionado,
              itens: const [
                "Fiat Toro",
                "Honda Civic",
                "Toyota Corolla",
                "Jeep Renegade",
              ],
              onChanged: (v) => setState(() => modeloSelecionado = v),
            ),

            // Campo ano
            _DropDownCampo(
              context: context,
              titulo: "Escolha o ano",
              placeholder: "Selecione o ano",
              valor: anoSelecionado,
              itens: const ["2024", "2023", "2022", "2021"],
              onChanged: (v) => setState(() => anoSelecionado = v),
            ),

            const SizedBox(height: 28),

            // Botão Consultar
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
                    "Consultar IPVA",
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
  }
}

// =======================================================================
//                       COMPONENTE DROPDOWN PERSONALIZADO
// =======================================================================

class _DropDownCampo extends StatelessWidget {
  final BuildContext context;
  final String titulo;
  final String placeholder;
  final String? valor;
  final List<String> itens;
  final Function(String?) onChanged;

  const _DropDownCampo({
    required this.context,
    required this.titulo,
    required this.placeholder,
    required this.valor,
    required this.itens,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111418),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey.shade600 : const Color(0xFFDBE0E6),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: valor,
                hint: Text(
                  placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                iconEnabledColor: isDark ? Colors.grey[400] : Colors.grey[600],
                items: itens
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF111418),
                ),
                dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

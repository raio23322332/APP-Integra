import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsultaCnhPage extends StatefulWidget {
  const ConsultaCnhPage({super.key});

  @override
  State<ConsultaCnhPage> createState() => _ConsultaCnhPageState();
}

class _ConsultaCnhPageState extends State<ConsultaCnhPage> {
  final cpfController = TextEditingController();
  final registroController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6),

      // ======= CABEÇALHO =======
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white),
                    onPressed: () => context.go('/'),
                  ),

                  // ======= TÍTULO CENTRAL (SEM ÍCONE) =======
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Consulta CNH',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),

                  // Espaço para balancear o Row
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ),
      ),

      // ======= CONTEÚDO =======
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            const Row(
              children: [
                Icon(Icons.home, color: Color(0xFF2E7D32), size: 20),
                Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                Text(
                  'Consulta CNH',
                  style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Headline
            Text(
              "Acesse informações da CNH",
              style: TextStyle(
                color:
                    isDark ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Consulte sua situação com segurança e rapidez.",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // ======= CAMPOS =======
            _InputField(
              label: "CPF",
              hint: "Digite o número do CPF",
              controller: cpfController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            _InputField(
              label: "Registro da CNH",
              hint: "Digite o registro da CNH",
              controller: registroController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),

            // ======= BOTÃO =======
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final cpf = cpfController.text.trim();
                  final reg = registroController.text.trim();

                  if (cpf.isEmpty || reg.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preencha todos os campos.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Consulta realizada com sucesso!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF137FEC),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: Colors.blueAccent.withOpacity(0.4),
                ),
                child: const Text(
                  "Consultar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======= COMPONENTE DE INPUT =======
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[200] : const Color(0xFF111418),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF111418),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF617589)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.grey.shade600
                    : const Color(0xFFDBE0E6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF137FEC), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

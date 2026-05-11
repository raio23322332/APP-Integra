import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class MulherProteseinfo extends StatelessWidget {
  final List<Map<String, String>> secoes = [
    {
      "titulo": "Informações gerais",
      "conteudo": "Conteúdo da seção de informações gerais aparece aqui.",
    },
    {
      "titulo": "O que é?",
      "conteudo":
          "Casas da Mulher é um espaço de atendimento ás mulheres em situação de violência doméstica e familiar com serviços integrados e humanosizados.",
    },
    {
      "titulo": "Como solicitar?",
      "conteudo": "Conteúdo da seção 'Como solicitar?' aparece aqui.",
    },
    {
      "titulo": "Informações importantes",
      "conteudo": "Conteúdo da seção 'Informações importantes' aparece aqui.",
    },
    {
      "titulo": "Requisitos",
      "conteudo": "Conteúdo da seção 'Requisitos' aparece aqui.",
    },
    {
      "titulo": "Formas de acesso",
      "conteudo": "Conteúdo da seção 'Formas de acesso' aparece aqui.",
    },
    {
      "titulo": "Documentos",
      "conteudo": "Conteúdo da seção 'Documentos' aparece aqui.",
    },
    {"titulo": "Custo", "conteudo": "Conteúdo da seção 'Custo' aparece aqui."},
    {
      "titulo": "Prazo para prestação do serviço",
      "conteudo": "Conteúdo da seção 'Prazo' aparece aqui.",
    },
    {
      "titulo": "Quem pode solicitar?",
      "conteudo": "Conteúdo da seção 'Quem pode solicitar?' aparece aqui.",
    },
    {
      "titulo": "Órgão responsável",
      "conteudo": "Conteúdo da seção 'Órgão responsável' aparece aqui.",
    },
    {
      "titulo": "Unidade responsável",
      "conteudo": "Conteúdo da seção 'Unidade responsável' aparece aqui.",
    },
    {
      "titulo": "Endereço",
      "conteudo": "Conteúdo da seção 'Endereço' aparece aqui.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF28669b), Color(0xFF3FA9F5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.go('/MulherProtese'), // volta pra home
                  
                ),
                const Text(
                  "Mais informações",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    
                  ),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Color(0xFF3F4E63),
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Encontre aqui mais informações sobre o serviço",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),

            child: Text(
              "Última modificação: 05/08/2024",
              style: TextStyle(
                color: isDark ? Colors.green.shade300 : Colors.green.shade700,
                fontWeight: FontWeight.w600,
              
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...secoes.map((secao) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Colors.blue, width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExpansionTile(
                  iconColor: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                  collapsedIconColor: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  title: Text(
                    secao["titulo"]!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        secao["conteudo"]!,
                        style: TextStyle(
                          color: isDark
                              ? const Color.fromARGB(255, 255, 255, 255)
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

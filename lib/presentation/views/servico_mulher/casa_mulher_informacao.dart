import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class CasaMulherInformacao extends StatelessWidget { // ignore: use_key_in_widget_constructors
  final List<Map<String, String>> secoes = [
    {
      "titulo": "O que é?",
      "conteudo":
          "Casas da Mulher é um espaço de atendimento ás mulheres em situação de violência doméstica e familiar com serviços integrados e humaizados.",
    },
    {
      "titulo": "Como solicitar?",
      "conteudo": "Presencial \n 1: Ir a Casa da Mulher Cearense;\nPresencial\n\n 2: Solicitar atendimento aos especialistas"
      "\n Presencial \n\n 3: Receber acolhimento, orientações e serviços disponíveis: psicossocial, jurídico, e outros.",
      
    },
    {
      "titulo": "Informações importantes",
      "conteudo": "Funcionamento 24h da recepção, psicossocial, com psicólogas e assistentes sociais, Delegacia da Mulher, casa de passagem, brinquedoteca, e transporte. No mesmo espaço, funcionam no horário comercial ou horário especial: Juizado da Mulher; Defensoria Pública; Ministério Público; e serviços de autonomia econômica, educação e formação.",
    },
    {
      "titulo": "Requisitos",
      "conteudo": "Ser mulher, maior de 18 anos, em situação de violência doméstica e outras vulnerabilidades, podendo estar acompanhada ou não de filhos.",
    },
    {
      "titulo": "Quem pode solicitar?",
      "conteudo": "Mulher pode ser atendida até sem documentação de identificação, sendo que no decorrer do acolhimento psicossocial será dado suporte para documentação básica.",
    },
    {
      "titulo": "Documentos",
      "conteudo": "RG\nCPF",
    },
    {
      "titulo": "Custo", 
      "conteudo": "Gratuito"
    },
    {
      "titulo": "Órgão responsável",
      "conteudo": "SECRETARIA DAS MULHERES",
    },
    {
      "titulo": "Unidade responsável",
      "conteudo": "Secretaria Executiva de Enfrentamento à Violência contra a Mulher",
    },
    {
      "titulo": "Endereço (Locais de Atendimento)",
      "conteudo": "R. Luiz Barbosa da Silva, 270 - Planalto Renascer, Quixadá - CE, 63901-085\nAv. Monsenhor José Aloísio Pinto, s/n - Cidade Gerardo Cristino de Menezes, Sobral - CE, 62051-215\nAvenida Padre Cícero, 4455 - São José, Juazeiro do Norte - CE, 63041-140",
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
                   onPressed: () => context.go('/CasaMulher'), // volta pra home
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
                    horizontal: 20,
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
                      padding: const EdgeInsets.all(16),
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

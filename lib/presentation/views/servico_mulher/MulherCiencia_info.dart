import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';

class MulhercienciaInfo extends StatelessWidget {
  final List<Map<String, String>> secoes = [
    {
      "titulo": "Informações gerais",
      "conteudo": "Conteúdo da seção de informações gerais aparece aqui.",
    },
    {
      "titulo": "O que é?",
      "conteudo":
          " Concessão de projetos de pesquisa que incluem despesas de capital e custeio, além de Bolsas de Apoio Técnico (BAT). Concede apoio à realização de projetos de pesquisas coordenados por mulheres, de Instituições de Ensino Superior - IES e Instituições de Ciência e Tecnologia - ICTs, públicas ou privadas sem fins lucrativos, com sede no estado do Ceará, que visam contribuir significativamente para o desenvolvimento científico e tecnológico e a inovação, em qualquer área do conhecimento.",
    },
    {
      "titulo": "Como solicitar?",
      "conteudo":
          "Online 1: Acessar a plataforma montenegro: http://montenegro.funcap.ce.gov.br/sugba/index.php?cnpj=00078007000126"
          "Online 2: Clicar em Editais;"
          "Online 3: Localizar o Edital (caso não esteja visível na aba Editais Abertos o edital não está aberto para submissão) e clicar em Acessar (entrar com login e senha; caso não tenha, realizar o cadastro)"
          "Online 4: Preencher o formulário e anexar os documentos solicitados.",
    },
    {
      "titulo": "Informações importantes",
      "conteudo": "Conteúdo da seção 'Informações importantes' aparece aqui.",
    },
    {
      "titulo": "Requisitos",
      "conteudo":
          "Apenas pesquisadoras doutoras podem ser proponentes."
          "É necessário verificar informações adicionais nos editais vigentes; o edital atual é o"
          "Os documentos geralmente solicitados são"
          "Cópia do projeto de pesquisa , Carta de anuência da instituição executora (aquela com a qual a proponente possui vínculo funcional/empregatício)"
          "Comprovante de submissão/parecer de comitê de ética em pesquisa.",
    },
    {
      "titulo": "Formas de acesso",
      "conteudo":
          "Concessão de projetos de pesquisa que incluem despesas de capital e custeio, além de Bolsas de Apoio Técnico (BAT). Concede apoio à realização de projetos de pesquisas coordenados por mulheres, de Instituições de Ensino Superior - IES e Instituições de Ciência e Tecnologia - ICTs, públicas ou privadas sem fins lucrativos, com sede no estado do Ceará, que visam contribuir significativamente para o desenvolvimento científico e tecnológico e a inovação, em qualquer área do conhecimento.",
    },
    {
      "titulo": "Documentos",
      "conteudo":
          "Carta de Anuência."
          "\ANUÊNCIADA IES EXECUTORA "
          "PROJETO de pesquisa"
          "COMPROVANTE DE SUBMISSAÕ PARECER DE COMITÊ EM PESQUISA ",
    },
    {"titulo": "Custo", "conteudo": "GRATUITO"},
    {"titulo": "Prazo para prestação do serviço", "conteudo": "MESES"},
    {
      "titulo": "Quem pode solicitar?",
      "conteudo": "PESQUISADORAS DOUTORAS do estado",
    },
    {
      "titulo": "Órgão responsável",
      "conteudo":
          "Fundação de apoio ao desenvolvimento cinetifíco e tecnologico.",
    },
    {
      "titulo": "Unidade responsável",
      "conteudo": "Gerência de foemnto de bolsas",
    },
    {"titulo": "Endereço", "conteudo": "Av."},
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
                  onPressed: () => Navigator.pop(context),
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
                  decoration: const BoxDecoration(shape: BoxShape.circle),
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

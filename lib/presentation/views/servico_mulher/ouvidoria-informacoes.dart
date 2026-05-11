import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class MaisinformacoesPage extends StatelessWidget {
  final List<Map<String, String>> secoes = [
    {
      "titulo": "Informações gerais",
      "conteudo": "Conteúdo da seção de informações gerais aparece aqui.",
    },
    {
      "titulo": "O que é?",
      "conteudo":
          "A ouvidoria representa um espaço de acolhimento, escuta e orientação, "
                "visando receber denúncias de violência e assédio contra mulheres e meninas "
                "da Universidade Estadual Vale do Acaraú.\n\n"
                "Os objetivos deste serviço são: Combater a violência contra mulheres e meninas "
                "da UVA; Estabelecer um canal específico de escuta ativa para o recebimento de "
                "informações, reclamações e denúncias relacionadas à violência contra meninas e "
                "mulheres da universidade, praticadas por representantes ou aqueles que atuam em "
                "função das atividades da universidade; Promover a colaboração com outras "
                "instituições destinadas ao combate e prevenção da violência contra a mulher.",
    },
    {
      "titulo": "Como solicitar?",
      "conteudo": "Telefone A manifestação é realizada pela menina ou mulher através do telefone / whatsapp: (88) 3611 1434. Falar com a responsável do setor (Mona Lisa: auxiliar administrativa / Professora Helena Mara: Coordenadora da Sala Girassol)."
      "Presencial"
      "A manifestação é realizada pela menina ou mulher pessoalmente com a responsável do setor (Mona Lisa: auxiliar administrativa / Professora Helena Mara: Coordenadora da Sala Girassol)."
      "Email:"
      "A manifestação é realizada pela menina ou mulher através do e-mail: ouvidoriamulheresemeninas@uvanet.br. Falar com a responsável do setor (Mona Lisa: auxiliar administrativa / Professora Helena Mara: Coordenadora da Sala Girassol) responderem assim que possível (o final da frase está cortado).",
    },
    {
      "titulo": "Informações importantes",
      "conteudo": "Os serviços prestados são:"
      "Recebimento de manifestações e tratamento às demandas relacionadas à violência contra a mulher e, especialmente, à igualdade de gênero e à participação feminina, apresentadas por servidoras, estagiárias, alunas, terceirizadas, prestadoras de serviços e demais colaboradoras da UVA;"
      "Receber as manifestações e dar tratamento às demandas relacionadas à violência contra a mulher praticadas por representantes ou em função das atividades da UVA;"
      "Espaço de acolhimento, escuta ativa e orientação sobre as demandas indicadas acima;"
      "Registro de demandas;"
      "Encaminhamentos;"
      "Agendamento de atendimentos."
      ,
    },
    {
      "titulo": "Requisitos",
      "conteudo": "Ser parte da comunidade acadêmica"
      "da UVA Servidora, terceirizada, aluna, professora e etc",
    },
    {
      "titulo": "Formas de acesso",
      "conteudo": "A ouvidoria representa um espaço de acolhimento, escuta e orientação, "
                "visando receber denúncias de violência e assédio contra mulheres e meninas "
                "da Universidade Estadual Vale do Acaraú.\n\n"
                "Os objetivos deste serviço são: Combater a violência contra mulheres e meninas "
                "da UVA; Estabelecer um canal específico de escuta ativa para o recebimento de "
                "informações, reclamações e denúncias relacionadas à violência contra meninas e "
                "mulheres da universidade, praticadas por representantes ou aqueles que atuam em "
                "função das atividades da universidade; Promover a colaboração com outras "
                "instituições destinadas ao combate e prevenção da violência contra a mulher.",
    },
    {
      "titulo": "Documentos",
      "conteudo": "Identidade com foto",
    },
    {"titulo": "Custo", "conteudo": "Gratuito "},
    {
      "titulo": "Prazo para prestação do serviço",
      "conteudo": "Imediato",
    },
    {
      "titulo": "Quem pode solicitar?",
      "conteudo": "Adolecentes e adultas do sexo feminino",
    },
    
    {
      "titulo": "Unidade responsável",
      "conteudo": "Ouvidoria.",
    },
    {
      "titulo": "Endereço",
      "conteudo": "",
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
                  onPressed: () => context.go('/sala_girassol'), // volta pra home
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

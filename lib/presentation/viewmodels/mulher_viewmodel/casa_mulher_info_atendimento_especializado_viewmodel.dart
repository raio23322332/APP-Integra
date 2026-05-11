import 'package:flutter/foundation.dart';

class InfoSection {
  final String title;
  final String content;

  const InfoSection({
    required this.title,
    required this.content,
  });
}

class CasaMulherInfoAtendimentoEspecializadoViewModel extends ChangeNotifier {
  // Textos fixos
  String get pageTitle => "Mais informações";
  String get subtitle => "Encontre aqui mais informações sobre o serviço";
  String get lastModifiedLabel => "Última modificação: 05/08/2024";

  // Rota de retorno (View decide como navegar)
  String get backRoute => '/CasaMulherinformacaoespecializadaGuia';

  // Seções
  List<InfoSection> get sections => const [
        InfoSection(
          title: "O que é?",
          content:
              "Casas da Mulher Cearense é um espaço de atendimento às mulheres em situação de violência doméstica e familiar com serviços integrados e humanizados.",
        ),
        InfoSection(
          title: "Como solicitar?",
          content: "Não especificado.",
        ),
        InfoSection(
          title: "Informações importantes",
          content:
              "Funcionamento 24h da recepção, psicossocial, com psicólogas e assistentes sociais, Delegacia da Mulher, casa de passagem, brinquedoteca, e transporte. No mesmo espaço, funcionam no horário comercial ou horário especial: Juizado da Mulher; Defensoria Pública; Ministério Público; e serviços de autonomia econômica, educação e formação.",
        ),
        InfoSection(
          title: "Requisitos",
          content:
              "Ser mulher, maior de 18 anos, em situação de violência doméstica e outras vulnerabilidades, podendo estar acompanhada ou não de filhos.",
        ),
        InfoSection(
          title: "Quem pode solicitar?",
          content:
              "Mulher pode ser atendida até sem documentação de identificação, sendo que no decorrer do acolhimento psicossocial será dado suporte para documentação básica.",
        ),
        InfoSection(
          title: "Documentos",
          content: "RG\nCPF",
        ),
        InfoSection(
          title: "Custo",
          content: "Gratuito",
        ),
        InfoSection(
          title: "Órgão responsável",
          content: "SECRETARIA DAS MULHERES",
        ),
        InfoSection(
          title: "Unidade responsável",
          content:
              "Secretaria Executiva de Enfrentamento à Violência contra a Mulher",
        ),
        InfoSection(
          title: "Endereço",
          content:
              "R. Luiz Barbosa da Silva, 270 - Planalto Renascer, Quixadá - CE, 63901-085\n"
              "Av. Monsenhor José Aloísio Pinto, s/n - Cidade Gerardo Cristino de Menezes, Sobral - CE, 62051-215\n"
              "Avenida Padre Cícero, 4455 - São José, Juazeiro do Norte - CE, 63041-140\n\n"
              "Se precisar de ajuda para encontrar a localização exata de um desses endereços ou informações de contato, por favor, me avise!",
        ),
        InfoSection(
          title: "Sala Lilás da Estação",
          content: """
* **O que é? / Formas de acesso:**
"Sala Lilás é um espaço de atendimento às **mulheres em situação de violência doméstica e outras vulnerabilidades** com serviços de **acolhimento psicológico e orientações em geral**."

* **Como solicitar?**
1. **Presencial 1:** Ir à **Estação da Mulher**;
2. **Presencial 2:** Solicitar atendimento a especialista;
3. **Presencial 3:** Receber acolhimento psicológico, orientações, **solicitação de Medida Protetiva Virtual**, e encaminhamento para... (texto cortado).

* **Informações importantes (Localização):**
"Fica localizada na **Estação da Parangaba da Linha Sul do Metrô de Fortaleza**, Rua Eduardo Perdigão, nº 203 - lojas 1 e 2, bairro Parangaba, Fortaleza-Ceará;"

* **Requisitos:**
"Ser mulher, maior de 18 anos, em situação de violência doméstica e outras vulnerabilidades, podendo estar acompanhada ou não de filhos."

* **Quem pode solicitar?**
"Mulher pode ser atendida **até sem documento de identificação**, sendo que no decorrer do acolhimento será dado suporte para documentação."

* **Documentos:**
"RG / CPF"

* **Custo:**
"Gratuito"

* **Prazo para prestação do serviço:**
"Imediato"

* **Órgão responsável:**
"SECRETARIA DAS MULHERES"

* **Unidade responsável:**
"Secretaria Executiva de Enfrentamento à Violência contra a Mulher"

* **Endereço:**
"R. Eduardo Perdigão, nº 203 - Parangaba, Fortaleza - CE, 60720-110"
""",
        ),
      ];
}

import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/presentation/routes/app_router.dart';

class PodaDeArvoreIntroScreen extends StatelessWidget {
  // Tela de introdução para o serviço de poda de árvore.
  const PodaDeArvoreIntroScreen({super.key});

  final primaryBlue = const Color(0xFF28669b);
  final secondaryGreen = const Color(0xFF4b8c40);
  final textDark = const Color(0xFF263860);
  final lightBackground = const Color(0xFFecf2f2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Poda de Árvore'),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(FontAwesomeIcons.tree, size: 24), // Ícone de árvore no canto direito
          ),
        ],
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Voltar',
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.lightBlue,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitar Poda de Árvore',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
            onPressed: () {
              // Navega para a tela de seleção de localização
              context.go(AppRoutes.PodaDeArvoreFormPage);
            },
            icon: const Icon(FontAwesomeIcons.handPointRight, size: 20),
            label: const Text(
              'Iniciar Serviço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 5,
            ),
          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Última atualização: 16/12/2025',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Divider(height: 30),
                ],
              ),
            ),
            _buildExpansionTile(
              title: 'O que é',
              content:
                  'Solicitação para remoção de galhos secos, doentes ou que estejam em contato com a fiação elétrica, ou ainda para a supressão (corte total) de árvores em vias públicas.',
              icon: FontAwesomeIcons.tree,
            ),
            _buildExpansionTile(
              title: 'Público Alvo',
              content:
                  'Qualquer cidadão, pessoa física ou jurídica, residente ou estabelecido no município.',
              icon: FontAwesomeIcons.users,
            ),
            _buildExpansionTile(
              title: 'Como fazer',
              content:
                  '1. Clique em "Iniciar Serviço".\n2. Preencha o endereço completo da árvore.\n3. Descreva o problema (ex: galhos secos, risco de queda).\n4. Envie a solicitação.',
              icon: FontAwesomeIcons.listCheck,
            ),
            _buildExpansionTile(
              title: 'Documentação necessária',
              content:
                  'Nenhuma documentação é necessária para a abertura do protocolo. A equipe técnica fará a vistoria no local.',
              icon: FontAwesomeIcons.fileLines,
            ),
            _buildExpansionTile(
              title: 'Quanto tempo leva',
              content:
                  'O prazo médio para a vistoria é de 15 dias úteis. A execução do serviço é agendada após a aprovação da vistoria.',
              icon: FontAwesomeIcons.hourglassHalf,
            ),
            _buildExpansionTile(
              title: 'Quanto custa',
              content:
                  'O serviço de poda e supressão de árvores em vias públicas é gratuito.',
              icon: FontAwesomeIcons.moneyBillWave,
            ),
            _buildExpansionTile(
              title: 'Outras informações',
              content:
                  'A poda sem autorização da prefeitura é proibida e pode gerar multa. Em caso de emergência (risco iminente de queda), ligue para a Defesa Civil.',
              icon: FontAwesomeIcons.circleInfo,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 0,
      color: Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: primaryBlue),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(color: textDark.withOpacity(0.8), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

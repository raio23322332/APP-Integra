import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/presentation/routes/app_router.dart';

class PodaDeArvoreSuccessScreen extends StatelessWidget {
  final String protocol;

  const PodaDeArvoreSuccessScreen({super.key, required this.protocol});

  final primaryBlue = const Color(0xFF28669b);
  final secondaryGreen = const Color(0xFF4b8c40);
  final highlightTeal = const Color(0xFF248e95);
  final textDark = const Color(0xFF263860);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitação Enviada'),
        foregroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, // Remove o botão de voltar
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(FontAwesomeIcons.tree, size: 24), // Ícone de árvore no canto direito
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF28669b),
                Color(0xFF3FA9F5),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSuccessHeader(),
            const SizedBox(height: 30),
            _buildProtocolCard(),
            const SizedBox(height: 30),
            _buildExplanatoryCards(),
            const SizedBox(height: 30),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Icon(
          FontAwesomeIcons.solidCircleCheck,
          color: secondaryGreen,
          size: 80,
        ),
        const SizedBox(height: 15),
        Text(
          'Solicitação de Poda Registrada com Sucesso!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Seu pedido foi enviado para análise da Secretaria de Meio Ambiente.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: textDark.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildProtocolCard() {
    return Card(
      elevation: 4,
      color: Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'SEU NÚMERO DE PROTOCOLO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryBlue),
              ),
              child: Text(
                protocol,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Use este número para acompanhar o status da sua solicitação.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanatoryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos Passos e Informações Importantes:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 15),
        _buildInfoCard(
          icon: FontAwesomeIcons.hourglassHalf,
          title: 'Prazo de Análise',
          description:
              'O prazo médio para a vistoria técnica é de 15 dias úteis. Você será notificado sobre a aprovação ou reprovação.',
          color: highlightTeal,
        ),
        _buildInfoCard(
          icon: FontAwesomeIcons.tree,
          title: 'Legislação',
          description:
              'Lembre-se que a poda de árvores em vias públicas só pode ser realizada pela prefeitura ou por empresas autorizadas.',
          color: secondaryGreen,
        ),
        _buildInfoCard(
          icon: FontAwesomeIcons.mapMarkerAlt,
          title: 'Acompanhamento',
          description:
              'Você pode verificar o status do seu protocolo a qualquer momento na área "Minhas Solicitações" do seu perfil.',
          color: primaryBlue,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      color: Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
        ),
        subtitle: Text(description),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
       
        context.go(AppRoutes.home);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Voltar para a Tela Inicial',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

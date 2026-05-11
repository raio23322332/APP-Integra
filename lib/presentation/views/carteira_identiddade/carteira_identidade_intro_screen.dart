import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/presentation/routes/app_router.dart';


class CarteiraIdentidadeIntroScreen extends StatelessWidget {
  const CarteiraIdentidadeIntroScreen({super.key});

  final primaryBlue = const Color(0xFF28669b);
  final secondaryGreen = const Color(0xFF4b8c40);
  final textDark = const Color(0xFF263860);
  final lightBackground = const Color(0xFFecf2f2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.lightBlue],
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
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    tooltip: 'Voltar',
                    onPressed: () {
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  // Título
                  const Text(
                    'Carteira de Identidade',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  // Ícone
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Icon(FontAwesomeIcons.idCard, size: 24, color: Colors.white),
                  ),
                ],
              ),
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
                  // Título Responsivo
                  Text(
                    'Solicitar Carteira de Identidade Nacional (CIN)',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botão de Ação com largura total
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
            onPressed: () {
              // Navega para a tela de seleção de localização
              context.go(AppRoutes.CarteiraIdentidadePage);
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
                    'Última atualização: 26/10/2025',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const Divider(height: 30),
                ],
              ),
            ),
           
            _buildExpansionTile(
              title: 'O que é',
              content:
                  'A Carteira de Identidade Nacional (CIN) é o novo documento de identificação do Brasil, que utiliza o número do CPF como único registro nacional. Ela substitui o antigo RG e está disponível em formato físico e digital.',
              icon: FontAwesomeIcons.fingerprint,
            ),
            _buildExpansionTile(
              title: 'Público Alvo',
              content:
                  'Todos os cidadãos brasileiros, incluindo recém-nascidos. A primeira via da CIN é gratuita.',
              icon: FontAwesomeIcons.users,
            ),
            _buildExpansionTile(
              title: 'Como fazer',
              content:
                  '1. Clique em "Iniciar Serviço" para verificar a disponibilidade de agendamento.\n2. Agende seu atendimento em um posto de identificação (ex: Poupatempo, Polícia Civil).\n3. Compareça ao local com a documentação necessária.\n4. Retire o documento na data informada.',
              icon: FontAwesomeIcons.listCheck,
            ),
            _buildExpansionTile(
              title: 'Documentação necessária',
              content:
                  '1. Certidão de Nascimento ou Casamento (original ou cópia autenticada).\n2. CPF (o número deve estar regularizado na Receita Federal).\n3. Comprovante de residência (alguns estados podem exigir).',
              icon: FontAwesomeIcons.fileLines,
            ),
            _buildExpansionTile(
              title: 'Quanto tempo leva',
              content:
                  'O prazo de entrega varia por estado, mas geralmente é de 5 a 15 dias úteis após o atendimento. A validade varia conforme a idade: 0 a 12 anos (5 anos); 12 a 60 anos (10 anos); acima de 60 anos (indeterminada).',
              icon: FontAwesomeIcons.hourglassHalf,
            ),
            _buildExpansionTile(
              title: 'Quanto custa',
              content:
                  'A primeira via da Carteira de Identidade Nacional (CIN) é gratuita. A segunda via pode ter custo, dependendo do estado.',
              icon: FontAwesomeIcons.moneyBillWave,
            ),
            _buildExpansionTile(
              title: 'Outras informações',
              content:
                  'O antigo RG continua válido até 2032. Não há necessidade de substituição imediata, exceto se o documento estiver vencido, danificado ou para crianças que atingem a idade de renovação.',
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
      color: Colors.white,
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

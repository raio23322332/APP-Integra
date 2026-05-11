import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';

class CinAvisoAgendamentoScreen extends StatelessWidget {
  const CinAvisoAgendamentoScreen({super.key});

  final primaryGreen = const Color(0xFF4b8c40);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho sem imagem
            Container(
              padding: const EdgeInsets.all(16.0),
              color: primaryGreen,
              child: Column(
                children: const [
                  Text(
                    'Quero solicitar a Carteira de Identidade Nacional - CIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Agendamento para emissão da Carteira de Identidade Nacional - CIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Conteúdo do Aviso
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Antes de iniciar, temos algumas informações importantes:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildListItem(
                    'Para agendar a emissão da CIN, é necessário ter um **CPF ativo**.',
                  ),
                  _buildListItem(
                    'No dia do atendimento, é obrigatória a apresentação do CPF e da certidão de nascimento ou casamento original ou **cópia autenticada em cartório**.',
                  ),
                  _buildListItem(
                    '**Menores de 16 anos** devem estar acompanhados por responsáveis legais.',
                  ),
                  _buildListItem(
                    'A **1ª via da CIN** em papel de segurança é **gratuita**, enquanto a **2ª via** é paga.',
                  ),
                  const SizedBox(height: 32),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Ao continuar você concorda com o ',
                        ),
                        TextSpan(
                          text: 'aviso de privacidade',
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' e as '),
                        TextSpan(
                          text: 'políticas de cookies.',
                          style: TextStyle(
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(AppRoutes.CinAgendamentoTipoPage);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

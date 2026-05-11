import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/presentation/viewmodels/cin_viewmodel.dart';
import 'package:provider/provider.dart';
import '../routes/app_router.dart';

class CinAgendamentoTipoScreen extends StatelessWidget {
  const CinAgendamentoTipoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CinViewModel>(context);
    const primaryGreen = Color(0xFF4b8c40);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quero solicitar a Carteira de ...'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pra quem será feito o agendamento?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildRadioOption(
              context,
              viewModel,
              value: 'pessoal',
              title: 'Agendamento pessoal',
              subtitle: 'Agendar pra mim.',
              icon: FontAwesomeIcons.user,
            ),
            const SizedBox(height: 16),
            _buildRadioOption(
              context,
              viewModel,
              value: 'dependente',
              title: 'Agendamento de dependente',
              subtitle:
                  'Agendar pra outra pessoa. O vínculo precisará ser comprovado.',
              icon: FontAwesomeIcons.users,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.CinAgendamentoFormPage);
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    BuildContext context,
    CinViewModel viewModel, {
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    const primaryGreen = Color(0xFF4b8c40);
    return InkWell(
      onTap: () {
        viewModel.selectAppointmentType(value);
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: viewModel.appointmentType == value
                ? primaryGreen
                : Colors.grey.shade300,
            width: viewModel.appointmentType == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: primaryGreen),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: viewModel.appointmentType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  viewModel.selectAppointmentType(newValue);
                }
              },
              activeColor: primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
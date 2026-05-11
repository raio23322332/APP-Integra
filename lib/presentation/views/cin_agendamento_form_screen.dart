import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/cin_agendamento_viewmodel.dart';
import '../widgets/common/app_loader.dart';

class CinAgendamentoFormScreen extends StatelessWidget {
  const CinAgendamentoFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4b8c40);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quero solicitar a Carteira de ...'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<CinAgendamentoViewModel>(
        builder: (context, vm, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: vm.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stepper Simples (evita erro de null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStep('Dados', true, primaryGreen),
                      _buildStep('Verificação', false, primaryGreen),
                      _buildStep('Posto', false, primaryGreen),
                      _buildStep('Horário', false, primaryGreen),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    'Preencha com as suas informações:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Campo Nome
                  TextFormField(
                    controller: vm.nomeCtrl,
                    validator: vm.validateNome,
                    decoration: const InputDecoration(
                      hintText: 'Nome completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo CPF
                  TextFormField(
                    controller: vm.cpfCtrl,
                    keyboardType: TextInputType.number,
                    validator: vm.validateCpf,
                    decoration: const InputDecoration(
                      hintText: 'CPF',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Email
                  TextFormField(
                    controller: vm.emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: vm.validateEmail,
                    decoration: const InputDecoration(
                      hintText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Celular
                  TextFormField(
                    controller: vm.celCtrl,
                    keyboardType: TextInputType.phone,
                    validator: vm.validateCelular,
                    decoration: const InputDecoration(
                      hintText: 'Celular',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Motivo
                  const Text(
                    'Por que deseja solicitar a CIN?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: const Text('Selecione o motivo'),
                    value: vm.state.motivo,
                    items: vm.motives
                        .map(
                          (v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(v),
                          ),
                        )
                        .toList(),
                    validator: vm.validateMotivo,
                    onChanged: vm.setMotivo,
                  ),

                  // Mensagem de erro
                  if (vm.state.error != FormError.none) ...[
                    const SizedBox(height: 16),
                    Text(
                      vm.state.error.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],

                  // Botão
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : vm.submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: vm.isLoading
                          ? const AppLoader()
                          : const Text(
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
          );
        },
      ),
    );
  }

  static Widget _buildStep(
    String title,
    bool isActive,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
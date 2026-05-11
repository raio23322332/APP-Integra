// lib/presentation/views/poda_arvore/poda_de_arvore_form_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart' show AppColors;
import 'package:integra_app/presentation/viewmodels/poda_arvore/poda_de_arvore_viewmodel.dart';
import 'package:integra_app/presentation/views/reparo_iluminacao/iluminacao.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




class PodaDeArvoreFormScreen extends StatefulWidget {
  const PodaDeArvoreFormScreen({super.key});

  @override
  State<PodaDeArvoreFormScreen> createState() => _PodaDeArvoreFormScreenState();
}

class _PodaDeArvoreFormScreenState extends State<PodaDeArvoreFormScreen> {
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PodaDeArvoreViewModel>();
      vm.initialize();
      _eventSubscription = vm.events.listen(_handleEvent);
    });
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    if (event is NavigationEvent) {
      context.go(event.route, extra: event.extra);
    } else if (event is ShowSnackBarEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.message),
          backgroundColor: event.isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PodaDeArvoreViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            title: const Text('Formulário de Poda'),
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
                      context.go('/poda-de-arvore-intro');
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Preencha os dados da solicitação',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightPrimaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Campos marcados com * são obrigatórios.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 25),

                // Endereço
                TextField(
                  controller: viewModel.addressController, // ✅ DO VIEWMODEL
                  decoration: _inputDecoration(
                    labelText: 'Endereço da Árvore *',
                    icon: FontAwesomeIcons.mapMarkerAlt,
                  ),
                ),
                const SizedBox(height: 20),

                // Problema
                DropdownButtonFormField<String>(
                  value: viewModel.selectedProblem,
                  decoration: _inputDecoration(
                    labelText: 'Tipo de Problema *',
                    icon: FontAwesomeIcons.tree,
                  ),
                  items: viewModel.problemOptions // ✅ DO VIEWMODEL
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: viewModel.setSelectedProblem,
                ),
                const SizedBox(height: 20),

                // Descrição
                TextField(
                  controller: viewModel.descriptionController, // ✅ DO VIEWMODEL
                  maxLines: 4,
                  decoration: _inputDecoration(
                    labelText: 'Detalhes Adicionais (Opcional)',
                    icon: FontAwesomeIcons.fileAlt,
                  ).copyWith(alignLabelWithHint: true),
                ),
                const SizedBox(height: 25),

                // Foto
                OutlinedButton.icon(
                  onPressed: viewModel.isLoading ? null : viewModel.pickImage,
                  icon: const Icon(FontAwesomeIcons.camera, color: AppColors.primaryBlue),
                  label: Text(
                    viewModel.imagePath != null
                        ? 'Foto Selecionada'
                        : 'Adicionar Foto (Opcional)',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (viewModel.imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Imagem: ${viewModel.imagePath!.split('/').last}',
                      style: const TextStyle(fontSize: 12, color: AppColors.lightPrimaryText),
                    ),
                  ),
                const SizedBox(height: 30),

                // Botão de envio
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : viewModel.submitRequest, // ✅ SEM DADOS HARCODED
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Enviar Solicitação de Poda',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
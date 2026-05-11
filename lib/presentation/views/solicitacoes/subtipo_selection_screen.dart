// presentation/views/solicitacoes/subtipo_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/core/models/tipo_model.dart';
import 'package:integra_app/core/models/subt_tipo_model.dart';
import 'package:integra_app/core/constants/tipos_constants.dart';

class SubtipoSelectionScreen extends StatefulWidget {
  final String tipo;
  final String slug;

  const SubtipoSelectionScreen({
    super.key,
    required this.tipo,
    required this.slug,
  });

  @override
  State<SubtipoSelectionScreen> createState() => _SubtipoSelectionScreenState();
}

class _SubtipoSelectionScreenState extends State<SubtipoSelectionScreen> {
  late TipoModel tipoSelecionado;
  SubtTipoModel? subtipoSelecionado;

  @override
  void initState() {
    super.initState();
    // Encontrar o tipo selecionado baseado no slug
    tipoSelecionado = TiposConstants.data.firstWhere(
      (tipo) => tipo.slug == widget.slug,
      orElse: () => TiposConstants.data.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Selecionar Subtipo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Header com informações
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tipo,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecione o subtipo mais adequado para sua solicitação:',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lista de subtipos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tipoSelecionado.subtipos.length,
              itemBuilder: (context, index) {
                final subtipo = tipoSelecionado.subtipos[index];
                final isSelected = subtipoSelecionado?.id == subtipo.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(153),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconForSubtipo(subtipo.descricao ?? ''),
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      subtipo.descricao ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.darkText,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primaryBlue,
                            size: 24,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        subtipoSelecionado = subtipo;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(153),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: subtipoSelecionado != null
                ? () => _proximoPasso()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: subtipoSelecionado != null
                  ? AppColors.primaryBlue
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Próximo Passo'),
          ),
        ),
      ),
    );
  }

  IconData _getIconForSubtipo(String descricao) {
    final desc = descricao.toLowerCase();
    if (desc.contains('apagada') || desc.contains('acesa')) {
      return FontAwesomeIcons.lightbulb;
    } else if (desc.contains('oscilando')) {
      return FontAwesomeIcons.bolt;
    } else if (desc.contains('nova') || desc.contains('instalar')) {
      return FontAwesomeIcons.circlePlus;
    } else if (desc.contains('vandalismo')) {
      return FontAwesomeIcons.triangleExclamation;
    } else if (desc.contains('lixo') || desc.contains('entulho')) {
      return FontAwesomeIcons.trash;
    } else if (desc.contains('buraco') || desc.contains('irregularidade')) {
      return FontAwesomeIcons.road;
    } else {
      return FontAwesomeIcons.gears;
    }
  }

  void _proximoPasso() {
    if (subtipoSelecionado == null) {
      // Mostrar mensagem de erro se nenhum subtipo for selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um subtipo antes de continuar'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validar se o ID do subtipo selecionado é válido
    final subtipoId = subtipoSelecionado!.id;
    ConsoleLog.debug(
      'Subtipo selecionado: ${subtipoSelecionado!.descricao} (ID: $subtipoId)',
    );

    // Verificar se o ID está na faixa válida (1-13)
    final subtipoIdInt = int.tryParse(subtipoId);
    if (subtipoIdInt == null || subtipoIdInt < 1 || subtipoIdInt > 13) {
      ConsoleLog.error(
        '❌ Subtipo ID inválido: $subtipoId (deve ser entre 1 e 13)',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subtipo selecionado inválido. Tente novamente.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ConsoleLog.debug('✅ Subtipo validado: $subtipoIdInt');

    // Navegar para a nova tela de solicitação unificada
    context.push(
      '/solicitacoes/nova',
      extra: {
        'tipo': widget.tipo,
        'slug': widget.slug,
        'subtipo': subtipoSelecionado!.descricao ?? '',
        'subtipoId': subtipoSelecionado!.id,
        'tipoId': tipoSelecionado.id,
      },
    );
  }
}

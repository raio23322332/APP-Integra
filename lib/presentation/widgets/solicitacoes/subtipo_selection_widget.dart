import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/core/models/tipo_model.dart';
import 'package:integra_app/core/models/subt_tipo_model.dart';
import 'package:integra_app/core/constants/tipos_constants.dart';

class SubtipoSelectionWidget extends StatefulWidget {
  final String tipo;
  final String slug;
  final Function(String subtipo, String subtipoId) onSubtipoSelected;
  final String? initialSubtipo;
  final String? initialSubtipoId;

  const SubtipoSelectionWidget({
    super.key,
    required this.tipo,
    required this.slug,
    required this.onSubtipoSelected,
    this.initialSubtipo,
    this.initialSubtipoId,
  });

  @override
  State<SubtipoSelectionWidget> createState() => _SubtipoSelectionWidgetState();
}

class _SubtipoSelectionWidgetState extends State<SubtipoSelectionWidget> {
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
    
    // Se já tiver um subtipo selecionado, encontrá-lo
    if (widget.initialSubtipo != null && widget.initialSubtipoId != null) {
      subtipoSelecionado = tipoSelecionado.subtipos.firstWhere(
        (subtipo) => subtipo.id == widget.initialSubtipoId,
        orElse: () => tipoSelecionado.subtipos.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header com informações
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
        // Lista de subtipos com altura expandida
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                  // Notificar o componente pai sobre a seleção
                  widget.onSubtipoSelected(
                    subtipo.descricao ?? '',
                    subtipo.id,
                  );
                },
              ),
            );
          },
        ),
      ],
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
}
import 'package:flutter/material.dart';

import 'custom_snack_bar.dart'; // Import movido para o topo do arquivo

// ============================================================================
// WIDGET REUTILIZÁVEL: ExpansionTileCard
// ============================================================================
/// Widget reutilizável para criar cards com ExpansionTile
/// Utilizado em telas de introdução (Carteira de Identidade, Poda de Árvore, etc.)
class ExpansionTileCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color primaryColor;
  final Color textColor;

  const ExpansionTileCard({
    Key? key,
    required this.title,
    required this.content,
    required this.icon,
    this.primaryColor = const Color(0xFF28669b),
    this.textColor = const Color(0xFF263860),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('expansionTileCard_$title'),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        key: ValueKey('expansionTile_$title'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          key: ValueKey('expansionTileIcon_$title'),
          icon,
          color: primaryColor,
        ),
        title: Text(
          key: ValueKey('expansionTileTitle_$title'),
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              key: ValueKey('expansionTileContent_$title'),
              content,
              style: TextStyle(color: textColor.withOpacity(0.8), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET REUTILIZÁVEL: ActionButton
// ============================================================================
/// Widget reutilizável para botões de ação com ícone
/// Utilizado em telas de introdução para iniciar serviços
/// Suporta estado de carregamento com indicador visual
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;
  final double padding;
  final double borderRadius;
  final bool isLoading;
  final String? loadingLabel;

  const ActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF4b8c40),
    this.foregroundColor = Colors.white,
    this.fontSize = 18,
    this.padding = 15,
    this.borderRadius = 30,
    this.isLoading = false,
    this.loadingLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey('actionButton_$label'),
      width: double.infinity,
      child: ElevatedButton.icon(
        key: ValueKey('elevatedButton_$label'),
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                key: ValueKey('buttonLoadingIcon_$label'),
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: foregroundColor,
                  strokeWidth: 2.5,
                ),
              )
            : Icon(key: ValueKey('buttonIcon_$label'), icon, size: 20),
        label: Text(
          key: ValueKey('buttonLabel_$label'),
          isLoading ? (loadingLabel ?? 'Processando...') : label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? backgroundColor.withOpacity(0.7)
              : backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: isLoading ? 2 : 5,
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET REUTILIZÁVEL: ServiceHeader
// ============================================================================
/// Widget reutilizável para cabeçalho de serviço
/// Exibe título, botão de ação e data de atualização
class ServiceHeader extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onButtonPressed;
  final String lastUpdateDate;
  final Color textColor;
  final Color buttonColor;

  const ServiceHeader({
    Key? key,
    required this.title,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onButtonPressed,
    this.lastUpdateDate = 'Última atualização: 26/10/2025',
    this.textColor = const Color(0xFF263860),
    this.buttonColor = const Color(0xFF4b8c40),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('serviceHeader_$title'),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        key: ValueKey('serviceHeaderColumn_$title'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key: ValueKey('serviceHeaderTitle_$title'),
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          ActionButton(
            key: ValueKey('serviceHeaderButton_$title'),
            label: buttonLabel,
            icon: buttonIcon,
            onPressed: onButtonPressed,
            backgroundColor: buttonColor,
          ),
          const SizedBox(height: 20),
          Text(
            key: ValueKey('serviceHeaderDate_$title'),
            lastUpdateDate,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Divider(height: 30),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET REUTILIZÁVEL: ProblemTag
// ============================================================================
/// Widget reutilizável para tags de seleção de problema
/// Utilizado em formulários de submissão
class ProblemTag extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback? onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const ProblemTag({
    Key? key,
    required this.text,
    this.isSelected = false,
    required this.isDarkMode,
    this.onTap,
    this.selectedColor = const Color(0xFF137FEC),
    this.unselectedColor = const Color(0xFF334155),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? (isDarkMode ? Colors.white : selectedColor)
        : (isDarkMode ? const Color(0xFFC7D2E2) : unselectedColor);
    final Color backgroundColor = isSelected
        ? selectedColor.withOpacity(0.15)
        : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    return InkWell(
      key: ValueKey('problemTag_$text'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        key: ValueKey('problemTagContainer_$text'),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          key: ValueKey('problemTagText_$text'),
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET REUTILIZÁVEL: FormField
// ============================================================================
/// Widget reutilizável para campos de formulário
class FormFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final int maxLines;
  final int minLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color primaryColor;

  const FormFieldWidget({
    Key? key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.controller,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.primaryColor = const Color(0xFF28669b),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('formField_$label'),
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                key: ValueKey('formFieldIcon_$label'),
                prefixIcon,
                color: primaryColor,
              )
            : null,
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
      ),
    );
  }
}

// ============================================================================
// FUNÇÃO REUTILIZÁVEL: showServiceInfoSnackBar
// ============================================================================
/// Função para exibir uma notificação explicativa sobre um serviço
/// Utilizada na HomeScreen para informar sobre serviços disponíveis
void showServiceInfoSnackBar(
  BuildContext context,
  String serviceName,
  String description,
) {
  CustomSnackBar.showSuccess(context, 'ℹ️ $serviceName\n$description');
}

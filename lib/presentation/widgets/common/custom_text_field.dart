// ARQUIVO: lib/presentation/widgets/common/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final bool isRequired;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final String? counterText;
  final EdgeInsets? contentPadding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.counterText,
    this.contentPadding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: null, // Desabilitar labelText padrão
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: AppColors.primaryBlue, size: 20)
            : null,
        suffixIcon: suffixIcon,
        counterText: counterText,
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        // Estilo mais forte para as bordas usando cores padrão do app
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        // Estilo do hint com cores padrão do app
        hintStyle: TextStyle(
          color: AppColors.grey600,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        // Cor de fundo padrão do app
        filled: true,
        fillColor: AppColors.lightSurface,
        // Label customizado com RichText
        label: label != null ? _buildCustomLabel() : null,
      ),
    );
  }

  Widget _buildCustomLabel() {
    if (label == null) return const SizedBox.shrink();
    
    // Verificar se o label contém asterisco
    final hasAsterisk = label!.contains('*');
    
    if (!hasAsterisk || !isRequired) {
      return Text(
        label!,
        style: TextStyle(
          color: AppColors.lightSecondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    
    // Separar o texto do asterisco
    final parts = label!.split('*');
    final textWithoutAsterisk = parts[0].trim();
    
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: textWithoutAsterisk,
            style: TextStyle(
              color: AppColors.lightSecondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
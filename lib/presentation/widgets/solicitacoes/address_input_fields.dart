import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../common/custom_text_field.dart';

class AddressInputFields extends StatelessWidget {
  final TextEditingController enderecoController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController estadoController;
  final TextEditingController referenciaController;
  final FocusNode enderecoFocus;
  final FocusNode numeroFocus;
  final FocusNode complementoFocus;
  final FocusNode bairroFocus;
  final FocusNode cidadeFocus;
  final FocusNode estadoFocus;
  final FocusNode referenciaFocus;

  const AddressInputFields({
    super.key,
    required this.enderecoController,
    required this.numeroController,
    required this.complementoController,
    required this.bairroController,
    required this.cidadeController,
    required this.estadoController,
    required this.referenciaController,
    required this.enderecoFocus,
    required this.numeroFocus,
    required this.complementoFocus,
    required this.bairroFocus,
    required this.cidadeFocus,
    required this.estadoFocus,
    required this.referenciaFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: enderecoController,
          focusNode: enderecoFocus,
          label: 'Logradouro *',
          hint: 'Rua, Avenida, etc.',
          prefixIcon: FontAwesomeIcons.road,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => numeroFocus.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe o logradouro';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: numeroController,
          focusNode: numeroFocus,
          label: 'Número *',
          hint: '123',
          prefixIcon: FontAwesomeIcons.hashtag,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => complementoFocus.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe o número';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: complementoController,
          focusNode: complementoFocus,
          label: 'Complemento',
          hint: 'Apto, Casa',
          prefixIcon: FontAwesomeIcons.house,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => bairroFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: bairroController,
          focusNode: bairroFocus,
          label: 'Bairro *',
          hint: 'Centro',
          prefixIcon: FontAwesomeIcons.locationDot,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => cidadeFocus.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe o bairro';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: cidadeController,
          focusNode: cidadeFocus,
          label: 'Cidade *',
          hint: 'Sua cidade',
          prefixIcon: FontAwesomeIcons.city,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => estadoFocus.requestFocus(),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe a cidade';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildEstadoField(),
        const SizedBox(height: 16),
        CustomTextField(
          controller: referenciaController,
          focusNode: referenciaFocus,
          label: 'Ponto de Referência',
          hint: 'Próximo à farmácia, esquina, etc.',
          prefixIcon: FontAwesomeIcons.mapPin,
          maxLines: 2,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildEstadoField() {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.flag, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Estado (UF) *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextFormField(
              controller: estadoController,
              focusNode: estadoFocus,
              maxLength: 2,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                UpperCaseTextFormatter(),
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
              ],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => referenciaFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o estado';
                if (value.length != 2) return 'O estado deve ter 2 caracteres';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Ex: PB, SP, RJ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.error, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

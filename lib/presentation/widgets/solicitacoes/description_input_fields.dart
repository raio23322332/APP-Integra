import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../common/custom_text_field.dart';

class DescriptionInputFields extends StatefulWidget {
  final TextEditingController descricaoController;
  final TextEditingController observacaoController;
  final int maxDescricaoLength;
  final Function(String)? onDescricaoChanged;
  final Function(String)? onObservacaoChanged;

  const DescriptionInputFields({
    super.key,
    required this.descricaoController,
    required this.observacaoController,
    this.maxDescricaoLength = 500,
    this.onDescricaoChanged,
    this.onObservacaoChanged,
  });

  @override
  State<DescriptionInputFields> createState() => _DescriptionInputFieldsState();
}

class _DescriptionInputFieldsState extends State<DescriptionInputFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDescricaoSection(),
        const SizedBox(height: 16),
        _buildObservacaoSection(),
      ],
    );
  }

  Widget _buildDescricaoSection() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.description, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Descrição do Problema *',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.descricaoController.text.length}/${widget.maxDescricaoLength}',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.descricaoController.text.length > widget.maxDescricaoLength
                      ? AppColors.error
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: widget.descricaoController,
            hint: 'Descreva detalhadamente o que está acontecendo...',
            maxLines: 4,
            maxLength: widget.maxDescricaoLength,
            counterText: '',
            contentPadding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(8),
            onChanged: widget.onDescricaoChanged,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Descreva o problema';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildObservacaoSection() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.note_add_outlined, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 12),
              Text(
                'Observações (opcional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: widget.observacaoController,
            hint: 'Informações adicionais que possam ajudar...',
            maxLines: 3,
            contentPadding: const EdgeInsets.all(12),
            borderRadius: BorderRadius.circular(8),
            onChanged: widget.onObservacaoChanged,
          ),
        ],
      ),
    );
  }
}

class DescriptionInputFieldsCompact extends StatelessWidget {
  final TextEditingController descricaoController;
  final TextEditingController observacaoController;
  final int maxDescricaoLength;
  final String? Function(String?)? descricaoValidator;
  final Function(String)? onDescricaoChanged;
  final Function(String)? onObservacaoChanged;

  const DescriptionInputFieldsCompact({
    super.key,
    required this.descricaoController,
    required this.observacaoController,
    this.maxDescricaoLength = 500,
    this.descricaoValidator,
    this.onDescricaoChanged,
    this.onObservacaoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCompactDescriptionField(),
        const SizedBox(height: 16),
        _buildCompactObservacaoField(),
      ],
    );
  }

  Widget _buildCompactDescriptionField() {
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
      child: TextFormField(
        controller: descricaoController,
        decoration: InputDecoration(
          labelText: 'Descrição *',
          hintText: 'Descreva sua solicitação...',
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
          filled: true,
          fillColor: Colors.white,
          counterText: '',
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              '${descricaoController.text.length}/$maxDescricaoLength',
              style: TextStyle(
                fontSize: 12,
                color: descricaoController.text.length > maxDescricaoLength
                    ? AppColors.error
                    : Colors.grey[600],
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 60,
            minHeight: 20,
          ),
        ),
        maxLines: 3,
        maxLength: maxDescricaoLength,
        validator: descricaoValidator,
        onChanged: onDescricaoChanged,
      ),
    );
  }

  Widget _buildCompactObservacaoField() {
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
      child: TextFormField(
        controller: observacaoController,
        decoration: InputDecoration(
          labelText: 'Observação',
          hintText: 'Observações adicionais (opcional)...',
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
          filled: true,
          fillColor: Colors.white,
        ),
        maxLines: 2,
        onChanged: onObservacaoChanged,
      ),
    );
  }
}

// ui/widgets/confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final bool showInputField;
  final String? inputLabel;
  final String? inputHint;
  final bool inputRequired;
  final int? maxLines;
  final Future<void> Function(String?) onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.confirmColor = AppColors.primaryBlue,
    this.showInputField = false,
    this.inputLabel,
    this.inputHint,
    this.inputRequired = false,
    this.maxLines = 3,
    required this.onConfirm,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('confirmation_dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Container(
        key: const Key('confirmation_dialog_container'),
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header com ícone
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('confirmation_dialog_close_button'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Mensagem
            Text(
              key: const Key('confirmation_dialog_message'),
              widget.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            // Campo de input se necessário
            if (widget.showInputField) ...[
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('confirmation_dialog_input_field'),
                controller: _controller,
                maxLines: widget.maxLines,
                decoration: InputDecoration(
                  labelText: widget.inputLabel,
                  hintText: widget.inputHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.confirmColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: widget.inputRequired
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo é obrigatório';
                        }
                        return null;
                      }
                    : null,
              ),
            ],
            const SizedBox(height: 24),
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('confirmation_dialog_cancel_button'),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.cancelText,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('confirmation_dialog_confirm_button'),
                    onPressed: _isLoading ? null : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.confirmColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.confirmText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    // Validação do campo obrigatório
    if (widget.showInputField && widget.inputRequired) {
      if (_controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.inputLabel} é obrigatório'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await widget.onConfirm(_controller.text.trim().isEmpty ? null : _controller.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
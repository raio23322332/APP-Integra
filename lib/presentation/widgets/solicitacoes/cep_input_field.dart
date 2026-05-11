import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/helpers/console_log.dart';
import '../../../services/cep/cep_service.dart';

class CepInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool Function(String)? onCepValidated;
  final VoidCallback? onFieldSubmitted;

  const CepInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.onCepValidated,
    this.onFieldSubmitted,
  });

  @override
  State<CepInputField> createState() => _CepInputFieldState();
}

class _CepInputFieldState extends State<CepInputField> {
  bool _validandoCep = false;
  bool _cepValido = false;

  @override
  Widget build(BuildContext context) {
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
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        maxLength: 9,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
          _CepInputFormatter(),
        ],
        onFieldSubmitted: (_) async {
          if (widget.controller.text.length == 9) {
            await _validarCep();
          } else if (widget.nextFocusNode != null) {
            widget.nextFocusNode!.requestFocus();
          }
          widget.onFieldSubmitted?.call();
        },
        validator: (value) {
          if (value == null || value.isEmpty) return 'Informe o CEP';
          if (value.length != 9) return 'CEP inválido';
          if (!_cepValido) return 'CEP brasileiro não validado';
          return null;
        },
        onChanged: (value) {
          setState(() {
            _cepValido = false;
          });
          
          if (value.length == 9 && !_validandoCep) {
            Future.delayed(const Duration(milliseconds: 1000), () async {
              if (widget.controller.text.length == 9 && !_cepValido) {
                await _validarCep();
              }
            });
          }
        },
        decoration: InputDecoration(
          labelText: 'CEP Brasileiro *',
          hintText: '00000-000',
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.envelope, color: AppColors.primaryBlue, size: 20),
                if (_validandoCep) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    ),
                  ),
                ] else if (_cepValido) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ],
            ),
          ),
          suffixIcon: widget.controller.text.length == 9 && !_validandoCep
              ? IconButton(
                  icon: Icon(Icons.search, color: AppColors.primaryBlue),
                  onPressed: () => _validarCep(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _cepValido ? Colors.green : Colors.grey,
              width: _cepValido ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          counterText: '',
        ),
      ),
    );
  }

  Future<void> _validarCep() async {
    if (widget.controller.text.length != 9) return;
    
    setState(() => _validandoCep = true);
    
    try {
      final ehValido = await CepService.validarCepBrasileiro(widget.controller.text);
      
      if (ehValido) {
        final endereco = await CepService.buscarEndereco(widget.controller.text);
        
        if (endereco != null) {
          setState(() {
            _cepValido = true;
          });

          // Notificar sobre a validação bem-sucedida
          final isValid = widget.onCepValidated?.call(widget.controller.text) ?? true;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isValid ? '✅ CEP válido! Endereço preenchido.' : '✅ CEP válido!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          widget.nextFocusNode?.requestFocus();
        } else {
          setState(() => _cepValido = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ CEP encontrado mas sem endereço completo.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        setState(() => _cepValido = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ CEP brasileiro inválido ou não encontrado.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _cepValido = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _validandoCep = false);
    }
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (newText.length > 8) {
      newText = newText.substring(0, 8);
    }
    
    if (newText.length > 5) {
      newText = '${newText.substring(0, 5)}-${newText.substring(5)}';
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }
}

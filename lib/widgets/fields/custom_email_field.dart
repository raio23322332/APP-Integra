import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integra_app/core/theme/app_colors.dart';

class CustomEmailField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? initialText; 
  final TextEditingController? controller;

  const CustomEmailField({
    super.key,
    this.hintText = 'seu@email.com',
    this.errorText,
    this.onChanged,
    this.initialText,
    this.controller,
  });

  @override
  State<CustomEmailField> createState() => _CustomEmailFieldState();
}

class _CustomEmailFieldState extends State<CustomEmailField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'E-MAIL',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.errorText != null 
                  ? Colors.red 
                  : _isFocused 
                      ? AppColors.authPrimary 
                      : Colors.grey.shade300,
              width: widget.errorText != null || _isFocused ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (widget.errorText == null && _isFocused)
                BoxShadow(
                  color: AppColors.authPrimary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              else if (widget.errorText == null)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: _isFocused ? AppColors.authPrimary : Colors.grey[600],
                ),
              ),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  maxLength: 255,
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    counterText: '',
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.errorText!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
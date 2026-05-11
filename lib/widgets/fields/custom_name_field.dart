import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integra_app/core/theme/app_colors.dart';

class CustomNameField extends StatefulWidget {
  final String? errorText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final String? labelText;

  const CustomNameField({
    super.key,
    this.errorText,
    required this.onChanged,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.labelText,
  });

  @override
  State<CustomNameField> createState() => _CustomNameFieldState();
}

class _CustomNameFieldState extends State<CustomNameField> {
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
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
        ],
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
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            onChanged: widget.onChanged,
            maxLength: 255,
            keyboardType: widget.keyboardType ?? TextInputType.name,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            onSubmitted: (_) => widget.onSubmitted?.call(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.authText,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Nome completo',
              hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: _isFocused ? AppColors.authPrimary : Colors.grey[600],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              counterText: '',
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

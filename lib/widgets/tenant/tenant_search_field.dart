import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integra_app/core/theme/app_colors.dart';

class TenantSearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const TenantSearchField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('tenant_search_field_padding'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        key: const Key('tenant_search_field_container'),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.authBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          key: const Key('tenant_search_field'),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Buscar município...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ),
    );
  }
}
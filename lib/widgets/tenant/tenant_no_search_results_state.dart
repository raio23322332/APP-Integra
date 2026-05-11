import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/tenant_constants.dart';
import '../../core/theme/app_colors_login.dart';
 
class TenantNoSearchResultsState extends StatelessWidget {
  final VoidCallback onClearSearch;

  const TenantNoSearchResultsState({
    super.key,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('tenant_no_search_results'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: TenantConstants.emptyStateIconSize,
            color: Colors.grey[400],
          ),
          SizedBox(height: TenantConstants.emptyStateSpacing),
          Text(
            'Nenhum município encontrado.',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.authText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tente usar outros termos para buscar o município desejado.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: TenantConstants.emptyStateButtonSpacing),
          ElevatedButton.icon(
            onPressed: onClearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.clear, color: Colors.white),
            label: const Text('Limpar busca'),
          ),
        ],
      ),
    );
  }
}
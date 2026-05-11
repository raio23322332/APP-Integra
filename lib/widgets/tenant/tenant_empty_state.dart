import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../core/constants/tenant_constants.dart';
import '../../core/theme/app_colors.dart';
 

class TenantEmptyState extends StatelessWidget {
  final VoidCallback onReload;

  const TenantEmptyState({
    super.key,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('tenant_empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            size: TenantConstants.emptyStateIconSize,
            color: AppColors.error,
          ),
          SizedBox(height: TenantConstants.emptyStateSpacing),
          Text(
            'Nenhum município disponível.',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.authText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Verifique sua conexão ou entre em contato com o suporte.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: TenantConstants.emptyStateButtonSpacing),
          ElevatedButton.icon(
            onPressed: onReload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }
}
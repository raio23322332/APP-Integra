import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/tenant_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/tenant_model.dart';
 
class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final int index;
  final bool isLastAccessed;
  final VoidCallback onTap;

  const TenantCard({
    super.key,
    required this.tenant,
    required this.index,
    required this.isLastAccessed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('tenant_card_padding_${tenant.id}'),
      padding: EdgeInsets.only(
        left: 7,
        right: 7,
        top: index == 0 ? 8 : 0,
      ),
      child: InkWell(
        key: ValueKey('tenant_card_${tenant.id}'),
        borderRadius: BorderRadius.circular(TenantConstants.cardBorderRadius),
        onTap: onTap,
        splashColor: AppColors.authPrimary.withValues(alpha: 0.2),
        highlightColor: AppColors.authPrimary.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: TenantConstants.cardVerticalPadding,
            horizontal: TenantConstants.cardHorizontalPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              TenantConstants.cardBorderRadius,
            ),
            border: Border.all(
              color: isLastAccessed
                  ? AppColors.authPrimary
                  : AppColors.authBorder,
              width: isLastAccessed ? 2 : 1,
            ),
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
              if (isLastAccessed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.authPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Último acessado',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.authPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Container(
                    width: TenantConstants.iconContainerSize,
                    height: TenantConstants.iconContainerSize,
                    decoration: BoxDecoration(
                      color: isLastAccessed
                          ? AppColors.authPrimary
                          : AppColors.authPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isLastAccessed ? Icons.star : Icons.layers_outlined,
                      color: isLastAccessed
                          ? Colors.white
                          : AppColors.authPrimary,
                      size: TenantConstants.iconSize,
                    ),
                  ),
                  const SizedBox(width: 16), 
                  Expanded(
                    child: Text(
                      tenant.descricao ?? tenant.id,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.authText,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: TenantConstants.arrowIconSize,
                    color: Colors.grey[500],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
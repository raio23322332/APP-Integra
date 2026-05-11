import 'package:flutter/material.dart';
import '../../core/constants/tenant_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/tenant_model.dart';
import '../../providers/municipio_provider.dart';
import 'tenant_card.dart';

class TenantList extends StatelessWidget {
  final List<Tenant> tenants;
  final Tenant? lastSelectedTenant;
  final MunicipioProvider provider;
  final Future<void> Function(Tenant tenant) onSelectTenant;

  const TenantList({
    super.key,
    required this.tenants,
    required this.lastSelectedTenant,
    required this.onSelectTenant,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: const Key('tenant_list_scrollbar'),
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 6,
      radius: const Radius.circular(6),
      child: RefreshIndicator(
        key: Key('tenant_list_refresh_indicator'),
        backgroundColor: AppColors.white,
        color: AppColors.authPrimary,
        onRefresh: () => provider.init(),
        child: ListView.separated(
          key: const PageStorageKey('tenant_list_view'),
          padding: EdgeInsets.symmetric(
            horizontal: TenantConstants.listHorizontalPadding,
            vertical: TenantConstants.listVerticalPadding,
          ),
          itemCount: tenants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tenant = tenants[index];

            final isLastAccessed = index == 0 &&
                lastSelectedTenant != null &&
                tenant.id == lastSelectedTenant!.id;

            return TenantCard(
                  tenant: tenant,
                  index: index,
                  isLastAccessed: isLastAccessed,
                  onTap: () async {
                    await onSelectTenant(tenant);
                  },
               
            );
          },
        ),
      ),
    );
  }
}

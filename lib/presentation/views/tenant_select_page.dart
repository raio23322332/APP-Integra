import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:provider/provider.dart';
import '../../providers/municipio_provider.dart';
import '../../widgets/tenant/tenant_empty_state.dart';
import '../../widgets/tenant/tenant_list.dart';
import '../../widgets/tenant/tenant_no_search_results_state.dart';
import '../../widgets/tenant/tenant_search_field.dart';
import '../widgets/common/tenant_skeleton_loader.dart';

class TenantSelectPage extends StatefulWidget {
  const TenantSelectPage({super.key});

  @override
  State<TenantSelectPage> createState() => _TenantSelectPageState();
}

class _TenantSelectPageState extends State<TenantSelectPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MunicipioProvider>().init();
    });
  }

  List<Tenant> _filterTenants(
    List<Tenant> tenants,
    Tenant? lastSelectedTenant,
  ) {
    if (_searchQuery.isEmpty) return tenants;

    final query = _searchQuery.toLowerCase();

    final filtered = tenants.where((tenant) {
      return tenant.id.toLowerCase().contains(query);
    }).toList();

    if (lastSelectedTenant != null && filtered.length > 1) {
      final index = filtered.indexWhere(
        (tenant) => tenant.id == lastSelectedTenant.id,
      );

      if (index > 0) {
        final lastSelected = filtered.removeAt(index);
        filtered.insert(0, lastSelected);
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MunicipioProvider>();
    return Scaffold(
      key: const Key('tenant_select_scaffold'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.authText,
        elevation: 0,
        title: Text(
          'Selecione seu município',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authText,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<MunicipioProvider>(
        key: const Key('tenant_select_body'),
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const TenantSkeletonLoader();
          }

          final filteredTenants = _filterTenants(
            provider.tenants,
            provider.lastSelectedTenant,
          );

          return Column(
            children: [
              TenantSearchField(
                value: _searchQuery,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              Expanded(
                child: filteredTenants.isEmpty
                    ? _searchQuery.isEmpty
                        ? TenantEmptyState(
                            onReload: provider.init,
                          )
                        : TenantNoSearchResultsState(
                            onClearSearch: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                    : TenantList(
                        tenants: filteredTenants,
                        lastSelectedTenant: provider.lastSelectedTenant,
                        onSelectTenant: provider.selectAndSaveTenant,
                        provider: provider,
                      ),
                    
              ),
            ],
          );
        },
      ),
    );
  }
}

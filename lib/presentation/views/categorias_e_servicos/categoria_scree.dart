import 'dart:async';
import 'package:flutter/material.dart';
import 'package:integra_app/core/utils/icon_mapper.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/data/models/tenant_model.dart';
import 'package:integra_app/presentation/viewmodels/categorias_e_servicos/categories_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/custom_snack_bar.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:provider/provider.dart';

import 'services_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final Tenant tenant;
  final String token;

  const CategoriesScreen({
    required this.tenant,
    required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoriesViewModel(),
      child: _CategoriesView(
        tenant: tenant,
        token: token,
      ),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  final Tenant tenant;
  final String token;

  const _CategoriesView({
    required this.tenant,
    required this.token,
  });

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();

    // MVVM: View chama ViewModel (não chama Service)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<CategoriesViewModel>();
      viewModel.init(
        tenant: widget.tenant,
        token: widget.token,
      );

      // ✅ PADRÃO: Ouvinte de eventos
      _eventSubscription = viewModel.events.listen(_handleEvent);
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  // ✅ PADRÃO: Handler centralizado de eventos
  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    switch (event) {
      case CategorySelectedEvent():
        // ✅ PADRÃO: Navegação via NavigationService com breadcrumbs
        NavigationService.instance.navigateToServices(context, event.category);
        break;
      case ShowSnackBarEvent():
        if (event.isError) {
          CustomSnackBar.showError(context, event.message);
        } else {
          CustomSnackBar.showSuccess(context, event.message);
        }
        break;
      default:
        debugPrint('Evento não tratado: ${event.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size; // você não estava usando
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: SafeArea(
        child: Consumer<CategoriesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.hasError) {
              return _ErrorState(
                message: viewModel.errorMessage,
                onRetry: () {
                  viewModel.loadCategories(
                    tenant: widget.tenant,
                    token: widget.token,
                    forceRefresh: true, // Força limpar cache no retry
                  );
                },
              );
            }

            if (viewModel.categories.isEmpty) {
              return const Center(child: Text('Nenhuma categoria encontrada.'));
            }

            final categories = viewModel.categories;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;

                return RefreshIndicator(
                  onRefresh: () => viewModel.loadCategories(
                    tenant: widget.tenant,
                    token: widget.token,
                    forceRefresh: true, // Força limpar cache
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 12,
                      vertical: 12,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final models.Category category = categories[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          minVerticalPadding: isTablet ? 18 : 8,
                          leading: Icon(
                            mapCategoryIcon(category.icon),
                            size: isTablet ? 30 : 22,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: isTablet ? 22 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: isTablet ? 22 : 16,
                          ),
                          onTap: () {
                            // ✅ PADRÃO: Delegação para ViewModel
                            viewModel.onCategorySelected(category);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Erro ao carregar categorias:\n$message',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

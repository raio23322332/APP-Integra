import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/data/models/favorite_model.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/breadcrumb_widget.dart';
import 'package:integra_app/core/models/breadcrumb_model.dart';
import 'package:integra_app/presentation/providers/breadcrumb_provider.dart';
import 'package:integra_app/widgets/dialogs/no_internet_dialog.dart';
import 'package:provider/provider.dart';
import '../routes/app_router.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔥 [FAVORITES_SCREEN] Iniciando FavoritesScreen do favorites_screen.dart');
    // Carrega os favoritos ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoritesAndServices();
    });
  }

  /// Carrega favoritos e depois busca dados completos dos serviços
  Future<void> _loadFavoritesAndServices() async {
    final favoriteViewModel = context.read<FavoriteViewModel>();
    
    // Verificar conexão antes de carregar dados completos
    final hasInternet = await _checkInternetConnection();
    
    if (!hasInternet) {
      // Se não tiver internet, apenas carrega os favoritos básicos do banco local
      await favoriteViewModel.loadFavorites();
      
      // Mostra aviso sobre falta de internet (opcional)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sem conexão com internet. Alguns dados podem estar incompletos.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    // Primeiro carrega os favoritos básicos
    await favoriteViewModel.loadFavorites();
    
    // Depois busca dados completos dos serviços (se tiver idService)
    await favoriteViewModel.loadFavoritesServicesData();
  }

  /// Verifica se há conexão com a internet
  Future<bool> _checkInternetConnection() async {
    try {
      // Simulação de verificação de internet
      // Em um projeto real, você usaria o pacote connectivity_plus
      // e faria uma requisição HTTP para testar a conexão
      
      // Por enquanto, vamos simular que sempre tem internet
      // Mude para 'return false;' para testar o diálogo
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : AppColors.lightBackground;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.home);
      },
      child: Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          tooltip: 'Voltar',
          padding: EdgeInsets.zero,
          splashRadius: 20,
          onPressed: () {
            // Remover apenas o último item do breadcrumb ao voltar
            final breadcrumbProvider = context.read<BreadcrumbProvider>();
            breadcrumbProvider.removeLast();
            context.go(AppRoutes.home);
          },
        ),
        titleSpacing: -16,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.lightBlue,
              ],
            ),
          ),
        ),
      ),
      
      body: Consumer<FavoriteViewModel>(
        builder: (context, viewModel, _) {
          // CONFIGURAR BREADCRUMB PARA A TELA DE FAVORITOS
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final breadcrumbProvider = context.read<BreadcrumbProvider>();
            breadcrumbProvider.setBreadcrumbs([
              const BreadcrumbItem(title: 'Home', route: '/'),
              const BreadcrumbItem(title: 'Meus Favoritos', route: '/favorites'),
            ]);
            breadcrumbProvider.sendBreadcrumbToApi();
          });

          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.favorites.isEmpty) {
            return _EmptyState(isDark: isDark);
          }

          return Column(
            children: [
              // BREADCRUMB COM PADDING CONSISTENTE
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 16, 8),
                child: BreadcrumbWidget(),
              ),

              // Título da página abaixo do breadcrumb
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'Seus serviços favoritos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightPrimaryText,
                  ),
                ),
              ),

              // Lista de favoritos
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.favorites.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final favorite = viewModel.favorites[index];
                    return _FavoriteItem(
                      favorite: favorite,
                      isDark: isDark,
                      onTap: () async {
                        // Verificar conexão com internet antes de acessar o serviço
                        final hasInternet = await _checkInternetConnection();
                        
                        if (!mounted) return;
                        
                        if (!hasInternet) {
                          await NoInternetDialog.show(
                            context: context,
                            customMessage: 'Você precisa estar conectado à internet para acessar este serviço.',
                          );
                          return;
                        }
                        
                        // Navegar para o serviço com dados completos se disponíveis
                        if (favorite.idService != null) {
                          final servicesCache = context.read<FavoriteViewModel>().servicesCache;
                          final fullService = servicesCache[favorite.idService];
                          
                          if (fullService != null) {
                            // Navega com dados completos do serviço
                            context.push('/service-detail', extra: {
                              'service': fullService,
                              'category': fullService.category,
                            });
                            debugPrint('🧭 Navegando com dados completos do serviço: ${fullService.title}');
                            return;
                          }
                        }
                        
                        // Fallback: navega com dados básicos do favorito
                        if (favorite.route.isNotEmpty) {
                          context.push(favorite.route);
                          debugPrint('🧭 Navegando com rota básica: ${favorite.route}');
                        }
                      },
                      onRemove: () async {
                        // Confirmar remoção
                        final shouldRemove = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remover Favorito'),
                            content: Text('Deseja remover "${favorite.serviceName}" dos favoritos?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Remover'),
                              ),
                            ],
                          ),
                        );

                        if (!mounted) return;

                        if (shouldRemove == true) {
                          await viewModel.toggleFavorite(favorite);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final Favorite favorite;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteItem({
    required this.favorite,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone do serviço
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informações do serviço
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        favorite.serviceName,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (favorite.title != null && favorite.title!.isNotEmpty)
                        Text(
                          favorite.title!,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                
                // Botão de remover
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: onRemove,
                  tooltip: 'Remover dos favoritos',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhum favorito encontrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione serviços aos favoritos para acessá-los rapidamente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

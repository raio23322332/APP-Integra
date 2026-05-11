import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/config/flavor_config.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'login_status_widget.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({required this.child, super.key});
  static const List<String> _navBarDestinations = [
    AppRoutes.home,
    AppRoutes.secondaryProfile,
    AppRoutes.favorites,
    AppRoutes.search,
  ];
  void _onItemTapped(BuildContext context, int index) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final targetRoute = _navBarDestinations[index];
    
    if (currentLocation != targetRoute) {
      // Sempre usa go para navegação principal da BottomNavigationBar
      // Isso evita problemas com pilha de navegação e duplo clique
      context.go(targetRoute);
    }
  }

  String _normalizeLocation(String location) {
    return location.split('?').first;
  }

  int _getCorrectTabIndex(String location) {
    final baseLocation = _normalizeLocation(location);
    debugPrint('🧭 [ScaffoldWithNavBar] Calculando índice para rota: $location');
    
    // Se for uma rota principal exata, retorna o índice correspondente
    if (_navBarDestinations.contains(baseLocation)) {
      final index = _navBarDestinations.indexOf(baseLocation);
      debugPrint('🧭 [ScaffoldWithNavBar] Rota principal encontrada, índice: $index');
      return index;
    }
    
    // Se for sub-rota, determina qual aba principal deve estar ativa
    if (baseLocation.startsWith('/protocolos') || 
        baseLocation.startsWith('/setores') ||
        baseLocation.startsWith(AppRoutes.profile) ||
        baseLocation.startsWith(AppRoutes.secondaryProfile) ||
        baseLocation.contains('edit') ||
        baseLocation.contains('security')) {
      final index = _navBarDestinations.indexOf(AppRoutes.secondaryProfile);
      debugPrint('🧭 [ScaffoldWithNavBar] Sub-rota de perfil, índice: $index');
      return index;
    } else if (baseLocation.startsWith(AppRoutes.favorites)) {
      final index = _navBarDestinations.indexOf(AppRoutes.favorites);
      debugPrint('🧭 [ScaffoldWithNavBar] Sub-rota de favoritos, índice: $index');
      return index;
    } else if (baseLocation.startsWith(AppRoutes.search)) {
      final index = _navBarDestinations.indexOf(AppRoutes.search);
      debugPrint('🧭 [ScaffoldWithNavBar] Sub-rota de busca, índice: $index');
      return index;
    }
    
    // Default para Home
    final index = _navBarDestinations.indexOf(AppRoutes.home);
    debugPrint('🧭 [ScaffoldWithNavBar] Default para Home, índice: $index');
    return index;
  }

  String _getParentRoute(String currentLocation) {
    // Determina qual rota principal voltar com base na sub-rota atual
    if (currentLocation.startsWith('/protocolos') || 
        currentLocation.startsWith('/setores') ||
        currentLocation.startsWith('/profile') ||
        currentLocation.startsWith(AppRoutes.secondaryProfile) ||
        currentLocation.contains('edit') ||
        currentLocation.contains('security')) {
      return AppRoutes.secondaryProfile;
    } else if (currentLocation.startsWith('/favorites')) {
      return AppRoutes.favorites;
    } else if (currentLocation.startsWith('/search')) {
      return AppRoutes.search;
    }
    // Default para Home
    return AppRoutes.home;
  }

  Future<String> _getTenantId() async {
    try {
      final domainStorage = DomainStorage();
      final tenant = await domainStorage.getSelectedTenant();
      if (tenant != null) {
        return tenant.id.toUpperCase();
      }
      final domain = await domainStorage.getSelectedDomain();
      if (domain != null) {
        return domain.split('.')[0].toUpperCase();
      }
    } catch (e) {
      debugPrint('Erro ao obter tenant: $e');
    }
    return 'INTEGRA';
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentLocation = _normalizeLocation(location);
    int currentIndex = _getCorrectTabIndex(location);
    final bool isMainRoute = _navBarDestinations.contains(currentLocation) || currentLocation == AppRoutes.profile;

    // ✅ Interceptar botão físico de voltar do Android e sempre voltar para home
    return PopScope(
      canPop: currentLocation == AppRoutes.home,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        // Se estivermos em uma das abas principais (que não seja a Home), volta para Home
        if (isMainRoute && currentLocation != AppRoutes.home) {
          context.go(AppRoutes.home);
          return;
        }
        
        // Para sub-rotas, volta para a rota pai correspondente
        if (!isMainRoute) {
          final parentRoute = _getParentRoute(currentLocation);
          context.go(parentRoute);
        }
      },
      child: Scaffold(
      appBar: isMainRoute
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 80,
                title: FutureBuilder<String>(
                    future: _getTenantId(),
                    builder: (context, snapshot) {
                      final tenantId = snapshot.data ?? 'INTEGRA';
                      return Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Image.asset(FlavorConfig.logoAsset, height: 60),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "INTEGRA",
                                        style: TextStyle(
                                          color: AppColors.darkText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        "SISTEMA DE GESTÃO DIGITAL",
                                        style: TextStyle(
                                          color: AppColors.lightPrimaryText,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        tenantId,
                                        style: const TextStyle(
                                          color: AppColors.lightPrimaryText,
                                          fontSize: 10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                actions: const [LoginStatusWidget(), SizedBox(width: 8)],
              ),
            )
          : null, // Sub-rotas controlam seu próprio AppBar
      body: child,
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          iconSize: 24,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, key: Key('nav_profile')),
              label: "Meu perfil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star, key: Key('nav_favorites')),
              label: "Favoritos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, key: Key('nav_search')),
              label: "Buscar",
            ),
          ],
        ),
      ),
      ),
    );
  }
}

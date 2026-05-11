import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/core/utils/icon_mapper.dart';
import 'package:integra_app/data/models/category_model.dart';
import 'package:integra_app/presentation/viewmodels/categorias_e_servicos/services_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/breadcrumb_widget.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/core/models/breadcrumb_model.dart';
import 'package:integra_app/presentation/providers/breadcrumb_provider.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:provider/provider.dart';

class ServicesScreen extends StatelessWidget {
  final Category category;

  const ServicesScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServicesViewModel(
        category,
        NavigationService.instance, // ✅ PADRÃO: Injeção de dependências
        FavoriteViewModel(
          domainStorage: Provider.of<DomainStorage>(context, listen: false),
        ), // ✅ PADRÃO: ViewModel de favoritos com DomainStorage
      ),
      child: const _ServicesView(),
    );
  }
}

class _ServicesView extends StatelessWidget {
  const _ServicesView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : AppColors.lightBackground;

    return Consumer<ServicesViewModel>(
      builder: (context, vm, _) {
        // CONFIGURAR BREADCRUMB PARA A TELA DE SERVIÇOS
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final breadcrumbProvider = context.read<BreadcrumbProvider>();
          breadcrumbProvider.setBreadcrumbs([
            const BreadcrumbItem(title: 'Home', route: '/'),
            BreadcrumbItem(
              title: vm.category.name,
              route: '/services',
              extra: vm.category,
            ),
          ]);
          breadcrumbProvider.sendBreadcrumbToApi();
        });

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              vm.appBarTitle.length > 20 
                  ? '${vm.appBarTitle.substring(0, 20)}...' 
                  : vm.appBarTitle,
            ),
            actions: [
              if (vm.icon.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _CategoryIcon(iconUrl: vm.icon),
                ),
            ],
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
                context.pop();
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
          
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  vm.exp,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightPrimaryText,
                  ),
                ),
              ),

              Expanded(
                child: vm.hasServices
                    ? _ServicesList(isDark: isDark)
                    : _EmptyState(
                        title: vm.emptyTitle,
                        subtitle: vm.emptySubtitle,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String iconUrl;

  const _CategoryIcon({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    // Verifica se é uma URL (começa com http) ou um nome de ícone
    if (iconUrl.startsWith('http')) {
      // Se for URL, usa o código original
      if (iconUrl.endsWith('.svg')) {
        return SvgPicture.network(
          iconUrl,
          width: 30,
          height: 30,
          placeholderBuilder: (context) => const Icon(Icons.category, color: Colors.white),
        );
      } else {
        return Image.network(
          iconUrl,
          width: 30,
          height: 30,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.category, color: Colors.white),
        );
      }
    } else {
      // Se for nome de ícone da API, usa o mapeamento
      final iconData = mapCategoryIcon(iconUrl);
      return Icon(iconData, color: Colors.white, size: 30);
    }
  }
}


class _ServicesList extends StatelessWidget {
  final bool isDark;
  const _ServicesList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesViewModel>(
      builder: (context, vm, _) {
        return Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 6,
          radius: const Radius.circular(6),
          child: ListView.separated(
            key: const PageStorageKey('services_list'),
            padding: const EdgeInsets.all(16),
            itemCount: vm.total,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = vm.services[index];

              return _ServiceListItem(
                service: service,
                isDark: isDark,
                onTap: () {
                  vm.onServiceSelected(service);
                },
                onFavoriteTap: () {
                  vm.toggleFavorite(service);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _FavoriteIcon extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteIcon({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<_FavoriteIcon> createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<_FavoriteIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FavoriteIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? Colors.red : Colors.grey.shade600,
              size: 24,
            ),
          );
        },
      ),
    );
  }
}

class _ServiceListItem extends StatelessWidget {
  final Service service;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _ServiceListItem({
    required this.service,
    required this.isDark,
    required this.onTap,
    required this.onFavoriteTap,
  });

  // Função para limitar caracteres e adicionar "..." se necessário
  String _limitText(String text, int maxLength) {
    if (text.isEmpty) return text;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trim()}...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Altura reduzida para cards mais compactos
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
            padding: const EdgeInsets.all(12), // Reduzido de 16 para 12
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _limitText(service.title, 35), // Reduzido para 35 caracteres para evitar bug
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Reduzido para melhor proporção
                        ),
                      ),
                    ),
                    _FavoriteIcon(
                      isFavorite: service.isFavorite,
                      onTap: onFavoriteTap,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          size: 14, // Reduzido para proporcional
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.timesAccessed} acessos',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 11, // Reduzido para proporcional
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          size: 14, // Reduzido para proporcional
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _limitText(service.duration, 12), // Reduzido para 12 caracteres
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 11, // Reduzido para proporcional
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 10, // Reduzido para proporcional
                        ),
                      ),
                    ),
                  ],
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
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

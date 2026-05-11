import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/search_viewmodel.dart';
import 'package:integra_app/utils/service_type_formatter.dart';
import 'package:provider/provider.dart';

/// ✅ MVVM: Widget com campo de busca e resultados integrados
/// Centraliza busca e resultados em um único componente para melhor UX
class WelcomeSectionWidget extends StatefulWidget {
  final HomeViewModel homeVM;
  final TextEditingController searchController;

  const WelcomeSectionWidget({
    super.key,
    required this.homeVM,
    required this.searchController,
  });

  @override
  State<WelcomeSectionWidget> createState() => WelcomeSectionWidgetState();
  
  // ✅ Método público para desativar campo de busca
  static void disableSearchField(GlobalKey<WelcomeSectionWidgetState> key) {
    key.currentState?.disableSearchField();
  }
}

class WelcomeSectionWidgetState extends State<WelcomeSectionWidget> {
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    // ✅ Campo inicia desativado para evitar ativação automática
    _isEnabled = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ✅ Método para desativar campo (navegação ou limpeza)
  void disableSearchField() {
    if (mounted) {
      setState(() {
        _isEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.lightBlue,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de boas-vindas
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Boas-vindas!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(blurRadius: 3, color: Colors.black12),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.searchController,
                      readOnly: !_isEnabled, // ✅ Só permite digitar quando habilitado
                      maxLength: 255,
                      onTap: () {
                        // ✅ Habilita campo apenas quando clicar
                        setState(() {
                          _isEnabled = true;
                        });
                        // Foco imediato sem delay para evitar problemas com BuildContext
                        if (mounted && _isEnabled) {
                          FocusScope.of(context).requestFocus();
                        }
                      },
                      onChanged: _isEnabled ? widget.homeVM.onSearchChanged : null, // ✅ Só funciona quando habilitado
                      decoration: const InputDecoration(
                        hintText: "Buscar serviços",
                        border: InputBorder.none,
                        counterText: '',
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.favorite, color: Colors.red),
                  //   onPressed: () => widget.homeVM.navigateToFavorites(),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ✅ Resultados da busca integrados abaixo do campo
            _buildSearchResults(),
            // Seção Destaques dentro do container azul
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Destaques para você",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // Container para os destaques com rolagem horizontal
                SizedBox(
                  height: 90,
                  child: _buildHorizontalHighlights(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Resultados da busca integrados abaixo do campo de busca
  Widget _buildSearchResults() {
    return Consumer<SearchViewModel>(
      builder: (context, searchVM, child) {
        // Se está carregando, mostra indicador simples
        if (searchVM.isLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(blurRadius: 3, color: Colors.black12),
              ],
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  "Buscando...",
                  style: TextStyle(
                    color: Color(0xFF263860),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Se houve erro, mostra mensagem simples
        if (searchVM.errorMessage.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Erro na busca: ${searchVM.errorMessage}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Se não há resultados e o usuário digitou algo, mostra mensagem
        if (searchVM.filteredServices.isEmpty) {
          // Só mostra mensagem se o usuário realmente digitou algo
          final searchQuery = widget.searchController.text.trim();
          if (searchQuery.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.search,
                          size: 32,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum serviço encontrado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Não encontramos serviços correspondentes à sua busca. Tente usar termos diferentes ou verificar a grafia.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          // Se não digitou nada, não mostra nada
          return const SizedBox.shrink();
        }

        // Mostra resultados de forma simples e acessível
        return Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(blurRadius: 3, color: Colors.black12),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dos resultados
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "${searchVM.filteredServices.length} resultado${searchVM.filteredServices.length != 1 ? 's' : ''}",
                  style: const TextStyle(
                    color: Color(0xFF263860),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Lista de resultados
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchVM.filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = searchVM.filteredServices[index];
                    return _buildSimpleResultItem(service);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Item de resultado simples e acessível
  Widget _buildSimpleResultItem(service) {
    return InkWell(
      onTap: () => widget.homeVM.onSearchResultTapped(service),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Ícone simples
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.miscellaneous_services,
                color: AppColors.primaryBlue,
                size: 16,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Color(0xFF1F2D3D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ServiceTypeFormatter.formatServiceType(service.type),
                    style: TextStyle(
                      color: const Color(0xFF263860).withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicador de navegação
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF263860).withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalHighlights() {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        final highlightItems = vm.getHighlightItems();
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: highlightItems.length,
          itemBuilder: (context, index) {
            final item = highlightItems[index];
            return Container(
              width: 90,
              margin: const EdgeInsets.only(right: 10),
              child: _buildHighlightCard(
                item.icon,
                item.title,
                item.color ?? Colors.grey,
                onTap: item.onTap,
                route: item.route,
                canFavorite: item.canFavorite,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHighlightCard(
    IconData icon,
    String text,
    Color color, {
    VoidCallback? onTap,
    String? route,
    bool canFavorite = true,
  }) {

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: canFavorite ? 5.0 : 0.0,
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            if (canFavorite)
              Positioned(
                top: 0,
                right: 0,
                child: Consumer<FavoriteViewModel>(
                  builder: (context, favoriteVM, _) {
                    final isFavorite = favoriteVM.isFavorite(text);
                    return GestureDetector(
                      onTap: () {
                        // Salva o favorito com dados específicos para navegação
                        String? slug;
                        String? title;
                        int iconCode;
                        
                        if (text == "Iluminação Pública") {
                          slug = "iluminacao-publica";
                          title = "Iluminação Pública";
                          iconCode = Icons.lightbulb.codePoint;
                        } else if (text == "Pavimentação") {
                          slug = "pavimentacao";
                          title = "Pavimentação";
                          iconCode = Icons.construction.codePoint;
                        } else if (text == "Poda de Árvore") {
                          slug = "poda-de-arvore";
                          title = "Poda de Árvore";
                          iconCode = FontAwesomeIcons.tree.codePoint;
                        } else if (text == "Limpeza Pública") {
                          slug = "limpeza-publica";
                          title = "Limpeza Pública";
                          iconCode = Icons.cleaning_services.codePoint;
                        } else {
                          iconCode = icon.codePoint; // Usa o ícone original
                        }
                        
                        favoriteVM.toggleFavoriteByData(
                          serviceName: text,
                          route: route ?? '',
                          iconCodePoint: iconCode,
                          slug: slug,
                          title: title,
                        );
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

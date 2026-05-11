import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:provider/provider.dart';

/// ✅ MVVM: Widget separado para o grid de destaques
/// Centraliza lógica de UI, remove duplicação de código
class HighlightGridWidget extends StatelessWidget {
  const HighlightGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: vm.getHighlightItems().map((item) {
            return _buildHighlightCard(
              item.icon,
              item.title,
              item.color ?? Colors.grey,
              onTap: item.onTap,
              route: item.route,
              canFavorite: item.canFavorite,
            );
          }).toList(),
        ),
      ),
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
          color: color,
          borderRadius: BorderRadius.circular(10),
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
                      style: const TextStyle(color: Colors.white, fontSize: 11),
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

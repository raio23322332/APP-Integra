import 'package:flutter/material.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:integra_app/core/utils/icon_mapper.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/data/models/favorite_model.dart';

/// ✅ MVVM: Widget para a lista de categorias
/// Centraliza lógica de categorias dinâmicas da API
class CategoryListWidget extends StatelessWidget {
  final HomeViewModel homeVM;

  const CategoryListWidget({
    super.key,
    required this.homeVM,
  });

  @override
  Widget build(BuildContext context) {
    final dynamicCategories = homeVM.categories;

    return Column(
      children: [
        // Categorias dinâmicas da API - ✅ AGORA PODEM SER FAVORITADAS
        if (homeVM.isLoadingCategories && dynamicCategories.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (homeVM.categoriesError != null && dynamicCategories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Erro ao carregar categorias: ${homeVM.categoriesError}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        else
          ...dynamicCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return _buildCategoryItem(
              context,
              mapCategoryIcon(category.icon),
              category.name,
              _getCategoryColor(index), // Usar cores do app
              onTap: () => homeVM.onCategoryTapped(category),
              categoryId: category.id,
              canFavorite: true,
            );
          }),
      ],
    );
  }

  Color _getCategoryColor(int index) {
    // Todas as categorias usam a mesma cor azul principal
    return const Color(0xFF28669b);
  }

  Widget _buildCategoryItem(
    BuildContext context,
    IconData? icon,
    String text,
    Color color, {
    VoidCallback? onTap,
    int? categoryId,
    bool? canFavorite = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone grande do lado esquerdo - círculo com cor do app
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), // Fundo com cor da categoria
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon ?? Icons.category,
                color: color, // Ícone com cor da categoria
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/data/models/favorite_model.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔥🔥🔥 [VERSÃO 2025] initState NOVO - ÍCONES CORRIGIDOS 🔥🔥🔥');
    // Carrega os favoritos quando a tela é criada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoriteViewModel = Provider.of<FavoriteViewModel>(context, listen: false);
      favoriteViewModel.loadFavorites();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega favoritos quando a tela se torna visível novamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoriteViewModel = Provider.of<FavoriteViewModel>(context, listen: false);
      favoriteViewModel.loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final favoriteViewModel = Provider.of<FavoriteViewModel>(context, listen: false);
              favoriteViewModel.loadFavorites();
            },
          ),
        ],
      ),
      body: favoriteViewModel.isLoading
          ? const AppLoader()
          : favoriteViewModel.favorites.isEmpty
          ? Center(
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
                    'Você ainda não tem favoritos.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Toque no coração para adicionar um serviço.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favoriteViewModel.favorites.length,
              itemBuilder: (context, index) {
                final favorite = favoriteViewModel.favorites[index];
                return _buildFavoriteItem(context, favorite, favoriteViewModel);
              },
            ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    Favorite favorite,
    FavoriteViewModel viewModel,
  ) {
    debugPrint('🔥🔥🔥 [VERSÃO FINAL] Nome: "${favorite.serviceName}"');
    
    // ✅ FORÇA ÍCONES PELO NOME - 100% GARANTIDO
    IconData iconData;
    final nome = favorite.serviceName.toLowerCase();
    
    if (nome.contains('poda') || nome.contains('árvore')) {
      iconData = FontAwesomeIcons.tree;
      debugPrint('✅ PODA: FontAwesomeIcons.tree');
    } else if (nome.contains('ilumina') || nome.contains('luz')) {
      iconData = FontAwesomeIcons.road;
      debugPrint('✅ ILUMINAÇÃO: FontAwesomeIcons.road');
    } else if (nome.contains('buraco')) {
      iconData = FontAwesomeIcons.road;
      debugPrint('✅ BURACO: FontAwesomeIcons.road');
    } else if (nome.contains('cnh')) {
      iconData = FontAwesomeIcons.carSide;
      debugPrint('✅ CNH: FontAwesomeIcons.carSide');
    } else if (nome.contains('identidade') || nome.contains('carteira')) {
      iconData = FontAwesomeIcons.fingerprint;
      debugPrint('✅ IDENTIDADE: FontAwesomeIcons.fingerprint');
    } else if (nome.contains('veículo') || nome.contains('veiculo')) {
      iconData = Icons.drive_eta;
      debugPrint('✅ VEÍCULOS: Icons.drive_eta');
    } else if (nome.contains('mulher')) {
      iconData = Icons.person;
      debugPrint('✅ MULHER: Icons.person');
    } else if (nome.contains('educação') || nome.contains('educacao')) {
      iconData = Icons.school;
      debugPrint('✅ EDUCAÇÃO: Icons.school');
    } else if (nome.contains('trabalho') || nome.contains('emprego')) {
      iconData = Icons.work;
      debugPrint('✅ TRABALHO: Icons.work');
    } else if (nome.contains('agro')) {
      iconData = Icons.agriculture;
      debugPrint('✅ AGRO: Icons.agriculture');
    } else {
      // Para categorias da API
      iconData = Icons.star;
      debugPrint('✅ API: Icons.star (fallback)');
    }

    debugPrint('🎯 FINAL: $iconData');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.lightBackground,
      child: ListTile(
        leading: Icon(iconData, color: AppColors.primaryBlue, size: 30),
        title: Text(
          favorite.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(favorite.route),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => viewModel.toggleFavorite(favorite),
        ),
        onTap: () {
          if (favorite.route.startsWith('/')) {
            try {
              context.go(favorite.route);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rota não encontrada: ${favorite.route}'),
                  backgroundColor: AppColors.orange,
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navegação não disponível para esta categoria'),
                backgroundColor: AppColors.orange,
              ),
            );
          }
        },
      ),
    );
  }
}

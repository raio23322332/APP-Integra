import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/core/utils/icon_mapper.dart';
import 'package:provider/provider.dart';

/// ✅ MVVM: Widget para mostrar serviços mais acessados
/// Usa os dados do HomeViewModel (já carregados das categorias)
class AccessGridWidget extends StatelessWidget {
  const AccessGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeVM, child) {
        final mostAccessedServices = homeVM.mostAccessedServices;

        if (mostAccessedServices.isEmpty) {
          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: 5,
              itemBuilder: (context, index) => _buildPlaceholderCard(),
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: mostAccessedServices.length,
            itemBuilder: (context, index) {
              final service = mostAccessedServices[index];
              return _buildServiceCard(service, homeVM);
            },
          ),
        );
      },
    );
  }

  Widget _buildServiceCard(models.Service service, HomeViewModel homeVM) {
    // ✅ Obtém o ícone da categoria usando o novo método do HomeViewModel
    final categoryIcon = homeVM.getServiceCategoryIcon(service);
    debugPrint('🔍 [AccessGrid] Serviço: ${service.title}, Ícone da categoria: $categoryIcon');
    
    // ✅ Usa mapCategoryIcon para converter o nome do ícone da categoria para IconData
    IconData serviceIcon = mapCategoryIcon(categoryIcon ?? 'category');
    
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 15),
      child: _buildAccessCard(
        serviceIcon,
        service.title,
        const Color(0xFF28669b),
        onTap: () {
          debugPrint('🖱️ Clicou no serviço: ${service.title}');
          
          // Usa o método do HomeViewModel para navegar
          homeVM.onMostAccessedServiceTapped(service);
        },
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 15),
      child: _buildAccessCard(
        FontAwesomeIcons.ellipsis,
        "Carregando...",
        Colors.grey,
      ),
    );
  }

  Widget _buildAccessCard(
    IconData icon, 
    String title, 
    Color color, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

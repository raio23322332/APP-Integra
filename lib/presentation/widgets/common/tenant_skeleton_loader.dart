import 'package:flutter/material.dart';

/// Skeleton loader para a tela de seleção de tenant
/// Melhora a percepção de performance enquanto carrega dados
class TenantSkeletonLoader extends StatelessWidget {
  const TenantSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: 6, // Mostra 6 skeletons
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // Skeleton para o ícone/círculo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 16),
              // Skeleton para o texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Skeleton para o nome
                    Container(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Skeleton para a descrição (opcional)
                    Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              // Skeleton para a seta
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/models/breadcrumb_model.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:integra_app/presentation/providers/breadcrumb_provider.dart';

class BreadcrumbWidget extends StatelessWidget {
  const BreadcrumbWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BreadcrumbProvider>(
      builder: (context, provider, child) {
        final breadcrumbs = provider.breadcrumbs;
        if (breadcrumbs.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < breadcrumbs.length; i++) ...[
                  if (i > 0) ...[
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                  ],
                  _BreadcrumbItemWidget(
                    item: breadcrumbs[i],
                    isLast: i == breadcrumbs.length - 1,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BreadcrumbItemWidget extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isLast;

  const _BreadcrumbItemWidget({
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLast || item.route == null
          ? null
          : () {
              final provider = context.read<BreadcrumbProvider>();
              provider.navigateToBreadcrumb(item);
              
              // Se for Home, usa GoRouter. Para outros, usa Navigator.pop()
              if (item.title == 'Home' && item.route != null) {
                context.go(item.route!, extra: item.extra);
              } else if (item.route != null) {
                // Para outros breadcrumbs, apenas volta para a tela anterior
                Navigator.of(context).pop();
              }
            },
      child: item.title == 'Home'
            ? Icon(
                Icons.home,
                color: isLast ? AppColors.primaryBlue : const Color(0xFF2E7D32),
                size: 16,
              )
            : Text(
                item.title,
                style: TextStyle(
                  color: isLast
                      ? AppColors.primaryBlue
                      : const Color(0xFF374151),
                  fontSize: 12,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
    );
  }
}

import 'package:flutter/material.dart';

/// Modelo para representar um item genérico na Home (Destaque, Categoria, etc).
class HomeItem {
  final String title;
  final IconData icon;
  final String? route;
  final Color? color;
  final VoidCallback? onTap;
  final bool canFavorite;

  HomeItem({
    required this.title,
    required this.icon,
    this.route,
    this.color,
    this.onTap,
    this.canFavorite = true,
  });
}

// lib/presentation/widgets/common/service_card_widget.dart

import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';

/// ✅ **Card Reutilizável para Serviços**
/// Widget genérico que pode ser usado em diferentes contextos
/// Suporta modo escuro, animações e personalização completa
class ServiceCardWidget extends StatefulWidget {
  /// Título principal do card
  final String title;

  /// Subtítulo ou descrição
  final String? subtitle;

  /// Ícone principal
  final IconData icon;

  /// Cor primária do card (padrão: azul primário)
  final Color? primaryColor;

  /// Cor de fundo customizada (opcional)
  final Color? backgroundColor;

  /// Cor da borda customizada (opcional)
  final Color? borderColor;

  /// Callback quando o card é pressionado
  final VoidCallback? onTap;

  /// Se o card está desabilitado
  final bool isDisabled;

  /// Se deve mostrar animação de hover/press
  final bool enableAnimation;

  /// Altura customizada do card
  final double? height;

  /// Largura customizada do card
  final double? width;

  /// Padding interno customizado
  final EdgeInsets? padding;

  /// Border radius customizado
  final double? borderRadius;

  /// Widget customizado para a área do ícone (opcional)
  final Widget? customIconWidget;

  /// Widget customizado para a área do conteúdo (opcional)
  final Widget? customContentWidget;

  const ServiceCardWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.primaryColor,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.isDisabled = false,
    this.enableAnimation = true,
    this.height,
    this.width,
    this.padding,
    this.borderRadius,
    this.customIconWidget,
    this.customContentWidget,
  });

  @override
  State<ServiceCardWidget> createState() => _ServiceCardWidgetState();
}

class _ServiceCardWidgetState extends State<ServiceCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableAnimation && !widget.isDisabled) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableAnimation && !widget.isDisabled) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableAnimation && !widget.isDisabled) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = widget.primaryColor ?? AppColors.primaryBlue;

    // Cores adaptativas
    final backgroundColor = widget.backgroundColor ??
        (isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white);

    final borderColor = widget.borderColor ??
        (isDark ? Colors.grey.shade800 : Colors.grey.shade300);

    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Dimensões
    final borderRadius = widget.borderRadius ?? 16.0;
    final padding = widget.padding ?? const EdgeInsets.all(16);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: widget.isDisabled ? null : widget.onTap,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Opacity(
              opacity: widget.isDisabled ? 0.6 : 1.0,
              child: Container(
                height: widget.height,
                width: widget.width,
                padding: padding,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    if (!isDark && !widget.isDisabled)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: widget.customContentWidget ??
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Área do ícone - CENTRALIZADO
                        widget.customIconWidget ??
                            Container(
                              alignment: Alignment.center,
                              child: Icon(
                                widget.icon,
                                color: widget.isDisabled
                                    ? Colors.grey
                                    : primaryColor,
                                size: 36, // TAMANHO AUMENTADO PARA MELHOR VISUAL
                              ),
                            ),

                        const SizedBox(height: 12),

                        // Área do texto - CENTRALIZADA E COM MELHOR ALINHAMENTO
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: titleColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // TAMANHO REDUZIDO PARA MELHOR AJUSTE
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ✅ **Factory Methods para Cards Específicos**
class ServiceCardFactory {
  /// Card para serviços padrão
  static ServiceCardWidget service({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? primaryColor,
    bool isDark = false,
  }) {
    return ServiceCardWidget(
      title: title,
      subtitle: subtitle,
      icon: Icons.room_service,
      primaryColor: primaryColor ?? AppColors.primaryBlue,
      onTap: onTap,
    );
  }

  /// Card para categorias
  static ServiceCardWidget category({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? primaryColor,
  }) {
    return ServiceCardWidget(
      title: title,
      //subtitle: subtitle,
      icon: Icons.category,
      primaryColor: primaryColor ?? AppColors.primaryBlue,
      onTap: onTap,
    );
  }

  /// Card para funcionalidades do perfil
  static ServiceCardWidget profileFeature({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? primaryColor,
  }) {
    return ServiceCardWidget(
      title: title,
      //subtitle: subtitle,
      icon: icon,
      primaryColor: primaryColor ?? AppColors.primaryBlue,
      onTap: onTap,
    );
  }

  /// Card com estilo exato da home (Container simples)
  static ServiceCardWidget homeStyle({
    required String title,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ServiceCardWidget(
      title: '', // Não usar title padrão
      icon: Icons.help, // Não usar ícone padrão
      enableAnimation: false, // Sem animação
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade200,
      borderRadius: 10.0,
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      customIconWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center, // ALINHADO AO CENTRO
        children: [
          Icon(icon, color: iconColor ?? const Color(0xFF28669b), size: 30),
          const SizedBox(height: 6), // ESPAÇO AUMENTADO PARA MELHOR ALINHAMENTO
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14, // TAMANHO REDUZIDO PARA CABER MELHOR
            ),
          ),
        ],
      ),
    );
  }

  /// Card personalizado com widget customizado
  static ServiceCardWidget custom({
    required Widget content,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsets? padding,
  }) {
    return ServiceCardWidget(
      title: '', // Não usado quando customContentWidget é fornecido
      icon: Icons.help, // Não usado quando customIconWidget é fornecido
      customContentWidget: content,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      onTap: onTap,
    );
  }
}

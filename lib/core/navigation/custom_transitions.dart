import 'package:flutter/material.dart';

/// Transições personalizadas para navegação fluida
class CustomTransitions {
  /// Transição slide suave da direita (padrão do app)
  static PageRouteBuilder slideRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Transição fade com scale para telas modais
  static PageRouteBuilder fadeScale(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Transição material design com hero para telas de detalhe
  static PageRouteBuilder materialHero(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
    );
  }

  /// Transição slide para baixo (para webviews e modais)
  static PageRouteBuilder slideUp(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Transição bounce para telas de sucesso
  static PageRouteBuilder bounceIn(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.3,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  /// Transição rotate para telas especiais
  static PageRouteBuilder rotateIn(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(
            begin: -0.25,
            end: 0.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}

/// Enum para tipos de transição
enum PageTransitionType {
  slideRight,    // Navegação principal (padrão)
  fadeScale,     // Modais e popups
  materialHero,  // Telas de detalhe
  slideUp,       // WebViews e overlays
  bounceIn,      // Telas de sucesso
  rotateIn,      // Telas especiais
}

/// Extensão para facilitar o uso
extension PageTransitionTypeExtension on PageTransitionType {
  PageRouteBuilder buildRoute(Widget page) {
    switch (this) {
      case PageTransitionType.fadeScale:
        return CustomTransitions.fadeScale(page);
      case PageTransitionType.materialHero:
        return CustomTransitions.materialHero(page);
      case PageTransitionType.slideUp:
        return CustomTransitions.slideUp(page);
      case PageTransitionType.bounceIn:
        return CustomTransitions.bounceIn(page);
      case PageTransitionType.rotateIn:
        return CustomTransitions.rotateIn(page);
      case PageTransitionType.slideRight:
        return CustomTransitions.slideRight(page);
    }
  }
}

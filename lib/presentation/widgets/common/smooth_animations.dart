import 'package:flutter/material.dart';

/// Widget para animações suaves de entrada
class SmoothFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginOpacity;
  final Offset? slideOffset;

  const SmoothFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.beginOpacity = 0.0,
    this.slideOffset,
  });

  @override
  State<SmoothFadeIn> createState() => _SmoothFadeInState();
}

class _SmoothFadeInState extends State<SmoothFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.beginOpacity,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset ?? Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: widget.slideOffset != null
              ? SlideTransition(
                  position: _slideAnimation,
                  child: child,
                )
              : child,
        );
      },
      child: widget.child,
    );
  }
}

/// Widget para animações de scale suaves
class SmoothScaleIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginScale;

  const SmoothScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.beginScale = 0.8,
  });

  @override
  State<SmoothScaleIn> createState() => _SmoothScaleInState();
}

class _SmoothScaleInState extends State<SmoothScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Widget para animações de entrada sequencial (staggered)
class StaggeredFadeIn extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;
  final Offset? slideOffset;

  const StaggeredFadeIn({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 500),
    this.slideOffset,
  });

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = Duration(milliseconds: index * widget.staggerDelay.inMilliseconds);

        return SmoothFadeIn(
          delay: delay,
          duration: widget.itemDuration,
          slideOffset: widget.slideOffset,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Extension para adicionar animações suaves a qualquer widget
extension SmoothAnimations on Widget {
  Widget fadeIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 500),
    double beginOpacity = 0.0,
    Offset? slideOffset,
  }) {
    return SmoothFadeIn(
      delay: delay,
      duration: duration,
      beginOpacity: beginOpacity,
      slideOffset: slideOffset,
      child: this,
    );
  }

  Widget scaleIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 400),
    double beginScale = 0.8,
  }) {
    return SmoothScaleIn(
      delay: delay,
      duration: duration,
      beginScale: beginScale,
      child: this,
    );
  }
}

/// Widget para animações de pulsação suave (para botões importantes)
class SmoothPulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final double endScale;

  const SmoothPulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.beginScale = 0.95,
    this.endScale = 1.05,
  });

  @override
  State<SmoothPulse> createState() => _SmoothPulseState();
}

class _SmoothPulseState extends State<SmoothPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

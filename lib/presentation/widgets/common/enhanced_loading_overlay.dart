import 'package:flutter/material.dart';
import 'package:integra_app/presentation/widgets/common/smooth_animations_v2.dart';

enum LoadingStyle {
  shimmer,
  pulse,
  blur,
}

class EnhancedLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final String? message;
  final Widget child;
  final LoadingStyle style;
  final Duration animationDuration;

  const EnhancedLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.style = LoadingStyle.shimmer,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<EnhancedLoadingOverlay> createState() => _EnhancedLoadingOverlayState();
}

class _EnhancedLoadingOverlayState extends State<EnhancedLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(EnhancedLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
        color: Colors.black.withValues(alpha: 0.3 * _opacityAnimation.value),
                child: Center(
                  child: _buildLoadingIndicator(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    switch (widget.style) {
      case LoadingStyle.shimmer:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerLoading(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (widget.message != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );

      case LoadingStyle.pulse:
        return SmoothPulse(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (widget.message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );

      case LoadingStyle.blur:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (widget.message != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
    }
  }
}

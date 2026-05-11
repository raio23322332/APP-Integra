// ARQUIVO: lib/presentation/widgets/common/app_loader.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppLoader extends StatefulWidget {
  final String? message;
  final bool showProgress;
  final Color? color;
  final double size;
  final LoaderType type;

  const AppLoader({
    Key? key,
    this.message,
    this.showProgress = false,
    this.color,
    this.size = 40.0,
    this.type = LoaderType.circular,
  }) : super(key: key);

  @override
  State<AppLoader> createState() => _AppLoaderState();

  // Static methods for showing/hiding loader dialogs
  static void show(
    BuildContext context, {
    String? message,
    LoaderType type = LoaderType.circular,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: AppLoader(message: message ?? "Carregando...", type: type),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.color ?? AppColors.primaryBlue;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoader(effectiveColor),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoader(Color color) {
    switch (widget.type) {
      case LoaderType.circular:
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );

      case LoaderType.dots:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.3;
                final animationValue = (_animation.value + delay) % 1.0;
                final scale = 0.5 + (0.5 * sin(animationValue * 2 * pi));

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        );

      case LoaderType.pulse:
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.4 * sin(_animation.value * 2 * pi)),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.6,
                    height: widget.size * 0.6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
    }
  }
}

enum LoaderType { circular, dots, pulse }

// Extensão para facilitar o uso
extension AppLoaderExtension on Widget {
  Widget withLoader({
    required bool isLoading,
    String? loadingMessage,
    LoaderType loaderType = LoaderType.circular,
  }) {
    return Stack(
      children: [
        this,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: AppLoader(message: loadingMessage, type: loaderType),
          ),
      ],
    );
  }
}

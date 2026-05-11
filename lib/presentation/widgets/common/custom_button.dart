// ARQUIVO: lib/presentation/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors_login.dart' show AppColors;
import 'package:integra_app/core/theme/app_text_styles.dart';



class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton._({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    required this.backgroundColor,
    required this.textColor,
  });

  factory CustomButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }

  factory CustomButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton._(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: AppColors.secondary,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.button,
              ),
      ),
    );
  }
}
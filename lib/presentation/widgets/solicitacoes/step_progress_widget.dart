import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';

class StepProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const StepProgressWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Progresso da Solicitação',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              // Linha conectora horizontal
              Positioned(
                top: 19, // Centro dos círculos (40/2 - 2/2)
                left: 40,
                right: 40,
                child: Container(
                  height: 2,
                  color: Colors.grey.shade300,
                ),
              ),
              // Linha conectora preenchida
              Positioned(
                top: 19,
                left: 40,
                right: 40,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final progress = currentStep / (totalSteps - 1);
                    final filledWidth = constraints.maxWidth * progress;
                    return Container(
                      height: 2,
                      width: filledWidth,
                      color: AppColors.primaryBlue,
                    );
                  },
                ),
              ),
              // Círculos e títulos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < currentStep;
                  final isCurrent = index == currentStep;

                  return Column(
                    children: [
                      // Número da etapa
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? AppColors.primaryBlue
                              : isCurrent
                                  ? AppColors.primaryBlue.withValues(alpha: 0.2)
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                          border: isCurrent
                              ? Border.all(color: AppColors.primaryBlue, width: 3)
                              : Border.all(color: Colors.grey.shade400, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? AppColors.primaryBlue
                                        : Colors.grey.shade600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Título da etapa
                      SizedBox(
                        width: 80,
                        child: Text(
                          stepTitles[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: isCompleted || isCurrent
                                ? AppColors.primaryBlue
                                : Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

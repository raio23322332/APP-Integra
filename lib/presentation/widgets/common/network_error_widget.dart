import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget de erro padronizado para quando não há conexão com a internet
/// Baseado na imagem de referência com ícone Wi-Fi cortado
class NetworkErrorWidget extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone Wi-Fi com linha cortada (estilo da imagem)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.wifi,
                    size: 48,
                    color: Colors.green,
                  ),
                  // Linha diagonal cortando o Wi-Fi
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Transform.rotate(
                      angle: -0.785, // -45 degrees
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Título do erro
            const Text(
              'Ocorreu um erro!',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mensagem de erro
            Text(
              customMessage ?? 
              'Não foi possível carregar as informações. Verifique sua conexão com a internet e tente novamente mais tarde.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            
            // Botão de retry (opcional)
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

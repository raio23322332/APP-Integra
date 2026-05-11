// presentation/widgets/solicitacoes/solicitacao_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/solicitacao_model.dart';
import '../../../core/theme/status_styles.dart';

class SolicitacaoCard extends StatelessWidget {
  final SolicitacaoModel item;
  final VoidCallback? onTap;

  const SolicitacaoCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusStyle = statusMap[item.status] ?? defaultStatus;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra lateral de status
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusStyle.color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Código + Status badge
                    Row(
                      children: [
                        Text(
                          item.codigo ?? '—',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusStyle.background,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusStyle.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusStyle.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Detalhes inferiores: data, subtipo, arquivos + ícone
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.dataBr.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.authText,
                                ),
                              ),
                              if (item.subtipo != null)
                                Text(
                                  item.subtipo!.descricao ?? '—',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.authText,
                                  ),
                                ),
                              if (item.arquivos != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'arquivos: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.authText,
                                      ),
                                    ),
                                    Text(
                                      item.arquivos!.length.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.authText,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors.authText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

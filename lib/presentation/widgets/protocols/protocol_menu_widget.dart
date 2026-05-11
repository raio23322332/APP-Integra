// presentation/widgets/protocols/protocol_menu_widget.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../views/protocol_edit_screen.dart';
import '../../views/protocol_forward_screen.dart';
import '../../views/protocol_receive_screen.dart';
import '../../views/protocol_comment_screen.dart';
import '../../../data/models/protocol_model.dart';
import '../../../services/http/protocol_http.dart';
import '../../../ui/widgets/confirmation_dialog.dart';

class ProtocolMenuWidget extends StatelessWidget {
  final ProtocolModel protocol;

  const ProtocolMenuWidget({
    super.key,
    required this.protocol,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      key: const Key('protocol_menu_button'),
      icon: const Icon(Icons.more_vert, color: AppColors.primaryBlue),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProtocolEditScreen(protocol: protocol))
            );
            break;
          case 'forward':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProtocolForwardScreen(protocol: protocol))
            );
            break;
          case 'receive':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProtocolReceiveScreen(protocol: protocol))
            );
            break;
          case 'comment':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProtocolCommentScreen(protocol: protocol))
            );
            break;
          case 'cancel':
            if (protocol.status == 'ATIVO') {
              _showCancelDialog(context);
            }
            break;
          case 'archive':
            if (protocol.status == 'ATIVO') {
              _showArchiveDialog(context);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        _buildMenuItem(
          value: 'edit',
          icon: Icons.edit_outlined,
          color: AppColors.primaryBlue,
          title: 'Editar',
          subtitle: 'Alterar informações do protocolo',
        ),
        _buildMenuItem(
          value: 'forward',
          icon: Icons.send_outlined,
          color: Colors.blue,
          title: 'Tramitar',
          subtitle: 'Enviar para outro setor',
        ),
        _buildMenuItem(
          value: 'receive',
          icon: Icons.inbox_outlined,
          color: Colors.green,
          title: 'Receber',
          subtitle: 'Confirmar recebimento',
        ),
        _buildMenuItem(
          value: 'comment',
          icon: Icons.comment_outlined,
          color: Colors.orange,
          title: 'Comentar',
          subtitle: 'Adicionar observação',
        ),
        if (protocol.status == 'ATIVO') ...[
          const PopupMenuDivider(),
          _buildMenuItem(
            value: 'cancel',
            icon: Icons.cancel_outlined,
            color: Colors.red,
            title: 'Cancelar',
            subtitle: 'Cancelar protocolo',
            isDangerous: true,
          ),
          _buildMenuItem(
            value: 'archive',
            icon: Icons.archive_outlined,
            color: Colors.amber,
            title: 'Arquivar',
            subtitle: 'Arquivar protocolo',
            isWarning: true,
          ),
        ],
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    bool isDangerous = false,
    bool isWarning = false,
  }) {
    return PopupMenuItem(
      key: Key('protocol_menu_item_$value'),
      value: value,
      child: Row(
        key: Key('protocol_menu_item_row_$value'),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDangerous ? Colors.red : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDangerous 
                        ? Colors.red[300] 
                        : isWarning 
                            ? Colors.amber[300] 
                            : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    if (protocol.status == 'CANCELADO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Protocolo já está cancelado'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmationDialog(
        title: 'Cancelar Protocolo',
        subtitle: 'Protocolo ${protocol.number}',
        message: 'Deseja realmente cancelar este protocolo? Esta ação não pode ser desfeita.',
        icon: Icons.cancel_outlined,
        iconColor: Colors.red,
        confirmText: 'Confirmar',
        cancelText: 'Voltar',
        confirmColor: Colors.red,
        showInputField: true,
        inputLabel: 'Motivo do cancelamento',
        inputHint: 'Digite o motivo do cancelamento...',
        inputRequired: true,
        onConfirm: (reason) async {
          await ProtocolHttp().cancelProtocol(protocol.id, reason: reason!);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Protocolo cancelado com sucesso!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    if (protocol.status == 'ARQUIVADO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Protocolo já está arquivado'), backgroundColor: Colors.orange),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConfirmationDialog(
        title: 'Arquivar Protocolo',
        subtitle: 'Protocolo ${protocol.number}',
        message: 'Deseja arquivar este protocolo? Ele será movido para o arquivo morto.',
        icon: Icons.archive_outlined,
        iconColor: Colors.amber,
        confirmText: 'Arquivar',
        cancelText: 'Voltar',
        confirmColor: Colors.amber,
        showInputField: true,
        inputLabel: 'Justificativa (opcional)',
        inputHint: 'Digite uma justificativa para o arquivamento...',
        inputRequired: false,
        onConfirm: (message) async {
          await ProtocolHttp().archiveProtocol(protocol.id, message: message);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Protocolo arquivado com sucesso!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../data/models/protocol_model.dart';

/// Componente reutilizável para exibir um protocolo em formato de card
/// Responsabilidade: Apenas apresentação do protocolo
class ProtocolCard extends StatelessWidget {
  final ProtocolModel protocol;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onArchive;
  final VoidCallback? onEdit;
  final VoidCallback? onAppendix;
  final VoidCallback? onForward;
  final VoidCallback? onReceive;

  const ProtocolCard({
    super.key,
    required this.protocol,
    required this.onTap,
    this.onCancel,
    this.onArchive,
    this.onEdit,
    this.onAppendix,
    this.onForward,
    this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(protocol.status);
    
    return Card(
      key: ValueKey('protocol_card_widget_${protocol.id}'),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        key: ValueKey('protocol_card_inkwell_${protocol.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(statusColor),
              const SizedBox(height: 12),
              _buildMetadata(),
              _buildFlags(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Cabeçalho com status e informações principais
  Widget _buildHeader(Color statusColor) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(protocol.status),
            color: statusColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                protocol.number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                protocol.subject,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            protocol.status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Metadados do protocolo
  Widget _buildMetadata() {
    return Row(
      children: [
        if (protocol.sector != null) ...[
          const Icon(Icons.business, size: 16),
          const SizedBox(width: 4),
          Text(protocol.sector!.name),
          const SizedBox(width: 16),
        ],
        Icon(Icons.calendar_today, size: 16),
        const SizedBox(width: 4),
        Text(_formatDate(protocol.createdAt)),
        if (protocol.isConfidential || protocol.isEmergency) ...[
          const SizedBox(width: 16),
          if (protocol.isConfidential) ...[
            const Icon(Icons.lock, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            const Text('Confidencial', style: TextStyle(color: Colors.red)),
          ],
          if (protocol.isConfidential && protocol.isEmergency)
            const SizedBox(width: 8),
          if (protocol.isEmergency) ...[
            const Icon(Icons.priority_high, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            const Text('Urgente', style: TextStyle(color: Colors.orange)),
          ],
        ],
      ],
    );
  }

  /// Indicadores especiais
  Widget _buildFlags() {
    if (!protocol.isConfidential && !protocol.isEmergency) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (protocol.isConfidential) ...[
            const Icon(Icons.lock, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            const Text('Confidencial', style: TextStyle(color: Colors.red)),
          ],
          if (protocol.isConfidential && protocol.isEmergency)
            const SizedBox(width: 8),
          if (protocol.isEmergency) ...[
            const Icon(Icons.priority_high, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            const Text('Urgente', style: TextStyle(color: Colors.orange)),
          ],
        ],
      ),
    );
  }

  /// Botões de ação (cancelar/arquivar/editar/apensar/encaminhar/receber)
  Widget _buildActions() {
    final hasAnyAction = onCancel != null || onArchive != null || onEdit != null || 
                         onAppendix != null || onForward != null || onReceive != null;
    
    if (!hasAnyAction) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Editar',
                color: Colors.blue,
              ),
            if (onAppendix != null)
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: onAppendix,
                tooltip: 'Apensar',
                color: Colors.purple,
              ),
            if (onForward != null)
              IconButton(
                icon: const Icon(Icons.forward),
                onPressed: onForward,
                tooltip: 'Tramitar',
                color: Colors.teal,
              ),
            if (onReceive != null)
              IconButton(
                icon: const Icon(Icons.inbox),
                onPressed: onReceive,
                tooltip: 'Receber',
                color: Colors.indigo,
              ),
            if (onCancel != null)
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: onCancel,
                tooltip: 'Cancelar',
                color: Colors.red,
              ),
            if (onArchive != null)
              IconButton(
                icon: const Icon(Icons.archive),
                onPressed: onArchive,
                tooltip: 'Arquivar',
                color: Colors.orange,
              ),
          ],
        ),
      ],
    );
  }

  /// Obtém cor baseada no status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ATIVO': return Colors.green;
      case 'CANCELADO': return Colors.red;
      case 'ARQUIVADO': return Colors.orange;
      default: return Colors.grey;
    }
  }

  /// Obtém ícone baseado no status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ATIVO': return Icons.check_circle;
      case 'CANCELADO': return Icons.cancel;
      case 'ARQUIVADO': return Icons.archive;
      default: return Icons.help;
    }
  }

  /// Formata data para exibição
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

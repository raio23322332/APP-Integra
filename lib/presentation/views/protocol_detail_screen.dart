import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../data/models/protocol_model.dart';
import '../../data/models/protocol_appendix_model.dart';
import '../../data/models/protocol_attachment_model.dart';
import 'attachment_preview_screen.dart';
import '../viewmodels/protocol/protocol_viewmodel.dart';
import '../../../services/http/protocol_http.dart';
import '../../../services/shared_preference_service.dart';
import '../../ui/widgets/attachment_upload_widget.dart';
import '../../ui/widgets/create_appendix_dialog.dart';
import '../../ui/widgets/confirmation_dialog.dart';
import 'protocol_edit_screen.dart';

import 'protocol_forward_screen.dart';
import 'protocol_receive_screen.dart';
import 'protocol_comment_screen.dart';

class ProtocolDetailScreen extends StatefulWidget {
  final ProtocolModel protocol;

  const ProtocolDetailScreen({super.key, required this.protocol});

  @override
  State<ProtocolDetailScreen> createState() => _ProtocolDetailScreenState();
}

class _ProtocolDetailScreenState extends State<ProtocolDetailScreen> {
  late final ProtocolViewModel _viewModel;
  late final ProtocolHttp _protocolHttp;
  final SharedPreferenceService _pref = SharedPreferenceService();
  bool _loading = false;
  List<ProtocolAppendixModel> _appendices = [];
  List<ProtocolAttachmentModel> _attachments = [];
  List<ProtocolMovementModel> _movements = []; // ✅ Adicionar movimentações

  @override
  void initState() {
    super.initState();
    _viewModel = ProtocolViewModel(ProtocolHttp(), context.read(), context.read());
    _protocolHttp = ProtocolHttp();
    _loadAppendicesAndAttachments();
    _loadMovements(); // ✅ Carregar movimentações
  }

  Future<void> _loadAppendicesAndAttachments() async {
    setState(() => _loading = true);
    try {
      // Carregar apensos
      final appendices = await _protocolHttp.getAppendices(widget.protocol.id);

      // Carregar anexos do protocolo principal
      final attachments = await _protocolHttp.getAttachments(widget.protocol.id);

      // Para cada apenso, carregar seus anexos específicos
      final updatedAppendices = <ProtocolAppendixModel>[];
      for (var appendix in appendices) {
        try {
          final appendixAttachments = await _protocolHttp.getAttachments(widget.protocol.id, appendixId: appendix.id);
          // Criar novo apenso com anexos atualizados
          final updatedAppendix = ProtocolAppendixModel(
            id: appendix.id,
            protocolId: appendix.protocolId,
            orderNumber: appendix.orderNumber,
            code: appendix.code,
            title: appendix.title,
            documentType: appendix.documentType,
            notes: appendix.notes,
            sectorId: appendix.sectorId,
            createdBy: appendix.createdBy,
            createdAt: appendix.createdAt,
            updatedAt: appendix.updatedAt,
            sector: appendix.sector,
            attachments: appendixAttachments,
          );
          updatedAppendices.add(updatedAppendix);
        } catch (e) {
          // Se falhar, adicionar o apenso original
          updatedAppendices.add(appendix);
          debugPrint('Erro ao carregar anexos do apenso ${appendix.id}: $e');
        }
      }

      setState(() {
        _appendices = updatedAppendices;
        _attachments = attachments;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar apensos e anexos: $e')),
      );
    }
  }

  Future<void> _loadMovements() async {
    // ✅ Usar movements do protocolo (igual ao web)
    if (widget.protocol.movements != null) {
      if (mounted) {
        setState(() => _movements = widget.protocol.movements!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        key: Key('protocol_detail_scaffold_${widget.protocol.id}'),
        appBar: AppBar(
          title: Text('Protocolo ${widget.protocol.number}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            if (widget.protocol.status != 'CANCELADO' && widget.protocol.status != 'ARQUIVADO')
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'forward',
                    child: Row(
                      children: [
                        Icon(Icons.send, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Tramitar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'receive',
                    child: Row(
                      children: [
                        Icon(Icons.inbox, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Receber'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'comment',
                    child: Row(
                      children: [
                        Icon(Icons.comment, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Comentar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cancelar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Arquivar'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                key: Key('protocol_detail_scroll_${widget.protocol.id}'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProtocolInfo(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Informações Básicas'),
                    _buildBasicInfo(),
                    const SizedBox(height: 24),
                    if (widget.protocol.notes != null && widget.protocol.notes!.isNotEmpty) ...[
                      _buildSectionTitle('Observações'),
                      _buildNotes(),
                      const SizedBox(height: 24),
                    ],
                    if (widget.protocol.originProtocol != null || widget.protocol.originAgency != null) ...[
                      _buildSectionTitle('Dados de Origem'),
                      _buildOriginInfo(),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionTitle('Classificação'),
                    _buildClassification(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Anexos'),
                    _buildAttachments(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Apensos / Subdocumentos'),
                    _buildAppendices(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Histórico de Movimentações'),
                    _buildMovements(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProtocolInfo() {
    return Card(
      key: Key('protocol_info_card_${widget.protocol.id}'),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.protocol.number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  widget.protocol.status == 'ATIVO' ? Icons.check_circle : Icons.cancel,
                  color: widget.protocol.status == 'ATIVO' ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.protocol.status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: widget.protocol.status == 'ATIVO' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      key: Key('protocol_basic_info_card_${widget.protocol.id}'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Setor', widget.protocol.sector?.name ?? 'N/A'),
            _buildInfoRow('Direção', widget.protocol.direction),
            _buildInfoRow('Tipo de Documento', widget.protocol.documentType ?? 'N/A'),
            _buildInfoRow('Assunto', widget.protocol.subject ?? 'N/A'),
            _buildInfoRow('Data de Registro', _formatDate(widget.protocol.registeredAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes() {
    return Card(
      key: Key('protocol_notes_card_${widget.protocol.id}'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.protocol.notes ?? '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildOriginInfo() {
    return Card(
      key: Key('protocol_origin_info_card_${widget.protocol.id}'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Protocolo de Origem', widget.protocol.originProtocol ?? 'N/A'),
            _buildInfoRow('Órgão de Origem', widget.protocol.originAgency ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildClassification() {
    return Card(
      key: Key('protocol_classification_card_${widget.protocol.id}'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildClassificationItem(
                'Sigiloso',
                widget.protocol.isConfidential ?? false,
                Icons.lock,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildClassificationItem(
                'Emergência',
                widget.protocol.isEmergency ?? false,
                Icons.warning,
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationItem(String label, bool value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: value ? color : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: value ? color.withOpacity(0.1) : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? color : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: value ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovements() {
    return Card(
      key: Key('protocol_movements_card_${widget.protocol.id}'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Histórico de Movimentações',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_movements.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_movements.length}',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_movements.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history, color: Colors.grey, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhuma movimentação registrada',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _movements.asMap().entries.map((entry) {
                  final index = entry.key;
                  final movement = entry.value;
                  return _buildMovementTimelineItem(movement, index == _movements.length - 1);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementTimelineItem(ProtocolMovementModel movement, bool isLast) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Container(
            width: 2,
            height: 80,
            decoration: BoxDecoration(
              color: isLast ? Colors.transparent : _getMovementColor(movement.action),
              borderRadius: BorderRadius.circular(1),
            ),
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _getMovementColor(movement.action), width: 2),
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getMovementColor(movement.action),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _getMovementColor(movement.action),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getMovementIcon(movement.action),
                            color: _getMovementColor(movement.action),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getMovementLabel(movement.action),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getMovementColor(movement.action),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDateTime(movement.movedAt),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (movement.message != null && movement.message!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      movement.message ?? '',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (movement.movedBy.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Por: ${movement.movedBy}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMovementColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'REGISTERED':
        return Colors.green;
      case 'FORWARDED':
        return Colors.blue;
      case 'RECEIVED':
        return Colors.orange;
      case 'COMMENT':
        return Colors.purple;
      case 'CANCELED':
        return Colors.red;
      case 'ARCHIVED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getMovementIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'REGISTERED':
        return Icons.check_circle;
      case 'FORWARDED':
        return Icons.send;
      case 'RECEIVED':
        return Icons.inbox;
      case 'COMMENT':
        return Icons.comment;
      case 'CANCELED':
        return Icons.cancel;
      case 'ARCHIVED':
        return Icons.archive;
      default:
        return Icons.history;
    }
  }

  String _getMovementLabel(String? type) {
    switch (type?.toUpperCase()) {
      case 'REGISTERED':
        return 'Registrado';
      case 'FORWARDED':
        return 'Tramitado';
      case 'RECEIVED':
        return 'Recebido';
      case 'COMMENT':
        return 'Comentado';
      case 'CANCELED':
        return 'Cancelado';
      case 'ARCHIVED':
        return 'Arquivado';
      default:
        return type ?? 'Desconhecido';
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime ?? 'N/A';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _handleMenuAction(String action) {
    // Validação de status antes de permitir operações
    if (widget.protocol.status == 'CANCELADO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Protocolo já está cancelado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (widget.protocol.status == 'ARQUIVADO') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Protocolo arquivado não pode ser modificado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProtocolEditScreen(protocol: widget.protocol),
          ),
        ).then((_) {
          // Recarregar dados quando voltar da edição
          _loadAppendicesAndAttachments();
        });
        break;
      case 'forward':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProtocolForwardScreen(protocol: widget.protocol),
          ),
        );
        break;
      case 'receive':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProtocolReceiveScreen(protocol: widget.protocol),
          ),
        );
        break;
      case 'comment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProtocolCommentScreen(protocol: widget.protocol),
          ),
        );
        break;
      case 'cancel':
        _showCancelDialog();
        break;
      case 'archive':
        _showArchiveDialog();
        break;
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Cancelar Protocolo',
        message: 'Deseja realmente cancelar este protocolo?',
        icon: Icons.cancel,
        iconColor: Colors.red,
        inputLabel: 'Motivo do cancelamento',
        inputHint: 'Digite o motivo do cancelamento',
        confirmText: 'Confirmar',
        cancelText: 'Cancelar',
        confirmColor: Colors.red,
        showInputField: true,
        inputRequired: true,
        onConfirm: (reason) async {
          await _cancelProtocol(reason!);
        },
      ),
    );
  }

  Future<void> _cancelProtocol(String reason) async {
    setState(() => _loading = true);

    try {
      await _viewModel.cancelProtocol(widget.protocol.id, reason: reason);

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Protocolo ${widget.protocol.number} cancelado com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar protocolo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: () {
                if (!Navigator.canPop(context)) return;
                _showCancelDialog();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _archiveProtocol(String? message) async {
    setState(() => _loading = true);

    try {
      await _viewModel.archiveProtocol(widget.protocol.id, message: message?.isEmpty ?? true ? null : message);

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Protocolo ${widget.protocol.number} arquivado com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao arquivar protocolo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: () {
                if (!Navigator.canPop(context)) return;
                _showArchiveDialog();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Arquivar Protocolo ${widget.protocol.number}',
        message: 'Deseja realmente arquivar este protocolo?',
        icon: Icons.archive,
        iconColor: Colors.orange,
        inputLabel: 'Justificativa do arquivamento (opcional)',
        inputHint: 'Digite uma justificativa (opcional)',
        confirmText: 'Arquivar',
        cancelText: 'Voltar',
        confirmColor: Colors.orange,
        onConfirm: (message) async {
          await _archiveProtocol(message);
        },
      ),
    );
  }

  Widget _buildAttachments() {
    return Card(
      key: Key('protocol_attachments_card_${widget.protocol.id}'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Anexos do Protocolo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_attachments.isNotEmpty)
                      Text(
                        '${_attachments.length}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    const SizedBox(width: 8),
                    AttachmentUploadWidget(
                      protocolId: widget.protocol.id,
                      onUploadComplete: _loadAppendicesAndAttachments,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_attachments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.attach_file, color: Colors.grey, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhum anexo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _attachments.map((attachment) => _buildAttachmentCard(attachment)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCard(ProtocolAttachmentModel attachment) {
    return Container(
      key: ValueKey('protocol_attachment_${attachment.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.description, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.originalName,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${attachment.fileExtension} • ${attachment.formattedSize}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Botão de visualizar
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.green),
            onPressed: () => _viewAttachment(attachment),
            tooltip: 'Visualizar',
          ),
          // Botão de download
          IconButton(
            icon: Icon(Icons.download, color: Colors.blue),
            onPressed: () => _downloadAttachment(attachment),
            tooltip: 'Baixar',
          ),
        ],
      ),
    );
  }

  bool _isImageAttachment(ProtocolAttachmentModel attachment) {
    final ext = attachment.fileExtension.toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic'}.contains(ext);
  }

  String _resolveAttachmentUrl(ProtocolAttachmentModel attachment) {
    if (attachment.url != null && attachment.url!.isNotEmpty) {
      final baseUrl = dotenv.env['URL_BASE_API'] ?? '';
      return attachment.url!.startsWith('http')
          ? attachment.url!
          : '$baseUrl/${attachment.url}';
    }
    return '';
  }

  Future<void> _viewAttachment(ProtocolAttachmentModel attachment) async {
    try {
      // Mostra indicador de progresso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Abrindo arquivo para visualização...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // Tenta primeiro usar a URL direta do attachment se existir
      String viewUrl = _resolveAttachmentUrl(attachment);
      if (viewUrl.isEmpty) {
        viewUrl = await _protocolHttp.getAttachmentViewUrl(widget.protocol.id, attachment.id);
      }

      if (viewUrl.isEmpty) {
        throw Exception('URL do anexo não encontrada');
      }

      if (_isImageAttachment(attachment)) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttachmentPreviewScreen(
                url: viewUrl,
                title: attachment.originalName,
                protocolId: widget.protocol.id,
                attachmentId: attachment.id,
              ),
            ),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
        return;
      }

      // Tenta abrir a URL para visualização no app externo
      final uri = Uri.parse(viewUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Não foi possível abrir o arquivo para visualização');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao visualizar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAttachment(ProtocolAttachmentModel attachment) async {
    try {
      // Mostra indicador de progresso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Baixando anexo...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      String filePath;
      
      // Tenta primeiro usar o método direto do service HTTP
      try {
        filePath = await _protocolHttp.downloadAttachment(widget.protocol.id, attachment.id);
      } catch (e) {
        // Se falhar, tenta construir URL manualmente
        if (attachment.url != null && attachment.url!.isNotEmpty) {
          final baseUrl = dotenv.env['URL_BASE_API'];
          final viewUrl = attachment.url!.startsWith('http') 
              ? attachment.url! 
              : '$baseUrl/${attachment.url}';
          
          // Usa o método viewAttachment para obter a URL e depois faz download manual
          filePath = await _downloadFromUrl(viewUrl, attachment.originalName);
        } else {
          rethrow;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anexo baixado com sucesso!\nSalvo em: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );

        // Copia o caminho para o clipboard
        await Clipboard.setData(ClipboardData(text: filePath));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar anexo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método auxiliar para download direto de URL
  Future<String> _downloadFromUrl(String url, String fileName) async {
    await _pref.init();
    final token = _pref.getAccessToken();
    
    if (token == null) throw Exception('Token de autenticação ausente');

    final request = http.Request('GET', Uri.parse(url))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      });

    final streamedResponse = await request.send();
    
    if (streamedResponse.statusCode != 200) {
      throw Exception('Erro ao baixar arquivo: ${streamedResponse.statusCode}');
    }

    // Obtém o diretório de downloads
    final directory = await _getDownloadsDirectory();
    if (directory == null) {
      throw Exception('Não foi possível acessar o diretório de downloads');
    }

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    final sink = file.openWrite();
    
    try {
      await streamedResponse.stream.pipe(sink);
    } finally {
      await sink.close();
    }

    return filePath;
  }

  // Helper para obter diretório de downloads
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory;
      }
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getTemporaryDirectory();
    }
  }

  Future<void> _viewAppendixAttachment(String appendixId, ProtocolAttachmentModel attachment) async {
    try {
      // Mostra indicador de progresso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Abrindo anexo do apenso para visualização...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // Usa o método de visualização do service HTTP com o appendixId
      final success = await _protocolHttp.viewAttachment(
        widget.protocol.id, 
        attachment.id, 
        appendixId: appendixId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o anexo do apenso para visualização'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao visualizar anexo do apenso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAppendixAttachment(String appendixId, ProtocolAttachmentModel attachment) async {
    try {
      // Mostra indicador de progresso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Baixando anexo do apenso...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Usa o método de download do service HTTP com o appendixId
      final filePath = await _protocolHttp.downloadAttachment(
        widget.protocol.id, 
        attachment.id, 
        appendixId: appendixId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anexo do apenso baixado com sucesso!\nSalvo em: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );

        // Copia o caminho para o clipboard
        await Clipboard.setData(ClipboardData(text: filePath));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar anexo do apenso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  void _showCreateAppendixDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAppendixDialog(
        protocolId: widget.protocol.id,
        onAppendixCreated: _loadAppendicesAndAttachments,
      ),
    );
  }

  Widget _buildAppendices() {
    return Card(
      key: Key('protocol_appendices_card_${widget.protocol.id}'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder, color: Colors.purple, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Apensos / Subdocumentos',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_appendices.isNotEmpty)
                      Text(
                        '${_appendices.length}',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.purple),
                      onPressed: _showCreateAppendixDialog,
                      tooltip: 'Criar Novo Apenso',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_appendices.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.folder, color: Colors.grey, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhum apenso registrado',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: _appendices.map((appendix) => _buildAppendixCard(appendix)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppendixCard(ProtocolAppendixModel appendix) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.folder, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appendix.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${appendix.code} • ${appendix.documentType ?? "Documento"}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (appendix.notes != null && appendix.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              appendix.notes!,
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
          if (appendix.attachments != null && appendix.attachments!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anexos do apenso (${appendix.attachments!.length})',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  ...appendix.attachments!.map((attachment) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            attachment.originalName,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          attachment.formattedSize,
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        // Botão de visualizar
                        IconButton(
                          icon: Icon(Icons.visibility, color: Colors.green, size: 16),
                          onPressed: () => _viewAppendixAttachment(appendix.id, attachment),
                          tooltip: 'Visualizar',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                        const SizedBox(width: 4),
                        // Botão de download
                        IconButton(
                          icon: Icon(Icons.download, color: Colors.blue, size: 16),
                          onPressed: () => _downloadAppendixAttachment(appendix.id, attachment),
                          tooltip: 'Baixar',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

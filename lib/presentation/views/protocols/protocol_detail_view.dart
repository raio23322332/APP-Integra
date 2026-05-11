// presentation/views/protocols/protocol_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import '../../../data/models/protocol_model.dart';
import '../../widgets/protocols/protocol_appendices_widget.dart';
import '../../widgets/protocols/protocol_appendix_widget.dart';
import '../../widgets/protocols/protocol_menu_widget.dart';
import '../../../ui/widgets/attachment_upload_widget.dart';

class ProtocolDetailView extends StatefulWidget {
  final ProtocolModel protocol;
  const ProtocolDetailView({super.key, required this.protocol});

  @override
  State<ProtocolDetailView> createState() => _ProtocolDetailViewState();
}

class _ProtocolDetailViewState extends State<ProtocolDetailView> {
  bool _showProtocolNumber = false;
  bool _copiedProtocolNumber = false;

  static const Color _primary = AppColors.primaryBlue;

  // Método para mascarar número do protocolo (mostra apenas últimos 4 dígitos)
  String _displayProtocolNumber(String number) {
    if (_showProtocolNumber) return number;
    
    if (number.isEmpty) return '-';
    if (number.length <= 4) return '*' * number.length;
    
    final visibleEnd = number.substring(number.length - 4);
    final maskedStart = number
        .substring(0, number.length - 4)
        .replaceAll(RegExp(r'[^\s\-/.]'), '*');
    
    return '$maskedStart$visibleEnd';
  }

  bool get _isPredated {
    if (widget.protocol.registeredAt == null || widget.protocol.createdAt == null) return false;
    try {
      final registeredAt = DateTime.parse(widget.protocol.registeredAt!);
      final createdAt = DateTime.parse(widget.protocol.createdAt!);
      
      // Comparar apenas as datas (sem horas), igual ao web
      final registeredDate = DateTime(registeredAt.year, registeredAt.month, registeredAt.day);
      final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      
      return registeredDate.isBefore(createdDate);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('protocol_detail_view_scaffold'),
      backgroundColor: AppColors.background,
      appBar: protocolAppBar(
        title: 'Protocolo ${_displayProtocolNumber(widget.protocol.number)}',
      ),
      body: SingleChildScrollView(
        key: const Key('protocol_detail_view_scroll'),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isPredated) ...[_buildPredatedAlert(), const SizedBox(height: 16)],
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            if (widget.protocol.sector != null) ...[_buildSectorCard(), const SizedBox(height: 16)],
            _buildDatesCard(),
            const SizedBox(height: 16),
            _buildSubjectCard(),
            const SizedBox(height: 16),
            if (widget.protocol.notes?.isNotEmpty == true) ...[_buildNotesCard(), const SizedBox(height: 16)],
            _buildProtocolAttachmentsSection(context),
            const SizedBox(height: 16),
            ProtocolAppendicesWidget(protocol: widget.protocol),
            const SizedBox(height: 16),
            if (widget.protocol.movements?.isNotEmpty == true) ...[_buildMovementsCard(), const SizedBox(height: 16)],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPredatedAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protocolo predatado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Este protocolo foi registrado com data retroativa em ${_fmt(widget.protocol.registeredAt)}, mas criado no sistema em ${_fmt(widget.protocol.createdAt)}.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final color = _statusColor(widget.protocol.status);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_statusIcon(widget.protocol.status), color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                ProtocolMenuWidget(protocol: widget.protocol),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_statusIcon(widget.protocol.status), color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_displayProtocolNumber(widget.protocol.number), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primary)),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                              child: Text(widget.protocol.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                            ),
                            if (widget.protocol.isConfidential) ...[const SizedBox(width: 8), Icon(Icons.lock, size: 16, color: Colors.red.shade400)],
                            if (widget.protocol.isEmergency) ...[const SizedBox(width: 6), Icon(Icons.priority_high, size: 16, color: Colors.orange.shade600)],
                            const SizedBox(width: 8),
                            // Botões de ocultar/mostrar e copiar
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showProtocolNumber = !_showProtocolNumber;
                                    });
                                  },
                                  icon: Icon(_showProtocolNumber ? Icons.visibility_off : Icons.visibility, size: 20),
                                  tooltip: _showProtocolNumber ? 'Ocultar número' : 'Mostrar número',
                                  color: Colors.grey[600],
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await Clipboard.setData(ClipboardData(text: widget.protocol.number));
                                    setState(() {
                                      _copiedProtocolNumber = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Número do protocolo copiado!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    Future.delayed(const Duration(seconds: 2), () {
                                      if (mounted) {
                                        setState(() {
                                          _copiedProtocolNumber = false;
                                        });
                                      }
                                    });
                                  },
                                  icon: Icon(_copiedProtocolNumber ? Icons.check : Icons.copy, size: 20),
                                  tooltip: 'Copiar número',
                                  color: _copiedProtocolNumber ? Colors.green : Colors.grey[600],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() => protocolSectionCard(
    icon: Icons.info_outline,
    title: 'Informações Básicas',
    child: Column(children: [
      _detailItem(Icons.tag, 'Número', _displayProtocolNumber(widget.protocol.number)),
      if (widget.protocol.documentType?.isNotEmpty == true) _detailItem(Icons.article_outlined, 'Tipo de Documento', widget.protocol.documentType!),
      if (widget.protocol.direction.isNotEmpty) _detailItem(Icons.swap_horiz, 'Direção', widget.protocol.direction),
      if (widget.protocol.originProtocol?.isNotEmpty == true) _detailItem(Icons.link, 'Protocolo de Origem', widget.protocol.originProtocol!),
      if (widget.protocol.originAgency?.isNotEmpty == true) _detailItem(Icons.account_balance, 'Órgão de Origem', widget.protocol.originAgency!),
    ]),
  );

  Widget _buildSectorCard() => protocolSectionCard(
    icon: Icons.business,
    title: 'Setor Responsável',
    child: _detailItem(Icons.business, 'Setor', widget.protocol.sector!.name),
  );

  Widget _buildDatesCard() => protocolSectionCard(
    icon: Icons.access_time,
    title: 'Datas',
    child: Column(children: [
      _detailItem(Icons.access_time, 'Data de Criação', _fmt(widget.protocol.createdAt)),
      if (widget.protocol.updatedAt != null) _detailItem(Icons.update, 'Última Atualização', _fmt(widget.protocol.updatedAt)),
    ]),
  );

  Widget _buildSubjectCard() => protocolSectionCard(
    icon: Icons.subject,
    title: 'Assunto',
    child: Text(widget.protocol.subject, style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
  );

  Widget _buildNotesCard() => protocolSectionCard(
    icon: Icons.note_outlined,
    title: 'Observações',
    child: Text(widget.protocol.notes!, style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
  );

  Widget _detailItem(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: _primary, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary, letterSpacing: 0.3)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
      ])),
    ]),
  );

  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'ATIVO': return const Color(0xFF10B981);
      case 'CANCELADO': return const Color(0xFFEF4444);
      case 'ARQUIVADO': return const Color(0xFFF59E0B);
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s.toUpperCase()) {
      case 'ATIVO': return Icons.check_circle;
      case 'CANCELADO': return Icons.cancel;
      case 'ARQUIVADO': return Icons.archive;
      default: return Icons.help;
    }
  }

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return 'N/A';
    try { return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(d)); }
    catch (_) { return d; }
  }

  Widget _buildMovementsCard() {
    return protocolSectionCard(
      icon: Icons.history,
      title: 'Histórico de Movimentações',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.protocol.movements!.map((movement) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: movement.movementColor,
                  width: 3,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      movement.movementIcon,
                      color: movement.movementColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        movement.fullDescription.split(' em ').first,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      _fmt(movement.movedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (movement.message?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    movement.message!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (movement.fromSectorName != null)
                      Expanded(
                        child: Text(
                          'De: ${movement.fromSectorName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    if (movement.toSectorName != null) ...[
                      if (movement.fromSectorName != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          'Para: ${movement.toSectorName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProtocolAttachmentsSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e botão alinhados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_file, color: _primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Anexos do Protocolo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
                AttachmentUploadWidget(
                  protocolId: widget.protocol.id,
                  onUploadComplete: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ProtocolDetailView(protocol: widget.protocol),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Widget de anexos existente
            ProtocolAppendixWidget(protocol: widget.protocol),
          ],
        ),
      ),
    );
  }
}

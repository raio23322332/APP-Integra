import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/data/models/solicitacao_model.dart';
import 'package:intl/intl.dart';


class ProtocolDetailScreen extends StatelessWidget {
  final SolicitacaoModel request;

  const ProtocolDetailScreen({super.key, required this.request});

  final primaryBlue = const Color(0xFF28669b);
  final secondaryGreen = const Color(0xFF4b8c40);
  final highlightTeal = const Color(0xFF248e95);
  final textDark = const Color(0xFF263860);

  String _formatDateTime(String dateTimeString) {
    try {
      // Tenta parse no formato ISO (2026-01-29T01:49:53.000000Z)
      if (dateTimeString.contains('T') && dateTimeString.contains('Z')) {
        final dateTime = DateTime.parse(dateTimeString);
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      }
      
      // Tenta parse no formato "2026-01-29 01:49:53"
      if (dateTimeString.contains(' ') && dateTimeString.contains(':')) {
        final parts = dateTimeString.split(' ');
        if (parts.length == 2) {
          final dateParts = parts[0].split('-');
          final timeParts = parts[1].split(':');
          if (dateParts.length == 3 && timeParts.length >= 2) {
            final dateTime = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
            return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
          }
        }
      }
      
      // Se não conseguir parse, retorna a string original
      return dateTimeString;
    } catch (e) {
      return dateTimeString;
    }
  }

  DateTime _parseDateTime(String dateTimeString) {
    try {
      // Tenta parse no formato ISO (2026-01-29T01:49:53.000000Z)
      if (dateTimeString.contains('T') && dateTimeString.contains('Z')) {
        return DateTime.parse(dateTimeString);
      }
      
      // Tenta parse no formato "2026-01-29 01:49:53"
      if (dateTimeString.contains(' ') && dateTimeString.contains(':')) {
        final parts = dateTimeString.split(' ');
        if (parts.length == 2) {
          final dateParts = parts[0].split('-');
          final timeParts = parts[1].split(':');
          if (dateParts.length == 3 && timeParts.length >= 2) {
            return DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
          }
        }
      }
      
      // Se não conseguir parse, retorna data atual
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Protocolo'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildStatusTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Protocolo: ${request.codigo ?? "N/A"}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatusChip(request.status ?? 'Pendente'),
        const SizedBox(height: 15),
        const Divider(),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'concluído':
        color = secondaryGreen;
        icon = FontAwesomeIcons.circleCheck;
        break;
      case 'em andamento':
        color = highlightTeal;
        icon = FontAwesomeIcons.hourglassHalf;
        break;
      case 'cancelado':
        color = Colors.red;
        icon = FontAwesomeIcons.circleXmark;
        break;
      case 'pendente':
      default:
        color = Colors.orange;
        icon = FontAwesomeIcons.clock;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      color: Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: FontAwesomeIcons.calendarDay,
              title: 'Data de Abertura',
              value: request.dateTime != null 
                  ? _formatDateTime(request.dateTime!)
                  : 'Data não disponível',
            ),
            if (request.tipoId != null)
              _buildInfoRow(
                icon: FontAwesomeIcons.tag,
                title: 'Tipo',
                value: request.getDescricaoTipo(request.tipoId!),
              ),
            if (request.subtipoId != null)
              _buildInfoRow(
                icon: FontAwesomeIcons.tags,
                title: 'Subtipo',
                value: request.getDescricaoTipoSubTipo(request.tipoId ?? "0", request.subtipoId!),
              ),
            _buildInfoRow(
              icon: FontAwesomeIcons.locationDot,
              title: 'Endereço da Solicitação',
              value: request.enderecos?.isNotEmpty == true
                  ? '${request.enderecos!.first.logradouro}, ${request.enderecos!.first.numero} - ${request.enderecos!.first.bairro}'
                  : 'Endereço não fornecido',
              isMultiline: true,
            ),
            _buildInfoRow(
              icon: FontAwesomeIcons.locationDot,
              title: 'Localização (Lat/Long)',
              value: request.latitude != null && request.longitude != null
                  ? '${double.parse(request.latitude!).toStringAsFixed(4)}, ${double.parse(request.longitude!).toStringAsFixed(4)}'
                  : 'Localização não disponível',
            ),
            _buildInfoRow(
              icon: FontAwesomeIcons.fileLines,
              title: 'Descrição',
              value: request.descricao ?? 'Sem descrição',
              isMultiline: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: highlightTeal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textDark.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    // Simulação de uma linha do tempo de status para um visual mais institucional
    final baseDate = request.dateTime != null ? _parseDateTime(request.dateTime!) : DateTime.now();
    final timeline = [
      {'status': 'Solicitação Aberta', 'date': baseDate, 'isDone': true},
      {
        'status': 'Em Análise pela Prefeitura',
        'date': baseDate.add(const Duration(hours: 1)),
        'isDone': (request.status ?? 'pendente').toLowerCase() != 'pendente',
      },
      {
        'status': 'Em Campo/Execução',
        'date': baseDate.add(const Duration(days: 2)),
        'isDone': (request.status ?? 'pendente').toLowerCase() == 'concluído',
      },
      {
        'status': 'Serviço Concluído',
        'date': baseDate.add(const Duration(days: 4)),
        'isDone': (request.status ?? 'pendente').toLowerCase() == 'concluído',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acompanhamento do Processo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 10),
        ...timeline.map((item) => _buildTimelineItem(item)),
      ],
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final date = item['date'] as DateTime;
    final isDone = item['isDone'] as bool;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isDone ? secondaryGreen : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              if (status != 'Serviço Concluído')
                Container(
                  width: 2,
                  height: 40,
                  color: isDone
                      ? secondaryGreen.withOpacity(0.5)
                      : Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDone ? textDark : Colors.grey.shade600,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(date),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// presentation/widgets/protocols/protocol_appendices_widget.dart
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import '../../../data/models/protocol_model.dart';
import '../../../data/models/protocol_appendix_model.dart';
import '../../../services/http/protocol_http.dart';
import '../../widgets/protocols/protocol_appendix_widget.dart';
import '../../../ui/widgets/create_appendix_dialog.dart';
// import '../../../ui/widgets/edit_appendix_dialog.dart'; // Comentado por compatibilidade
import 'package:integra_app/core/theme/app_colors.dart';

class ProtocolAppendicesWidget extends StatefulWidget {
  final ProtocolModel protocol;

  const ProtocolAppendicesWidget({super.key, required this.protocol});

  @override
  State<ProtocolAppendicesWidget> createState() => _ProtocolAppendicesWidgetState();
}

class _ProtocolAppendicesWidgetState extends State<ProtocolAppendicesWidget> {
  final ProtocolHttp _protocolHttp = ProtocolHttp();
  List<ProtocolAppendixModel> _appendices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAppendices();
  }

  Future<void> _loadAppendices() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _appendices = await _protocolHttp.getAppendices(widget.protocol.id);
    } catch (e) {
      if (mounted) _snack('Erro ao carregar apensos: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return protocolSectionCard(
      icon: Icons.folder_copy_outlined,
      title: 'Apensos / Subdocumentos',
      child: Column(
        key: const Key('protocol_appendices_section'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão novo apenso
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              key: const Key('protocol_appendices_new_button'),
              onTap: _isLoading ? null : () => _showCreateDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    const Text('Novo Apenso', style: TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_appendices.isEmpty)
            _buildEmptyState()
          else
            Column(
              children: _appendices.asMap().entries.map((e) => _buildAppendixItem(e.value, e.key + 1)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      key: const Key('protocol_appendices_empty_state'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(Icons.folder_copy_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('Nenhum apenso encontrado', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Clique em "Novo Apenso" para adicionar', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAppendixItem(ProtocolAppendixModel appendix, int order) {
    return Container(
      key: Key('protocol_appendix_item_${appendix.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text('$order', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        title: Text(appendix.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.darkText)),
        subtitle: Row(
          children: [
            if (appendix.documentType != null) ...[
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                  child: Text(appendix.documentType!, style: const TextStyle(fontSize: 11, color: Color(0xFF1D4ED8)), overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.business, size: 11, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Flexible(child: Text(appendix.sector?.name ?? '—', style: TextStyle(fontSize: 11, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Icon(Icons.attach_file, size: 11, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text('${appendix.attachments?.length ?? 0} anexos', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appendix.notes?.isNotEmpty == true) ...[
                  Text('Observações:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(appendix.notes!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 12),
                ],
                if (appendix.attachments != null && appendix.attachments!.isNotEmpty)
                  ProtocolAppendixWidget(protocol: widget.protocol, appendixId: appendix.id),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // _actionChip(icon: Icons.edit_outlined, label: 'Editar', color: AppColors.primaryBlue, onTap: () => _editAppendix(appendix)),
                    // const SizedBox(width: 8),
                    // _actionChip(icon: Icons.delete_outline, label: 'Excluir', color: Colors.red, onTap: () => _confirmDelete(appendix)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _actionChip({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
  */

  // ─── LÓGICA (original preservada) ────────────────────────────────────────

  void _showCreateDialog(BuildContext context) {
    if (_isLoading) return;
    showDialog(
      context: context,
      builder: (_) => CreateAppendixDialog(
        protocolId: widget.protocol.id,
        onAppendixCreated: () { 
          if (mounted) {
            Navigator.pop(context); 
            _loadAppendices(); 
          }
        },
      ),
    );
  }

  /*
  void _editAppendix(ProtocolAppendixModel appendix) {
    showDialog(
      context: context,
      builder: (_) => EditAppendixDialog(
        protocolId: widget.protocol.id,
        appendix: appendix,
        onAppendixUpdated: () { 
          if (mounted) {
            Navigator.pop(context); 
            _loadAppendices(); 
          }
        },
      ),
    );
  }

  void _confirmDelete(ProtocolAppendixModel appendix) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Apenso'),
        content: Text('Deseja realmente excluir o apenso "${appendix.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _protocolHttp.deleteAppendix(widget.protocol.id, appendix.id);
                if (mounted) {
                  setState(() => _appendices.removeWhere((a) => a.id == appendix.id));
                  _snack('Apenso excluído com sucesso!', Colors.green);
                }
              } catch (e) {
                if (mounted) _snack('Erro ao excluir apenso: $e', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
  */

  void _snack(String msg, Color color) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}

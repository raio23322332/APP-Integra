// presentation/widgets/protocols/protocol_appendix_widget.dart
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../views/attachment_preview_screen.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import '../../../data/models/protocol_model.dart';
import '../../../services/http/protocol_http.dart';
import '../../../data/models/protocol_attachment_model.dart';


class ProtocolAppendixWidget extends StatefulWidget {
  final ProtocolModel protocol;
  final String? appendixId;

  const ProtocolAppendixWidget({super.key, required this.protocol, this.appendixId});

  @override
  State<ProtocolAppendixWidget> createState() => _ProtocolAppendixWidgetState();
}

class _ProtocolAppendixWidgetState extends State<ProtocolAppendixWidget> {
  // final ImagePicker _imagePicker = ImagePicker(); // Comentado por compatibilidade
  final ProtocolHttp _protocolHttp = ProtocolHttp();
  List<ProtocolAttachmentModel> _attachments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _attachments = await _protocolHttp.getAttachments(widget.protocol.id, appendixId: widget.appendixId);
    } catch (e) {
      if (mounted) _snack('Erro ao carregar anexos: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return protocolSectionCard(
      icon: Icons.attach_file,
      title: 'Anexos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão adicionar - Comentado por compatibilidade (apenas visualização)
          /*
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: _isLoading ? null : () => _showAddDialog(context),
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
                    const Text('Adicionar', style: TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          */
          const SizedBox(height: 12),
          if (_attachments.isEmpty)
            _buildEmptyState(Icons.folder_open, 'Nenhum anexo encontrado')
          else
            Column(children: _attachments.map(_buildAttachmentItem).toList()),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(ProtocolAttachmentModel attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _fileColor(attachment.extension).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(_fileIcon(attachment.extension), color: _fileColor(attachment.extension), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attachment.originalName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(attachment.formattedSize, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.open_in_new, size: 18, color: AppColors.primaryBlue), onPressed: () => _openFile(attachment), tooltip: 'Abrir'),
          IconButton(icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400), onPressed: () => _confirmDelete(attachment), tooltip: 'Excluir'),
        ],
      ),
    );
  }

  /*
  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Adicionar Anexo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _optionButton(icon: Icons.camera_alt, label: 'Câmera', color: AppColors.primaryBlue, onTap: _pickFromCamera)),
                const SizedBox(width: 12),
                Expanded(child: _optionButton(icon: Icons.photo_library, label: 'Galeria', color: AppColors.green, onTap: _pickFromGallery)),
                const SizedBox(width: 12),
                Expanded(child: _optionButton(icon: Icons.folder, label: 'Arquivos', color: AppColors.orange, onTap: _pickFromFiles)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _optionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
  */

  // ─── ACTIONS (lógica original preservada) ────────────────────────────────

  /*
  Future<void> _pickFromCamera() async {
    Navigator.pop(context);
    try {
      if (!await Permission.camera.request().isGranted) { _snack('Permissão da câmera negada', Colors.red); return; }
      final img = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (img != null) await _upload(File(img.path), 'Imagem');
    } catch (e) { _snack('Erro ao capturar imagem: $e', Colors.red); }
  }

  Future<void> _pickFromGallery() async {
    Navigator.pop(context);
    try {
      if (!await Permission.photos.request().isGranted) { _snack('Permissão da galeria negada', Colors.red); return; }
      final img = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (img != null) await _upload(File(img.path), 'Imagem');
    } catch (e) { _snack('Erro ao selecionar imagem: $e', Colors.red); }
  }

  Future<void> _pickFromFiles() async {
    Navigator.pop(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf','doc','docx','xls','xlsx','ppt','pptx','jpg','jpeg','png','gif','zip','rar','txt','csv'],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        await _upload(File(result.files.first.path!), 'Documento');
      }
    } catch (e) { _snack('Erro ao selecionar arquivo: $e', Colors.red); }
  }

  Future<void> _upload(File file, String category) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final uploaded = await _protocolHttp.uploadAttachment(
        protocolId: widget.protocol.id, 
        file: file, 
        category: category,
        appendixId: widget.appendixId
      );
      if (mounted) {
        setState(() => _attachments.add(uploaded));
        _snack('Anexo adicionado com sucesso!', Colors.green);
      }
    } catch (e) {
      if (mounted) _snack('Erro ao adicionar anexo: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  */

  void _openFile(ProtocolAttachmentModel attachment) async {
    try {
      // Tenta primeiro usar a URL direta do attachment se existir
      String url = _resolveAttachmentUrl(attachment);
      if (url.isEmpty) {
        url = await _protocolHttp.getAttachmentViewUrl(widget.protocol.id, attachment.id, appendixId: widget.appendixId);
      }

      if (url.isEmpty) throw Exception('URL do anexo não encontrada');

      if (_isImageAttachment(attachment)) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttachmentPreviewScreen(
                url: url,
                title: attachment.originalName,
                protocolId: widget.protocol.id,
                attachmentId: attachment.id,
                appendixId: widget.appendixId,
              ),
            ),
          );
        }
        return;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Não foi possível abrir o arquivo no app externo');
      }
    } catch (e) {
      _snack('Erro ao abrir arquivo: $e', Colors.red);
    }
  }

  void _confirmDelete(ProtocolAttachmentModel attachment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Anexo'),
        content: Text('Deseja realmente excluir "${attachment.originalName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _protocolHttp.deleteAttachment(widget.protocol.id, attachment.id, appendixId: widget.appendixId);
                if (mounted) {
                  setState(() => _attachments.removeWhere((a) => a.id == attachment.id));
                  _snack('Anexo excluído com sucesso!', Colors.green);
                }
              } catch (e) {
                if (mounted) _snack('Erro ao excluir: $e', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Color _fileColor(String? ext) {
    switch (ext?.toUpperCase()) {
      case 'PDF': return Colors.red;
      case 'DOC': case 'DOCX': return AppColors.primaryBlue;
      case 'XLS': case 'XLSX': return Colors.green;
      case 'ZIP': case 'RAR': return Colors.purple;
      case 'JPG': case 'JPEG': case 'PNG': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _fileIcon(String? ext) {
    switch (ext?.toUpperCase()) {
      case 'PDF': return Icons.picture_as_pdf;
      case 'DOC': case 'DOCX': return Icons.description;
      case 'XLS': case 'XLSX': return Icons.table_chart;
      case 'ZIP': case 'RAR': return Icons.archive;
      case 'JPG': case 'JPEG': case 'PNG': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }
}

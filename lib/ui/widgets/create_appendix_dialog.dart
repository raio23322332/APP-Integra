// ui/widgets/create_appendix_dialog.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../services/http/protocol_http.dart';
import '../../../services/http/sector_http.dart';
import 'package:integra_app/core/theme/app_colors.dart';


class CreateAppendixDialog extends StatefulWidget {
  final String protocolId;
  final Function() onAppendixCreated;

  const CreateAppendixDialog({
    super.key,
    required this.protocolId,
    required this.onAppendixCreated,
  });

  @override
  State<CreateAppendixDialog> createState() => _CreateAppendixDialogState();
}

class _CreateAppendixDialogState extends State<CreateAppendixDialog> {
  final _formKey = GlobalKey<FormState>();
  final ProtocolHttp _protocolHttp = ProtocolHttp();
  final ImagePicker _imagePicker = ImagePicker();

  final _titleController = TextEditingController();
  final _documentTypeController = TextEditingController();
  final _notesController = TextEditingController();

  List<File> _selectedFiles = [];
  List<String> _selectedFileNames = [];
  bool _isCreating = false;
  List<Map<String, String>> _sectors = [];
  String? _selectedSectorId;

  @override
  void initState() {
    super.initState();
    _loadSectors();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _documentTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSectors() async {
    try {
      final sectors = await SectorHttp().getSectors();
      setState(() {
        _sectors = sectors.map((s) => {'id': s.id, 'name': s.name}).toList();
      });
    } catch (e) {
      setState(() {
        _sectors = [
          {'id': '1', 'name': 'Setor A'},
          {'id': '2', 'name': 'Setor B'},
          {'id': '3', 'name': 'Setor C'},
        ];
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await [Permission.camera, Permission.storage, Permission.photos].request();
    } else if (Platform.isIOS) {
      await [Permission.camera, Permission.photos].request();
    }
  }

  Future<void> _pickFromCamera() async {
    await _requestPermissions();
    final img = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1920, maxHeight: 1080);
    if (img != null) {
      setState(() { _selectedFiles.add(File(img.path)); _selectedFileNames.add(img.name); });
    }
  }

  Future<void> _pickFromGallery() async {
    await _requestPermissions();
    final img = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1920, maxHeight: 1080);
    if (img != null) {
      setState(() { _selectedFiles.add(File(img.path)); _selectedFileNames.add(img.name); });
    }
  }

  Future<void> _pickFromFiles() async {
    await _requestPermissions();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','doc','docx','xls','xlsx','ppt','pptx','txt','jpg','jpeg','png','gif','webp'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.path != null) {
        setState(() {
          _selectedFiles.add(File(file.path!));
          _selectedFileNames.add(file.name);
        });
      }
    }
  }

  void _removeFile(int index) => setState(() { _selectedFiles.removeAt(index); _selectedFileNames.removeAt(index); });

  void _showUploadOptions() {
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
                const Text('Adicionar Arquivos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _optionButton(icon: Icons.camera_alt, label: 'Câmera', color: AppColors.primaryBlue, onTap: () { Navigator.pop(context); _pickFromCamera(); })),
                const SizedBox(width: 12),
                Expanded(child: _optionButton(icon: Icons.photo_library, label: 'Galeria', color: AppColors.green, onTap: () { Navigator.pop(context); _pickFromGallery(); })),
                const SizedBox(width: 12),
                Expanded(child: _optionButton(icon: Icons.folder, label: 'Arquivos', color: AppColors.orange, onTap: () { Navigator.pop(context); _pickFromFiles(); })),
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

  Future<void> _createAppendix() async {
    if (!_formKey.currentState!.validate() || _selectedSectorId == null) {
      if (_selectedSectorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um setor'), backgroundColor: Colors.red));
      }
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Validar tamanho dos arquivos antes de enviar
      if (_selectedFiles.isNotEmpty) {
        for (final file in _selectedFiles) {
          final fileSize = await file.length();
          const maxFileSize = 10 * 1024 * 1024; // 10MB
          if (fileSize > maxFileSize) {
            throw Exception('Arquivo muito grande (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB). Tamanho máximo permitido: 10MB.');
          }
        }
      }

      // Enviar tudo junto (igual ao web)
      await _protocolHttp.createAppendixWithFiles(
        protocolId: widget.protocolId,
        title: _titleController.text.trim(),
        sectorId: _selectedSectorId!,
        documentType: _documentTypeController.text.trim().isEmpty ? null : _documentTypeController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        files: _selectedFiles,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apenso criado com sucesso!'), backgroundColor: Colors.green));
        widget.onAppendixCreated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao criar apenso: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ));
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('create_appendix_dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.background,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_copy_outlined,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Novo Apenso',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(1)
              )
            ),
            const SizedBox(height: 16),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        key: const Key('create_appendix_title_field'),
                        controller: _titleController,
                        decoration: protocolInputDecoration(label: 'Título do Apenso *', hint: 'Digite o título', prefixIcon: Icons.title),
                        validator: (v) => v == null || v.trim().isEmpty ? 'O título é obrigatório' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('create_appendix_document_type_field'),
                        controller: _documentTypeController,
                        decoration: protocolInputDecoration(label: 'Tipo do Documento', hint: 'Ex: Ofício, Memorando...', prefixIcon: Icons.description),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: const Key('create_appendix_sector_dropdown'),
                        value: _selectedSectorId,
                        decoration: protocolInputDecoration(label: 'Setor *', hint: 'Selecione o setor', prefixIcon: Icons.business),
                        items: _sectors.map((s) => DropdownMenuItem(
                          value: s['id'], 
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              s['name']!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )).toList(),
                        validator: (v) => v == null ? 'Selecione um setor' : null,
                        onChanged: (v) => setState(() => _selectedSectorId = v),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue),
                        iconSize: 24,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 4,
                        style: const TextStyle(color: AppColors.darkText, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('create_appendix_notes_field'),
                        controller: _notesController,
                        decoration: protocolInputDecoration(label: 'Observações', hint: 'Observações adicionais (opcional)', prefixIcon: Icons.note_outlined),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),

                      // Seção de arquivos
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.attach_file, color: AppColors.primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('Arquivos do Apenso', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.darkText))),
                                InkWell(
                                  key: const Key('create_appendix_add_attachment_button'),
                                  onTap: _showUploadOptions,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add, size: 14, color: AppColors.primaryBlue),
                                        SizedBox(width: 4),
                                        Text('Adicionar', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Você pode enviar um arquivo no mesmo cadastro.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                            if (_selectedFileNames.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Selecionados (${_selectedFileNames.length})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                                    const SizedBox(height: 8),
                                    ...List.generate(_selectedFileNames.length, (i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.insert_drive_file, color: AppColors.primaryBlue, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(_selectedFileNames[i], style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                          InkWell(
                                            onTap: () => _removeFile(i),
                                            child: const Icon(Icons.close, size: 16, color: Colors.grey),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botões
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('create_appendix_cancel_button'),
                    onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('create_appendix_submit_button'),
                    onPressed: (_isCreating || _titleController.text.trim().isEmpty || _selectedSectorId == null) ? null : _createAppendix,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Criar Apenso',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

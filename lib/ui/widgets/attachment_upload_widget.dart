import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../services/attachment_upload_service.dart';

class AttachmentUploadWidget extends StatefulWidget {
  final String protocolId;
  final String? appendixId;
  final Function() onUploadComplete;

  const AttachmentUploadWidget({
    super.key,
    required this.protocolId,
    this.appendixId,
    required this.onUploadComplete,
  });

  @override
  State<AttachmentUploadWidget> createState() => _AttachmentUploadWidgetState();
}

class _AttachmentUploadWidgetState extends State<AttachmentUploadWidget> {
  final ImagePicker _imagePicker = ImagePicker();
  final AttachmentUploadService _uploadService = AttachmentUploadService();
  File? _selectedFile;
  String? _selectedFileName;
  bool _isCompressing = false;

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await [
        Permission.camera,
        Permission.storage,
        Permission.photos,
      ].request();
    } else if (Platform.isIOS) {
      await [
        Permission.camera,
        Permission.photos,
      ].request();
    }
  }

  @override
  void dispose() {
    // Limpar recursos para evitar memory leaks
    _selectedFile = null;
    _selectedFileName = null;
    super.dispose();
  }

  // Função para comprimir imagens
  Future<File?> _compressImage(File imageFile) async {
    try {
      setState(() => _isCompressing = true);
      
      // Ler a imagem original
      final originalImage = img.decodeImage(await imageFile.readAsBytes());
      if (originalImage == null) return null;

      // Calcular novas dimensões (máximo 1920x1080)
      int maxWidth = 1920;
      int maxHeight = 1080;
      
      double widthRatio = maxWidth / originalImage.width;
      double heightRatio = maxHeight / originalImage.height;
      double ratio = widthRatio < heightRatio ? widthRatio : heightRatio;
      
      int newWidth = (originalImage.width * ratio).round();
      int newHeight = (originalImage.height * ratio).round();

      // Redimensionar imagem
      final compressedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.average,
      );

      // Reduzir qualidade para JPEG (85%)
      final compressedBytes = img.encodeJpg(compressedImage, quality: 85);
      
      // Salvar arquivo comprimido
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      debugPrint('Imagem comprimida: ${(imageFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)}MB → ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)}MB');
      
      return compressedFile;
    } catch (e) {
      debugPrint('Erro ao comprimir imagem: $e');
      return imageFile; // Retorna original se falhar
    } finally {
      if (mounted) {
        setState(() => _isCompressing = false);
      }
    }
  }

  // Verificar se o arquivo é uma imagem
  bool _isImageFile(File file) {
    final extension = file.path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        File? dialogSelectedFile = _selectedFile;
        String? dialogSelectedFileName = _selectedFileName;
        bool dialogIsUploading = false;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> dialogPickImageFromCamera() async {
              await _requestPermissions();
              
              final XFile? image = await _imagePicker.pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
                maxWidth: 1920,
                maxHeight: 1080,
              );

              if (image != null) {
                setDialogState(() {
                  dialogSelectedFile = File(image.path);
                  dialogSelectedFileName = image.name;
                });
              }
            }

            Future<void> dialogPickImageFromGallery() async {
              await _requestPermissions();
              
              final XFile? image = await _imagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
                maxWidth: 1920,
                maxHeight: 1080,
              );

              if (image != null) {
                setDialogState(() {
                  dialogSelectedFile = File(image.path);
                  dialogSelectedFileName = image.name;
                });
              }
            }

            Future<void> dialogPickFile() async {
              await _requestPermissions();
              
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png', 'gif'],
                allowMultiple: false,
              );

              if (result != null && result.files.single.path != null) {
                PlatformFile file = result.files.single;
                setDialogState(() {
                  dialogSelectedFile = File(file.path!);
                  dialogSelectedFileName = file.name;
                });
              }
            }

            Future<void> dialogUploadFile() async {
              if (dialogSelectedFile == null || dialogSelectedFileName == null) return;

              setDialogState(() => dialogIsUploading = true);

              try {
                // Verificar se o arquivo existe antes de tentar fazer upload
                if (!await dialogSelectedFile!.exists()) {
                  throw Exception('Arquivo não encontrado: ${dialogSelectedFile!.path}');
                }

                File fileToUpload = dialogSelectedFile!;

                // Comprimir imagem se for muito grande
                if (_isImageFile(fileToUpload)) {
                  final fileSize = await fileToUpload.length();
                  const maxFileSize = 10 * 1024 * 1024; // 10MB
                  
                  if (fileSize > maxFileSize) {
                    // Tentar comprimir automaticamente
                    final compressedFile = await _compressImage(fileToUpload);
                    if (compressedFile != null) {
                      final compressedSize = await compressedFile.length();
                      if (compressedSize <= maxFileSize) {
                        fileToUpload = compressedFile;
                        setDialogState(() {
                          dialogSelectedFile = compressedFile;
                          dialogSelectedFileName = compressedFile.path.split('/').last;
                        });
                      } else {
                        final originalSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
                        final compressedSizeMB = (compressedSize / (1024 * 1024)).toStringAsFixed(2);
                        throw Exception('Arquivo muito grande mesmo após compressão ($originalSizeMB MB → $compressedSizeMB MB). Tamanho máximo: 10MB');
                      }
                    }
                  }
                }

                // Verificação final do tamanho
                final finalFileSize = await fileToUpload.length();
                const maxFileSize = 10 * 1024 * 1024; // 10MB
                if (finalFileSize > maxFileSize) {
                  final fileSizeMB = (finalFileSize / (1024 * 1024)).toStringAsFixed(2);
                  throw Exception('Arquivo muito grande ($fileSizeMB MB). Tamanho máximo permitido: 10MB');
                }

                await _uploadService.uploadAttachment(
                  widget.protocolId,
                  fileToUpload,
                  appendixId: widget.appendixId,
                  category: 'Documento',
                );
                
                if (mounted) {
                  Navigator.of(context).pop(); // Fechar o dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Arquivo "$dialogSelectedFileName" enviado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  widget.onUploadComplete();
                  
                  // Limpar seleção no widget principal
                  setState(() {
                    _selectedFile = null;
                    _selectedFileName = null;
                  });
                }
              } catch (e) {
                if (mounted) {
                  String errorMessage = e.toString();
                  
                  // Tratar mensagens de erro específicas
                  if (errorMessage.contains('Token de autenticação ausente')) {
                    errorMessage = 'Sessão expirada. Faça login novamente.';
                  } else if (errorMessage.contains('URL_BASE_API não configurada')) {
                    errorMessage = 'Configuração do servidor ausente. Contate o suporte.';
                  } else if (errorMessage.contains('Arquivo não encontrado')) {
                    errorMessage = 'Arquivo não encontrado. Tente selecionar novamente.';
                  } else if (errorMessage.contains('mesmo após compressão')) {
                    errorMessage = 'Arquivo muito grande mesmo após compressão automática. Tente um arquivo menor.';
                  } else if (errorMessage.contains('muito grande')) {
                    errorMessage = 'Arquivo muito grande. Tamanho máximo: 5MB. Imagens são comprimidas automaticamente.';
                  } else if (errorMessage.contains('Status: 401')) {
                    errorMessage = 'Não autorizado. Faça login novamente.';
                  } else if (errorMessage.contains('Status: 403')) {
                    errorMessage = 'Sem permissão para enviar arquivos.';
                  } else if (errorMessage.contains('Status: 413')) {
                    errorMessage = 'Arquivo muito grande para o servidor.';
                  } else if (errorMessage.contains('Status: 422')) {
                    errorMessage = 'Dados inválidos. Verifique o arquivo.';
                  } else if (errorMessage.contains('Status: 500')) {
                    errorMessage = 'Erro interno do servidor. A equipe já foi notificada. Tente novamente em alguns minutos.';
                  } else if (errorMessage.contains('Erro 500:')) {
                    errorMessage = 'Erro interno do servidor detectado. Tentando métodos alternativos...';
                    errorMessage += '\n\nO sistema está tentando diferentes abordagens para resolver o problema.';
                  } else if (errorMessage.contains('Status:')) {
                    final statusMatch = RegExp(r'Status: (\d+)').firstMatch(errorMessage);
                    if (statusMatch != null) {
                      final statusCode = statusMatch.group(1);
                      errorMessage = 'Erro no servidor (Código: $statusCode). Tente novamente.';
                    }
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'OK',
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setDialogState(() => dialogIsUploading = false);
                }
              }
            }

            return Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adicionar Anexo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Opções de upload
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _UploadOption(
                          icon: Icons.camera_alt,
                          label: 'Câmera',
                          color: Colors.blue,
                          onTap: dialogPickImageFromCamera,
                        ),
                        _UploadOption(
                          icon: Icons.photo_library,
                          label: 'Galeria',
                          color: Colors.green,
                          onTap: dialogPickImageFromGallery,
                        ),
                        _UploadOption(
                          icon: Icons.attach_file,
                          label: 'Arquivo',
                          color: Colors.orange,
                          onTap: dialogPickFile,
                        ),
                      ],
                    ),
                    
                    // Arquivo selecionado
                    if (dialogSelectedFile != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dialogSelectedFileName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setDialogState(() {
                                      dialogSelectedFile = null;
                                      dialogSelectedFileName = null;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                ),
                              ],
                            ),
                            if (_isCompressing) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Comprimindo imagem automaticamente...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: dialogIsUploading ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: dialogSelectedFile != null && !dialogIsUploading ? dialogUploadFile : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: dialogIsUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'ENVIAR',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
      onPressed: _showUploadDialog,
      tooltip: 'Adicionar Anexo',
      iconSize: 24,
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

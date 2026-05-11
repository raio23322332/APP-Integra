import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import 'protocols/protocol_app_bar.dart';

class AttachmentPreviewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? protocolId;
  final String? attachmentId;
  final String? appendixId;

  const AttachmentPreviewScreen({
    super.key,
    required this.url,
    required this.title,
    this.protocolId,
    this.attachmentId,
    this.appendixId,
  });

  @override
  State<AttachmentPreviewScreen> createState() => _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
  final Set<String> _imageExtensions = const {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'heic',
  };
  late final WebViewController _controller;
  bool _loading = true;
  bool _downloading = false;

  String get _fileExtension {
    final uri = Uri.tryParse(widget.url);
    final path = uri?.path ?? widget.url;
    final parts = path.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  bool get _isImage => _imageExtensions.contains(_fileExtension);
  bool get _isPdf => _fileExtension == 'pdf';

  String get _previewUrl {
    if (_isPdf) {
      return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.url)}';
    }
    return widget.url;
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(_previewUrl));
  }

  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir externamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadFile() async {
    if (_downloading) return;

    setState(() => _downloading = true);

    try {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download iniciado! 📁\nVerifique seu navegador para baixar o arquivo.'),
            backgroundColor: AppColors.green,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        throw Exception('Não foi possível iniciar o download');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao baixar arquivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: protocolAppBar(
        title: widget.title,
        actions: [
          if (_downloading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _downloadFile,
              tooltip: 'Baixar arquivo',
            ),
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: _openExternal,
            tooltip: 'Abrir externamente',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: _isImage ? _buildImagePreview() : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          widget.url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              if (_loading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _loading = false);
                });
              }
              return child;
            }
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            if (_loading) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _loading = false);
              });
            }
            return const Center(child: Text('Erro ao carregar imagem.'));
          },
        ),
      ),
    );
  }
}

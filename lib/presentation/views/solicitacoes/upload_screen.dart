// presentation/views/solicitacoes/upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integra_app/core/helpers/console_log.dart';
import 'package:integra_app/services/solicitacao/solicitacao_servico.dart';
import 'package:integra_app/data/dao/user_dao.dart';

class UploadScreen extends StatefulWidget {
  final Map<String, dynamic> dados;
  const UploadScreen({super.key, required this.dados});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  static const int _maxImagens = 3;
  static const int _maxDescricaoLength = 500;

  final _descricaoController = TextEditingController();
  final _observacaoController = TextEditingController();
  final List<File> _imagens = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final SolicitacaoServico _solicitacaoServico = SolicitacaoServico();

  // Cor primária conforme sua preferência
  static const Color _primaryColor = Color(0xFF2b529c);
  static const Color _backgroundColor = Color(0xFFF5F7FA); // fundo claro

  @override
  void initState() {
    super.initState();
    ConsoleLog.debug('UploadScreen iniciado');
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  bool get _isDescricaoValida =>
      _descricaoController.text.trim().isNotEmpty &&
      _descricaoController.text.trim().length <= _maxDescricaoLength;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Adicionar Fotos'),
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescricaoField(),
          const SizedBox(height: 16),
          _buildObservacaoField(),
          const SizedBox(height: 16),
          _buildImageUploadSection(),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final isEnabled = !_isUploading && _isDescricaoValida;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEnabled ? _enviarSolicitacao : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled
                ? _primaryColor
                : _primaryColor.withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Enviar Solicitação',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDescricaoField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descricaoController,
        maxLines: 4,
        maxLength: _maxDescricaoLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        onChanged: (_) => setState(() {}), // atualiza estado para botão
        decoration: InputDecoration(
          labelText: 'Descrição do Problema *',
          hintText: 'Descreva detalhadamente o que está acontecendo...',
          prefixIcon: Icon(Icons.description, color: _primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
          counterText: '', // remove contador automático (opcional)
        ),
      ),
    );
  }

  Widget _buildObservacaoField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.note_add_outlined, color: _primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Observações (opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextFormField(
              controller: _observacaoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Informações adicionais que possam ajudar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotos do Local',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _imagens.length + (_imagens.length < _maxImagens ? 1 : 0),
          itemBuilder: (_, index) {
            if (index < _imagens.length) {
              return _buildImageItem(_imagens[index], index);
            }
            return _buildAddImageButton();
          },
        ),
        if (_imagens.length >= _maxImagens)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Máximo de $_maxImagens fotos atingido',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(File image, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(image, fit: BoxFit.cover),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => setState(() => _imagens.removeAt(index)),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _primaryColor, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_imagens.length >= _maxImagens) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _imagens.add(File(picked.path)));
    }
  }

  Future<void> _enviarSolicitacao() async {
    if (!_isDescricaoValida) {
      _showError(
        'A descrição é obrigatória e deve ter até $_maxDescricaoLength caracteres.',
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = await UserDao().getCurrentUser();
      if (user == null) throw Exception('Usuário não autenticado');

      final endereco = widget.dados['endereco'] as Map<String, dynamic>?;

      final resultado = await _solicitacaoServico.criarSolicitacao(
        serviceSlug: widget.dados['slug'] ?? '',
        descricao: _descricaoController.text.trim(),
        observacao: _observacaoController.text.trim().isEmpty
            ? null
            : _observacaoController.text.trim(),
        userId: user.id ?? 1,
        latitude: endereco?['latitude'],
        longitude: endereco?['longitude'],
        cep: endereco?['cep'],
        logradouro: endereco?['logradouro'],
        numero: endereco?['numero'],
        bairro: endereco?['bairro'],
        cidade: endereco?['cidade'],
        estado: endereco?['estado'],
        imagens: _imagens,
      );

      _handleResultado(resultado);
    } catch (e) {
      ConsoleLog.error('Erro ao enviar solicitação: $e');
      _showError('Não foi possível enviar a solicitação. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _handleResultado(Map<String, dynamic> resultado) {
    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado['message'] ?? 'Solicitação enviada com sucesso!',
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/');
      });
    } else {
      _showError(resultado['message'] ?? 'Erro ao processar a solicitação.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

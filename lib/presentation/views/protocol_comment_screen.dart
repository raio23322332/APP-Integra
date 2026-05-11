import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/protocol_model.dart';
import '../../presentation/viewmodels/protocol/protocol_viewmodel.dart';
import '../../../services/http/protocol_http.dart';
import '../../core/theme/app_colors.dart';
import './protocols/protocol_app_bar.dart';

class ProtocolCommentScreen extends StatefulWidget {
  final ProtocolModel protocol;

  const ProtocolCommentScreen({super.key, required this.protocol});

  @override
  State<ProtocolCommentScreen> createState() => _ProtocolCommentScreenState();
}

class _ProtocolCommentScreenState extends State<ProtocolCommentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _loading = false;
  late final ProtocolViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProtocolViewModel(ProtocolHttp(), context.read(), context.read());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        key: const Key('protocol_comment_scaffold'),
        backgroundColor: AppColors.background,
        appBar: protocolAppBar(title: 'Comentar Protocolo'),
        body: SingleChildScrollView(
          key: const Key('protocol_comment_scroll'),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              key: const Key('protocol_comment_form_column'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                protocolSectionCard(
                  icon: Icons.folder_copy_outlined,
                  title: 'Protocolo',
                  child: Column(
                    children: [
                      _infoRow(Icons.tag, 'Número', widget.protocol.number),
                      const SizedBox(height: 8),
                      _infoRow(Icons.business, 'Setor Atual', widget.protocol.sector?.name ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                protocolSectionCard(
                  icon: Icons.comment,
                  title: 'Comentário',
                  child: TextFormField(
                    key: const Key('protocol_comment_message_field'),
                    controller: _messageController,
                    decoration: protocolInputDecoration(
                      label: 'Comentário *',
                      hint: 'Digite seu comentário aqui...',
                      prefixIcon: Icons.comment,
                    ),
                    maxLines: 4,
                    validator: (value) => value?.trim().isEmpty == true ? 'Informe o comentário' : null,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('protocol_comment_submit_button'),
                    onPressed: _loading ? null : _commentProtocol,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Comentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _commentProtocol() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _viewModel.commentProtocol(
        widget.protocol.id,
        message: _messageController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentário adicionado com sucesso!'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao adicionar comentário'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

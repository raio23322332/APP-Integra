// presentation/views/protocol_receive_screen.dart
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import 'package:provider/provider.dart';
import '../../data/models/protocol_model.dart';
import '../../presentation/viewmodels/protocol/protocol_viewmodel.dart';
import '../../../services/http/protocol_http.dart';
import '../../core/theme/app_colors.dart';


class ProtocolReceiveScreen extends StatefulWidget {
  final ProtocolModel protocol;

  const ProtocolReceiveScreen({super.key, required this.protocol});

  @override
  State<ProtocolReceiveScreen> createState() => _ProtocolReceiveScreenState();
}

class _ProtocolReceiveScreenState extends State<ProtocolReceiveScreen> {
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
        key: const Key('protocol_receive_scaffold'),
        backgroundColor: AppColors.background,
        appBar: protocolAppBar(title: 'Receber Protocolo'),
        body: SingleChildScrollView(
          key: const Key('protocol_receive_scroll'),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              key: const Key('protocol_receive_form_column'),
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
                  icon: Icons.inbox,
                  title: 'Recebimento',
                  child: TextFormField(
                    key: const Key('protocol_receive_message_field'),
                    controller: _messageController,
                    decoration: protocolInputDecoration(
                      label: 'Mensagem de Recebimento (opcional)',
                      hint: 'Adicione uma mensagem...',
                      prefixIcon: Icons.inbox,
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('protocol_receive_submit_button'),
                    onPressed: _loading ? null : _receiveProtocol,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Receber', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 14, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
      ],
    );
  }

  Future<void> _receiveProtocol() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _viewModel.receiveProtocol(
        widget.protocol.id,
        message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Protocolo recebido com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
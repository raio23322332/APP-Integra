// presentation/views/protocols/protocol_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/protocol/protocol_viewmodel.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/protocol_model.dart';
import '../../../services/http/protocol_http.dart';
import '../../../services/navigation_service.dart';
import '../../../core/theme/app_colors.dart';


class ProtocolEditScreen extends StatefulWidget {
  final ProtocolModel protocol;

  const ProtocolEditScreen({super.key, required this.protocol});

  @override
  State<ProtocolEditScreen> createState() => _ProtocolEditScreenState();
}

class _ProtocolEditScreenState extends State<ProtocolEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _notesController = TextEditingController();
  final _documentTypeController = TextEditingController();

  String? _documentType;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _subjectController.text = widget.protocol.subject;
    _notesController.text = widget.protocol.notes ?? '';
    _documentTypeController.text = widget.protocol.documentType ?? '';
    _documentType = widget.protocol.documentType;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    _documentTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('protocol_edit_scaffold'),
      backgroundColor: AppColors.background,
      appBar: protocolAppBar(
        title: 'Editar Protocolo',
        actions: [
          IconButton(
            key: const Key('protocol_edit_app_bar_save_button'),
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            onPressed: _loading ? null : _updateProtocol,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : SingleChildScrollView(
              key: const Key('protocol_edit_scroll'),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  key: const Key('protocol_edit_form_column'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainFieldsCard(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── CARDS ───────────────────────────────────────────────────────────────

  Widget _buildMainFieldsCard() {
    return protocolSectionCard(
      icon: Icons.edit_note,
      title: 'Informações',
      child: Column(
        key: const Key('protocol_edit_main_fields_card'),
        children: [
          TextFormField(
            key: const Key('protocol_edit_document_type_field'),
            controller: _documentTypeController,
            decoration: protocolInputDecoration(
              label: 'Tipo do Documento *',
              hint: 'Ex: Ofício, Memorando, Requerimento...',
              prefixIcon: Icons.description,
            ),
            maxLength: 80,
            buildCounter: _buildCounter,
            validator: (v) => v == null || v.trim().isEmpty ? 'Informe o tipo do documento' : null,
            onChanged: (v) => setState(() => _documentType = v.trim().isEmpty ? null : v.trim()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('protocol_edit_subject_field'),
            controller: _subjectController,
            decoration: protocolInputDecoration(
              label: 'Assunto *',
              hint: 'Descreva o assunto do protocolo...',
              prefixIcon: Icons.subject,
            ),
            maxLength: 255,
            maxLines: 2,
            buildCounter: _buildCounter,
            validator: (v) => v == null || v.trim().isEmpty ? 'Informe o assunto' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('protocol_edit_notes_field'),
            controller: _notesController,
            decoration: protocolInputDecoration(
              label: 'Observações',
              hint: 'Informações adicionais (opcional)...',
              prefixIcon: Icons.note_outlined,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        key: const Key('protocol_edit_submit_button'),
        onPressed: _loading ? null : _updateProtocol,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: _loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Salvar Alterações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget? _buildCounter(BuildContext context, {required int currentLength, required bool isFocused, int? maxLength}) {
    return Text(
      '$currentLength/${maxLength ?? ''}',
      style: TextStyle(
        fontSize: 12,
        color: maxLength != null && currentLength > maxLength * 0.9 ? AppColors.error : Colors.grey,
      ),
    );
  }

  Future<void> _updateProtocol() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final auth = context.read<AuthViewModel>();
      final nav = context.read<NavigationService>();
      final viewModel = ProtocolViewModel(ProtocolHttp(), auth, nav);

      await viewModel.updateProtocol(widget.protocol.id, {
        'subject': _subjectController.text,
        'documentType': _documentType,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      });

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.canPop(context) ? Navigator.pop(context) : context.go('/protocols');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Protocolo atualizado com sucesso!'), backgroundColor: Colors.green),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(label: 'Fechar', textColor: Colors.white, onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()),
            ));
          }
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
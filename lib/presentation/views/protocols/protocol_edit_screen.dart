// presentation/views/protocols/protocol_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/protocol_model.dart';
import '../../viewmodels/protocol/protocol_viewmodel.dart';
import '../../viewmodels/sector/sector_viewmodel.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../../services/http/protocol_http.dart';
import '../../../services/http/sector_http.dart';
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
  final _originProtocolController = TextEditingController();
  final _originAgencyController = TextEditingController();

  String? _selectedSectorId;
  String _direction = 'interno';
  String? _documentType;
  bool _isConfidential = false;
  bool _isEmergency = false;
  bool _loading = false;
  late final SectorViewModel _sectorViewModel;

  @override
  void initState() {
    super.initState();
    _subjectController.text = widget.protocol.subject;
    _notesController.text = widget.protocol.notes ?? '';
    _documentTypeController.text = widget.protocol.documentType ?? '';
    _originProtocolController.text = widget.protocol.originProtocol ?? '';
    _originAgencyController.text = widget.protocol.originAgency ?? '';
    _selectedSectorId = widget.protocol.sector?.id;
    _direction = widget.protocol.direction;
    _documentType = widget.protocol.documentType;
    _isConfidential = widget.protocol.isConfidential;
    _isEmergency = widget.protocol.isEmergency;

    final auth = context.read<AuthViewModel>();
    final nav = context.read<NavigationService>();
    _sectorViewModel = SectorViewModel(SectorHttp(), auth, nav);
    _sectorViewModel.loadSectors();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _notesController.dispose();
    _documentTypeController.dispose();
    _originProtocolController.dispose();
    _originAgencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _sectorViewModel,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: protocolAppBar(
          title: 'Editar Protocolo',
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              onPressed: _loading ? null : _updateProtocol,
              tooltip: 'Salvar',
            ),
          ],
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProtocolInfoCard(),
                      const SizedBox(height: 16),
                      _buildSectorCard(),
                      const SizedBox(height: 16),
                      _buildMainFieldsCard(),
                      const SizedBox(height: 16),
                      _buildOriginCard(),
                      const SizedBox(height: 16),
                      _buildClassificationCard(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ─── CARDS ───────────────────────────────────────────────────────────────

  Widget _buildProtocolInfoCard() {
    return protocolSectionCard(
      icon: Icons.info_outline,
      title: 'Protocolo',
      child: Column(
        children: [
          _infoRow(Icons.tag, 'Número', widget.protocol.number),
          const SizedBox(height: 8),
          _infoRow(Icons.circle, 'Status', widget.protocol.status),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, 'Criado em', _formatDate(widget.protocol.createdAt)),
        ],
      ),
    );
  }

  Widget _buildSectorCard() {
    return Consumer<SectorViewModel>(
      builder: (context, sectorVm, _) {
        if (sectorVm.loading) {
          return protocolSectionCard(
            icon: Icons.business,
            title: 'Setor',
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (sectorVm.error != null) {
          return protocolSectionCard(
            icon: Icons.business,
            title: 'Setor',
            child: _buildFeedbackBanner(
              icon: Icons.error_outline,
              message: 'Erro ao carregar setores.',
              color: AppColors.error,
              action: TextButton(
                onPressed: sectorVm.loadSectors,
                child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        }
        if (sectorVm.sectors.isEmpty) {
          return protocolSectionCard(
            icon: Icons.business,
            title: 'Setor',
            child: _buildFeedbackBanner(
              icon: Icons.warning_outlined,
              message: 'Nenhum setor encontrado.',
              color: AppColors.warning,
              action: TextButton(
                onPressed: sectorVm.loadSectors,
                child: const Text('Recarregar', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        }
        return protocolSectionCard(
          icon: Icons.business,
          title: 'Setor',
          child: DropdownButtonFormField<String>(
            value: _selectedSectorId,
            decoration: protocolInputDecoration(label: 'Setor *', hint: 'Selecione um setor', prefixIcon: Icons.business),
            items: sectorVm.sectors.map((s) => DropdownMenuItem(
              value: s.id,
              child: Text('${s.code.toString().padLeft(3, '0')} - ${s.name}', style: const TextStyle(fontSize: 14)),
            )).toList(),
            validator: (v) => v == null || v.isEmpty ? 'Selecione um setor' : null,
            onChanged: (v) => setState(() => _selectedSectorId = v),
          ),
        );
      },
    );
  }

  Widget _buildMainFieldsCard() {
    return protocolSectionCard(
      icon: Icons.edit_note,
      title: 'Informações',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _direction,
            decoration: protocolInputDecoration(label: 'Direção', prefixIcon: Icons.swap_horiz),
            items: const [
              DropdownMenuItem(value: 'entrada', child: Text('Entrada')),
              DropdownMenuItem(value: 'saida', child: Text('Saída')),
              DropdownMenuItem(value: 'interno', child: Text('Interno')),
            ],
            onChanged: (v) => setState(() => _direction = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
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

  Widget _buildOriginCard() {
    return protocolSectionCard(
      icon: Icons.history,
      title: 'Dados de Origem (opcional)',
      child: Column(
        children: [
          TextFormField(
            controller: _originProtocolController,
            decoration: protocolInputDecoration(label: 'Protocolo de Origem', hint: 'Número do protocolo original...', prefixIcon: Icons.tag),
            maxLength: 120,
            buildCounter: _buildCounter,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _originAgencyController,
            decoration: protocolInputDecoration(label: 'Órgão de Origem', hint: 'Órgão emissor original...', prefixIcon: Icons.account_balance),
            maxLength: 120,
            buildCounter: _buildCounter,
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationCard() {
    return protocolSectionCard(
      icon: Icons.flag_outlined,
      title: 'Classificação',
      child: Row(
        children: [
          Expanded(child: _buildCheckItem(
            label: 'Sigiloso',
            icon: Icons.lock,
            iconColor: Colors.red.shade600,
            value: _isConfidential,
            onTap: () => setState(() => _isConfidential = !_isConfidential),
          )),
          const SizedBox(width: 16),
          Expanded(child: _buildCheckItem(
            label: 'Emergência',
            icon: Icons.warning,
            iconColor: Colors.orange.shade600,
            value: _isEmergency,
            onTap: () => setState(() => _isEmergency = !_isEmergency),
          )),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
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

  // ─── HELPERS VISUAIS ─────────────────────────────────────────────────────

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

  Widget _buildCheckItem({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value ? AppColors.primaryBlue.withValues(alpha: 0.06) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value ? AppColors.primaryBlue.withValues(alpha: 0.4) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: value ? AppColors.primaryBlue : Colors.grey.shade400, width: 2),
                borderRadius: BorderRadius.circular(4),
                color: value ? AppColors.primaryBlue : Colors.transparent,
              ),
              child: value ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 14, color: AppColors.darkText, fontWeight: value ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner({required IconData icon, required String message, required Color color, required Widget action}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w500))),
          action,
        ],
      ),
    );
  }

  Widget? _buildCounter(BuildContext context, {required int currentLength, required bool isFocused, int? maxLength}) {
    return Text('$currentLength/${maxLength ?? ''}', style: TextStyle(fontSize: 12, color: maxLength != null && currentLength > maxLength * 0.9 ? AppColors.error : Colors.grey));
  }

  String _formatDate(String? d) {
    if (d == null || d.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) { return d; }
  }

  // ─── LÓGICA (original preservada) ────────────────────────────────────────

  Future<void> _updateProtocol() async {
    if (!_formKey.currentState!.validate() || _selectedSectorId == null) return;
    setState(() => _loading = true);

    try {
      final auth = context.read<AuthViewModel>();
      final nav = context.read<NavigationService>();
      final viewModel = ProtocolViewModel(ProtocolHttp(), auth, nav);

      await viewModel.updateProtocol(widget.protocol.id, {
        'sectorId': _selectedSectorId!,
        'direction': _direction,
        'subject': _subjectController.text,
        'documentType': _documentType,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        'originProtocol': _originProtocolController.text.isNotEmpty ? _originProtocolController.text : null,
        'originAgency': _originAgencyController.text.isNotEmpty ? _originAgencyController.text : null,
        'isConfidential': _isConfidential,
        'isEmergency': _isEmergency,
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
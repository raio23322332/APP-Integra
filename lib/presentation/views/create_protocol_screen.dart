// presentation/views/create_protocol_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/protocol/protocol_viewmodel.dart';
import '../viewmodels/sector/sector_viewmodel.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../../services/http/protocol_http.dart';
import '../../services/http/sector_http.dart';
import '../../services/navigation_service.dart';
import '../../core/theme/app_colors.dart';


class CreateProtocolScreen extends StatefulWidget {
  const CreateProtocolScreen({super.key});

  @override
  State<CreateProtocolScreen> createState() => _CreateProtocolScreenState();
}

class _CreateProtocolScreenState extends State<CreateProtocolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _notesController = TextEditingController();
  final _documentTypeController = TextEditingController();
  final _originProtocolController = TextEditingController();
  final _originAgencyController = TextEditingController();
  final _registeredAtController = TextEditingController();

  String? _selectedSectorId;
  String _direction = 'interno';
  String? _documentType;
  bool _isConfidential = false;
  bool _isEmergency = false;
  bool _loading = false;
  DateTime? _selectedDate;
  late final SectorViewModel _sectorViewModel;

  bool get _isPredated {
    if (_selectedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    return selected.isBefore(today);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _registeredAtController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
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
    _registeredAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _sectorViewModel,
      child: Scaffold(
        key: const Key('create_protocol_scaffold'),
        backgroundColor: AppColors.background,
        appBar: protocolAppBar(
          title: 'Novo Protocolo',
          actions: [
            IconButton(
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              onPressed: _loading ? null : _createProtocol,
              tooltip: 'Salvar',
            ),
          ],
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : SingleChildScrollView(
                key: const Key('create_protocol_scroll'),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectorCard(),
                      const SizedBox(height: 16),
                      _buildMainFieldsCard(),
                      const SizedBox(height: 16),
                      _buildDateCard(),
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

  Widget _buildSectorCard() {
    return Consumer<SectorViewModel>(
      key: const Key('create_protocol_sector_consumer'),
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
            key: const Key('create_protocol_sector_dropdown'),
            value: _selectedSectorId,
            decoration: protocolInputDecoration(
              label: 'Setor *',
              hint: 'Selecione um setor',
              prefixIcon: Icons.business,
            ),
            isExpanded: true,
            items: sectorVm.sectors.map((s) => DropdownMenuItem(
              key: Key('sector_item_${s.id}'),
              value: s.id,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${s.code.toString().padLeft(3, '0')} - ${s.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
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
      key: const Key('create_protocol_main_fields_card'),
      icon: Icons.edit_note,
      title: 'Informações',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: const Key('create_protocol_direction_dropdown'),
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
            key: const Key('create_protocol_document_type_field'),
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
            key: const Key('create_protocol_subject_field'),
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
            key: const Key('create_protocol_notes_field'),
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

  Widget _buildDateCard() {
    return protocolSectionCard(
      key: const Key('create_protocol_date_card'),
      icon: Icons.calendar_today,
      title: 'Data do Protocolo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: const Key('create_protocol_date_field'),
            controller: _registeredAtController,
            readOnly: true,
            decoration: protocolInputDecoration(
              label: 'Data do Protocolo *',
              hint: 'Clique para selecionar a data...',
              prefixIcon: Icons.calendar_today,
            ),
            validator: (v) => v == null || v.isEmpty 
              ? 'Selecione a data do protocolo' 
              : null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('pt', 'BR'),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primaryBlue,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.darkText,
                      ),
                    ),
                    child: child ?? const SizedBox(),
                  );
                },
              );
              
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _registeredAtController.text = 
                    DateFormat('dd/MM/yyyy').format(picked);
                });
              }
            },
          ),
          const SizedBox(height: 8),
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Data selecionada: ${DateFormat('EEEE, dd de MMMM de yyyy', 'pt_BR').format(_selectedDate!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (_isPredated)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Protocolo predatado',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Este protocolo será registrado com data retroativa em ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOriginCard() {
    return protocolSectionCard(
      key: const Key('create_protocol_origin_card'),
      icon: Icons.history,
      title: 'Dados de Origem (opcional)',
      child: Column(
        children: [
          TextFormField(
            key: const Key('create_protocol_origin_protocol_field'),
            controller: _originProtocolController,
            decoration: protocolInputDecoration(
              label: 'Protocolo de Origem',
              hint: 'Número do protocolo original...',
              prefixIcon: Icons.tag,
            ),
            maxLength: 120,
            buildCounter: _buildCounter,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const Key('create_protocol_origin_agency_field'),
            controller: _originAgencyController,
            decoration: protocolInputDecoration(
              label: 'Órgão de Origem',
              hint: 'Órgão emissor original...',
              prefixIcon: Icons.account_balance,
            ),
            maxLength: 120,
            buildCounter: _buildCounter,
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationCard() {
    return protocolSectionCard(
      key: const Key('create_protocol_classification_card'),
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
          const SizedBox(width: 12),
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
      key: const Key('create_protocol_submit_button'),
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _createProtocol,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: _loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Criar Protocolo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ─── HELPERS VISUAIS ─────────────────────────────────────────────────────

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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? AppColors.primaryBlue.withValues(alpha: 0.06) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? AppColors.primaryBlue.withValues(alpha: 0.4) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                border: Border.all(color: value ? AppColors.primaryBlue : Colors.grey.shade400, width: 2),
                borderRadius: BorderRadius.circular(3),
                color: value ? AppColors.primaryBlue : Colors.transparent,
              ),
              child: value ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.darkText,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner({
    required IconData icon,
    required String message,
    required Color color,
    required Widget action,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
    return Text(
      '$currentLength/${maxLength ?? ''}',
      style: TextStyle(
        fontSize: 12,
        color: maxLength != null && currentLength > maxLength * 0.9 ? AppColors.error : Colors.grey,
      ),
    );
  }

  // ─── LÓGICA (original preservada) ────────────────────────────────────────

  Future<void> _createProtocol() async {
    if (!_formKey.currentState!.validate() || _selectedSectorId == null) return;
    setState(() => _loading = true);

    try {
      final auth = context.read<AuthViewModel>();
      final nav = context.read<NavigationService>();
      final viewModel = ProtocolViewModel(ProtocolHttp(), auth, nav);

      final payload = {
        'sectorId': _selectedSectorId!,
        'direction': _direction,
        'subject': _subjectController.text,
        'documentType': _documentType,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        'originProtocol': _originProtocolController.text.isNotEmpty ? _originProtocolController.text : null,
        'originAgency': _originAgencyController.text.isNotEmpty ? _originAgencyController.text : null,
        'isConfidential': _isConfidential,
        'isEmergency': _isEmergency,
        'registeredAt': _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null,
      };
      
      // Debug: verificar payload
      print('📋 Payload enviado do formulário: $payload');
      print('📅 Data selecionada: $_selectedDate');
      print('📅 Data formatada: ${_selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : "NULA"}');

      await viewModel.createProtocol(payload);

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.canPop(context) ? Navigator.pop(context) : context.go('/protocols');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Protocolo criado com sucesso!'), backgroundColor: Colors.green),
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
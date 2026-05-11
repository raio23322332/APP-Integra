import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/protocol_model.dart';
import '../../data/models/sector_model.dart';
import '../../presentation/viewmodels/protocol/protocol_viewmodel.dart';
import '../../services/http/sector_http.dart';
import '../../../services/http/protocol_http.dart';
import '../../../core/theme/app_colors.dart';
import './protocols/protocol_app_bar.dart';

class ProtocolForwardScreen extends StatefulWidget {
  final ProtocolModel protocol;

  const ProtocolForwardScreen({super.key, required this.protocol});

  @override
  State<ProtocolForwardScreen> createState() => _ProtocolForwardScreenState();
}

class _ProtocolForwardScreenState extends State<ProtocolForwardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String? _selectedSectorId;
  List<SectorModel> _sectors = [];
  bool _loading = false;
  late final ProtocolViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProtocolViewModel(ProtocolHttp(), context.read(), context.read());
    _loadSectors();
  }

  Future<void> _loadSectors() async {
    try {
      final sectorHttp = SectorHttp();
      _sectors = await sectorHttp.getSectors(isActive: true);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar setores: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        key: const Key('protocol_forward_scaffold'),
        backgroundColor: AppColors.background,
        appBar: protocolAppBar(
          title: 'Tramitar Protocolo ${widget.protocol.number}',
        ),
        body: SingleChildScrollView(
          key: const Key('protocol_forward_scroll'),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              key: const Key('protocol_forward_form_column'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProtocolInfoCard(),
                const SizedBox(height: 24),
                _buildDestinationSectorCard(),
                const SizedBox(height: 16),
                _buildMessageCard(),
                const SizedBox(height: 24),
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolInfoCard() {
    return protocolSectionCard(
      icon: Icons.description_outlined,
      title: 'Informações do Protocolo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailItem(Icons.tag, 'Número', widget.protocol.number),
          _detailItem(Icons.business, 'Setor Atual', widget.protocol.sector?.name ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDestinationSectorCard() {
    return protocolSectionCard(
      icon: Icons.send_outlined,
      title: 'Setor Destino',
      child: DropdownButtonFormField<String>(
        key: const Key('protocol_forward_sector_dropdown'),
        value: _selectedSectorId,
        decoration: protocolInputDecoration(
          label: 'Selecione o setor destino *',
          hint: 'Escolha um setor para tramitar',
          prefixIcon: Icons.business,
        ),
        isExpanded: true,
        items: _sectors.map((sector) {
          return DropdownMenuItem(
            value: sector.id,
            child: Text(
              '${sector.code.toString().padLeft(3, '0')} - ${sector.name}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        validator: (value) => value == null ? 'Selecione um setor destino' : null,
        onChanged: (value) => setState(() => _selectedSectorId = value),
      ),
    );
  }

  Widget _buildMessageCard() {
    return protocolSectionCard(
      icon: Icons.message_outlined,
      title: 'Mensagem (Opcional)',
      child: TextFormField(
        key: const Key('protocol_forward_message_field'),
        controller: _messageController,
        decoration: protocolInputDecoration(
          label: 'Observações',
          hint: 'Adicione uma mensagem para a tramitação',
          prefixIcon: Icons.comment,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        key: const Key('protocol_forward_submit_button'),
        onPressed: _loading ? null : _forwardProtocol,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: _loading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Tramitando...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Tramitar Protocolo'),
                ],
              ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _forwardProtocol() async {
    if (!_formKey.currentState!.validate() || _selectedSectorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um setor destino'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _viewModel.forwardProtocol(
        widget.protocol.id,
        toSectorId: _selectedSectorId!,
        message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Protocolo ${widget.protocol.number} tramitado com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao tramitar protocolo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: Colors.white,
              onPressed: () {
                if (!Navigator.canPop(context)) return;
                Navigator.pop(context);
                _forwardProtocol();
              },
            ),
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

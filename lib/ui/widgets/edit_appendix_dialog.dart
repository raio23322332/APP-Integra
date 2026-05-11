import 'package:flutter/material.dart';
import '../../../data/models/protocol_appendix_model.dart';
import '../../../services/http/sector_http.dart';

class EditAppendixDialog extends StatefulWidget {
  final String protocolId;
  final ProtocolAppendixModel appendix;
  final Function() onAppendixUpdated;

  const EditAppendixDialog({
    super.key,
    required this.protocolId,
    required this.appendix,
    required this.onAppendixUpdated,
  });

  @override
  State<EditAppendixDialog> createState() => _EditAppendixDialogState();
}

class _EditAppendixDialogState extends State<EditAppendixDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _documentTypeController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<Map<String, String>> _sectors = [];
  String? _selectedSectorId;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadSectors();
    _initializeFields();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _documentTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _titleController.text = widget.appendix.title;
    _documentTypeController.text = widget.appendix.documentType ?? '';
    _notesController.text = widget.appendix.notes ?? '';
    _selectedSectorId = widget.appendix.sectorId;
  }

  Future<void> _loadSectors() async {
    try {
      final sectorHttp = SectorHttp();
      final sectors = await sectorHttp.getSectors();
      
      setState(() {
        _sectors = sectors.map((sector) => {
          'id': sector.id,
          'name': sector.name,
        }).toList();
      });
    } catch (e) {
      // Fallback para dados mock se falhar
      setState(() {
        _sectors = [
          {'id': '1', 'name': 'Setor A'},
          {'id': '2', 'name': 'Setor B'},
          {'id': '3', 'name': 'Setor C'},
        ];
      });
    }
  }

  Future<void> _updateAppendix() async {
    if (!_formKey.currentState!.validate() || _selectedSectorId == null) {
      if (_selectedSectorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um setor'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      setState(() => _isUpdating = true);

      // TODO: Implementar chamada ao ProtocolHttp.updateAppendix
      // final updatedAppendix = await _protocolHttp.updateAppendix(
      //   protocolId: widget.protocolId,
      //   appendixId: widget.appendix.id,
      //   title: _titleController.text.trim(),
      //   sectorId: _selectedSectorId!,
      //   documentType: _documentTypeController.text.trim().isEmpty 
      //       ? null 
      //       : _documentTypeController.text.trim(),
      //   notes: _notesController.text.trim().isEmpty 
      //       ? null 
      //       : _notesController.text.trim(),
      // );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apenso atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAppendixUpdated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar apenso: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Editar Apenso',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 16),
            
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título do Apenso *',
                          hintText: 'Digite o título',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O título é obrigatório';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Tipo de Documento
                      TextFormField(
                        controller: _documentTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Tipo do Documento',
                          hintText: 'Ex: Ofício, Memorando, etc.',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Setor
                      DropdownButtonFormField<String>(
                        value: _selectedSectorId,
                        decoration: const InputDecoration(
                          labelText: 'Setor *',
                          hintText: 'Selecione o setor',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        items: _sectors.map((sector) {
                          return DropdownMenuItem<String>(
                            value: sector['id'],
                            child: Text(sector['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSectorId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um setor';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Observações
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Observações',
                          hintText: 'Observações adicionais (opcional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
                  child: const Text('CANCELAR'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_isUpdating || _titleController.text.trim().isEmpty || _selectedSectorId == null) 
                      ? null 
                      : _updateAppendix,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('ATUALIZAR APENSO'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

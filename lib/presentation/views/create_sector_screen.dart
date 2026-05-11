import 'package:flutter/material.dart';
import '../../../services/http/sector_http.dart';

class CreateSectorScreen extends StatefulWidget {
  const CreateSectorScreen({super.key});

  @override
  State<CreateSectorScreen> createState() => _CreateSectorScreenState();
}

class _CreateSectorScreenState extends State<CreateSectorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isActive = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Setor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Setor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Informe o código';
                  if (int.tryParse(value!) == null) return 'Código inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Setor Ativo'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _loading ? null : _createSector,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Criar Setor'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createSector() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final http = SectorHttp();

      await http.createSector(
        name: _nameController.text,
        code: int.parse(_codeController.text),
        isActive: _isActive,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setor criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

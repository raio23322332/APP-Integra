import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sector/sector_viewmodel.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../../../services/http/sector_http.dart';
import '../../../services/navigation_service.dart';
import '../../../data/models/sector_model.dart';

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  late final SectorViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    final nav = context.read<NavigationService>();
    final http = SectorHttp();
    
    _viewModel = SectorViewModel(http, auth, nav);
    _viewModel.loadSectors();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setores'),
          actions: [
            Consumer<SectorViewModel>(
              builder: (context, vm, child) => IconButton(
                icon: Icon(vm.showInactive ? Icons.visibility_off : Icons.visibility),
                onPressed: vm.toggleInactive,
              ),
            ),
            Consumer<SectorViewModel>(
              builder: (context, vm, child) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: vm.loadSectors,
              ),
            ),
          ],
        ),
        body: Consumer<SectorViewModel>(
          builder: (context, vm, child) {
            if (vm.loading && vm.sectors.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null && vm.sectors.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64),
                    const SizedBox(height: 16),
                    Text(vm.error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: vm.loadSectors,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (vm.sectors.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business, size: 64),
                    SizedBox(height: 16),
                    Text('Nenhum setor encontrado'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: vm.loadSectors,
              child: ListView.builder(
                itemCount: vm.sectors.length,
                itemBuilder: (context, index) {
                  final sector = vm.sectors[index];
                  return SectorCard(
                    sector: sector,
                    onEdit: () => vm.goEdit(sector),
                    onDelete: () => _showDeleteDialog(sector),
                    onToggle: () => vm.toggleStatus(sector.id),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: Consumer<SectorViewModel>(
          builder: (context, vm, child) => FloatingActionButton(
            onPressed: vm.goCreate,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(SectorModel sector) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${sector.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.deleteSector(sector.id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class SectorCard extends StatelessWidget {
  final SectorModel sector;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const SectorCard({
    super.key,
    required this.sector,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(sector.code.toString()),
        ),
        title: Text(
          sector.name,
          style: TextStyle(
            decoration: sector.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text('Código: ${sector.code}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                sector.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: sector.isActive ? Colors.green : Colors.grey,
              ),
              onPressed: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}

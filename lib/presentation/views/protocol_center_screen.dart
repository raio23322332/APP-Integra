import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../viewmodels/protocol/protocol_viewmodel.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../viewmodels/sector/sector_viewmodel.dart';
import '../../services/navigation_service.dart';
import '../../services/http/protocol_http.dart';
import '../../services/http/sector_http.dart';
import '../../data/models/protocol_model.dart';
import '../../data/models/sector_model.dart';
import 'create_protocol_screen.dart';
import 'protocols_screen.dart';
import 'protocols/protocol_app_bar.dart';

class ProtocolCenterScreen extends StatefulWidget {
  const ProtocolCenterScreen({super.key});

  @override
  State<ProtocolCenterScreen> createState() => _ProtocolCenterScreenState();
}

class _ProtocolCenterScreenState extends State<ProtocolCenterScreen> {
  ProtocolViewModel? _viewModel;
  SectorViewModel? _sectorViewModel;
  bool _isViewModelReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = ProtocolViewModel(
        ProtocolHttp(),
        context.read<AuthViewModel>(),
        context.read<NavigationService>(),
      );
      
      _sectorViewModel = SectorViewModel(
        SectorHttp(),
        context.read<AuthViewModel>(),
        context.read<NavigationService>(),
      );
      
      _viewModel!.loadProtocols();
      _sectorViewModel!.loadSectors();
      
      setState(() {
        _isViewModelReady = true;
      });
    });
  }

  @override
  void dispose() {
    _viewModel?.removeListener(() {});
    _sectorViewModel?.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: protocolAppBar(title: 'Central de Protocolos'),
      body: _isViewModelReady ? _buildBody() : _buildLoading(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryBlue),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O que você deseja fazer?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha uma das opções abaixo para gerenciar seus protocolos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Opção 1: Criar Protocolo
          _buildOptionCard(
            icon: Icons.add_circle,
            title: 'Criar Protocolo',
            subtitle: 'Novo protocolo para registrar documentos',
            color: AppColors.primaryBlue,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateProtocolScreen()),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Opção 2: Meus Protocolos
          _buildOptionCard(
            icon: Icons.folder,
            title: 'Meus Protocolos',
            subtitle: 'Ver todos os protocolos que criei',
            color: Colors.green,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProtocolsScreen()),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Opção 3: Protocolos Tramitados
          _buildOptionCard(
            icon: Icons.send,
            title: 'Protocolos Tramitados',
            subtitle: 'Ver protocolos que foram tramitados',
            color: Colors.orange,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TramitedProtocolsScreen(
                  viewModel: _viewModel!,
                  sectorViewModel: _sectorViewModel!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: AppColors.lightSurface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withValues(alpha: 0.1),
          highlightColor: color.withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Container do ícone com animação
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightPrimaryText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.lightSecondaryText,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Setinha animada
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(10 * (1 - value), 0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: color,
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TramitedProtocolsScreen extends StatefulWidget {
  final ProtocolViewModel viewModel;
  final SectorViewModel sectorViewModel;

  const TramitedProtocolsScreen({
    super.key,
    required this.viewModel,
    required this.sectorViewModel,
  });

  @override
  State<TramitedProtocolsScreen> createState() => _TramitedProtocolsScreenState();
}

class _TramitedProtocolsScreenState extends State<TramitedProtocolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSectorId;
  List<ProtocolModel> _filteredProtocols = [];
  List<SectorModel> _availableSectors = [];

  @override
  void initState() {
    super.initState();
    _filterProtocols();
    
    widget.viewModel.addListener(() {
      if (mounted) _filterProtocols();
    });
    
    widget.sectorViewModel.addListener(() {
      if (mounted) {
        _availableSectors = widget.sectorViewModel.sectors;
        _filterProtocols();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProtocols() {
    final protocols = widget.viewModel.protocols;
    _availableSectors = widget.sectorViewModel.sectors;
    
    // Filtrar apenas protocolos tramitados (que têm movimentações FORWARDED)
    _filteredProtocols = protocols.where((protocol) {
      // Verificar se o protocolo tem alguma movimentação do tipo FORWARDED
      final hasForwardedMovement = protocol.movements?.any((movement) => 
        movement.action.toUpperCase() == 'FORWARDED'
      ) ?? false;
      
      if (!hasForwardedMovement) return false;
      
      // Aplicar filtros de busca e setor
      final query = _searchController.text.toLowerCase().trim();
      final matchesText = query.isEmpty || 
          protocol.number.toLowerCase().contains(query) ||
          protocol.subject.toLowerCase().contains(query) ||
          (protocol.documentType?.toLowerCase().contains(query) ?? false);
      
      final matchesSector = _selectedSectorId == null || protocol.sectorId == _selectedSectorId;
      
      return matchesText && matchesSector;
    }).toList();
    
    setState(() {});
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Data não informada';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return 'Data inválida';
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrar Protocolos Tramitados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            
            // Filtro por setor
            Text(
              'Setor',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSectorId,
                  hint: Text('Todos os setores'),
                  items: [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    ..._availableSectors.map((sector) => DropdownMenuItem(
                      value: sector.id,
                      child: Text(sector.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSectorId = value;
                    });
                    _filterProtocols();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSectorId = null;
                      });
                      _filterProtocols();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Limpar Filtros',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Fechar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: protocolAppBar(title: 'Protocolos Tramitados'),
      body: Column(
        children: [
          // Campo de busca e filtros usando padrão do projeto
          protocolSectionCard(
            icon: Icons.search,
            title: 'Buscar Protocolos Tramitados',
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterProtocols(),
                  decoration: protocolInputDecoration(
                    label: 'Buscar',
                    hint: 'Número, assunto ou tipo...',
                    prefixIcon: Icons.search,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showFilterOptions(context),
                        icon: Icon(
                          Icons.filter_list,
                          color: _selectedSectorId != null ? AppColors.primaryBlue : Colors.grey[600],
                          size: 20,
                        ),
                        label: Text(
                          _selectedSectorId != null ? 'Filtrado' : 'Filtrar por setor',
                          style: TextStyle(
                            color: _selectedSectorId != null ? AppColors.primaryBlue : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: _selectedSectorId != null ? AppColors.primaryBlue : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterProtocols();
                        },
                        tooltip: 'Limpar busca',
                      ),
                    ],
                  ],
                ),
                
                // Filtro ativo
                if (_selectedSectorId != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: AppColors.primaryBlue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtrando por setor',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSectorId = null;
                            });
                            _filterProtocols();
                          },
                          child: Icon(Icons.clear, color: AppColors.primaryBlue, size: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Lista de protocolos tramitados
          Expanded(
            child: _filteredProtocols.isEmpty
                ? _buildEmptyState()
                : _buildProtocolsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum protocolo tramitado encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Protocolos tramitados aparecerão aqui',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolsList() {
    return RefreshIndicator(
      onRefresh: widget.viewModel.loadProtocols,
      color: Colors.orange,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: _filteredProtocols.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final protocol = _filteredProtocols[index];
          return _buildProtocolCard(protocol);
        },
      ),
    );
  }

  Widget _buildProtocolCard(ProtocolModel protocol) {
    // Encontrar a última movimentação FORWARDED
    final lastForwardedMovement = protocol.movements
        ?.where((m) => m.action.toUpperCase() == 'FORWARDED')
        .reduce((a, b) => DateTime.parse(a.movedAt).isAfter(DateTime.parse(b.movedAt)) ? a : b);
    
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              color: Colors.white,
              shadowColor: Colors.black.withValues(alpha: 0.08),
              child: InkWell(
                onTap: () {
                  // Navegar para detalhes do protocolo usando GoRouter
                  context.push('/protocolos/detail', extra: protocol);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com número e data
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.send,
                              color: AppColors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  protocol.number,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tramitado em ${_formatDate(lastForwardedMovement?.movedAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.lightSecondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Assunto
                      Text(
                        protocol.subject,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Setor de destino
                      if (lastForwardedMovement?.toSectorName != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.orange.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: AppColors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Para: ${lastForwardedMovement!.toSectorName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

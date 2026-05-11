import 'package:flutter/material.dart';
import 'package:integra_app/presentation/views/protocols/protocol_app_bar.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../viewmodels/protocol/protocol_viewmodel.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../viewmodels/sector/sector_viewmodel.dart';
import '../viewmodels/protocol/protocol_notification_viewmodel.dart';
import '../../services/navigation_service.dart';
import '../../data/models/protocol_model.dart';
import '../../data/models/sector_model.dart';
import 'protocols/protocol_detail_view.dart';
import 'protocol_notification_screen.dart';
import '../../services/http/protocol_http.dart';
import '../../services/http/sector_http.dart';

class ProtocolsScreen extends StatefulWidget {
  const ProtocolsScreen({super.key});

  @override
  State<ProtocolsScreen> createState() => _ProtocolsScreenState();
}

class _ProtocolsScreenState extends State<ProtocolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSectorId;
  String? _selectedStatus;
  List<ProtocolModel> _filteredProtocols = [];
  List<SectorModel> _availableSectors = [];
  final List<String> _availableStatuses = [
    'ATIVO',
    'CANCELADO',
    'ARQUIVADO',
  ];
  
  // Paginação
  int _currentPage = 1;
  int _itemsPerPage = 10;
  final List<int> _itemsPerPageOptions = [10, 25, 50, 100];
  
  ProtocolViewModel? _viewModel;
  SectorViewModel? _sectorViewModel;
  bool _isViewModelReady = false;

  @override
  void initState() {
    super.initState();
    // Criar ViewModels usando dependências do Provider
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
      
      // Carregar dados
      _viewModel!.loadProtocols();
      _sectorViewModel!.loadSectors();
      
      // Notificações serão carregadas no build method quando o Provider estiver disponível
      
      // Adicionar listeners
      _viewModel!.addListener(() {
        if (mounted) {
          _filterProtocols();
        }
      });
      
      _sectorViewModel!.addListener(() {
        if (mounted) {
          _filterProtocols();
        }
      });
      
      setState(() {
        _isViewModelReady = true;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel?.removeListener(() {});
    _sectorViewModel?.removeListener(() {});
    super.dispose();
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProtocolNotificationScreen(),
      ),
    );
  }

  void _filterProtocols() {
    if (!mounted || !_isViewModelReady || _viewModel == null) return;
    
    final protocols = _viewModel!.protocols;
    
    // Resetar para página 1 quando filtros mudam
    if (_currentPage != 1) {
      _currentPage = 1;
    }
    
    // Usar setores do SectorViewModel (carregados da API)
    if (_sectorViewModel != null) {
      _availableSectors = _sectorViewModel!.sectors;
    }
    
    // Debug específico para status CANCELADO
    if (_selectedStatus == 'CANCELED') {
      print('=== DEBUG CANCELADO ===');
      print('Status selecionado: "$_selectedStatus"');
      print('Protocolos com status CANCELADO:');
      for (final p in protocols) {
        if (p.status.toUpperCase().contains('CANCEL')) {
          print('  - ${p.number}: status="${p.status}"');
        }
      }
      print('========================');
    }
    
    _filteredProtocols = protocols.where((p) {
      final query = _searchController.text.toLowerCase().trim();
      final matchesText = query.isEmpty || 
          p.number.toLowerCase().contains(query) ||
          p.subject.toLowerCase().contains(query) ||
          (p.documentType?.toLowerCase().contains(query) ?? false);
      
      final matchesSector = _selectedSectorId == null || p.sectorId == _selectedSectorId;
      
      // Debug específico para comparação
      final protocolStatus = p.status.toUpperCase();
      final selectedStatus = _selectedStatus?.toUpperCase() ?? '';
      final matchesStatus = _selectedStatus == null || protocolStatus == selectedStatus;
      
      if (_selectedStatus == 'CANCELED' && protocolStatus.contains('CANCEL')) {
        print('  ${p.number}: "$protocolStatus" == "$selectedStatus" ? $matchesStatus');
      }
      
      return matchesText && matchesSector && matchesStatus;
    }).toList();
    
    if (_selectedStatus == 'CANCELED') {
      print('Protocolos filtrados (CANCELADO): ${_filteredProtocols.length}');
      print('========================');
    }
    
    setState(() {});
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ATIVO':
        return 'Ativo';
      case 'CANCELADO':
        return 'Cancelado';
      case 'ARQUIVADO':
        return 'Arquivado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ATIVO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.red;
      case 'ARQUIVADO':
        return Colors.grey;
      default:
        return Colors.grey;
    }
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
              'Filtrar Protocolos',
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
            
            // Filtro por status
            Text(
              'Status',
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
                  value: _selectedStatus,
                  hint: Text('Todos os status'),
                  items: [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    ..._availableStatuses.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_formatStatus(status)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
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
                        _selectedStatus = null;
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

  Widget _buildFilterWidget() {
    if (!mounted) {
      return Container();
    }
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Título do filtro
          Expanded(
            child: Text(
              _getFilterTitle(),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Botão limpar (sempre visível quando há filtro)
          if (_selectedSectorId != null || _selectedStatus != null)
            GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() {
                  _selectedSectorId = null;
                  _selectedStatus = null;
                });
                _filterProtocols();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Limpar Filtro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFilterTitle() {
    try {
      final sectorFilter = _selectedSectorId != null 
          ? _availableSectors.firstWhere((s) => s.id == _selectedSectorId, orElse: () => _availableSectors.first).name 
          : null;
      final statusFilter = _selectedStatus != null ? _formatStatus(_selectedStatus!) : null;
      
      if (sectorFilter != null && statusFilter != null) {
        return 'Setor: $sectorFilter, Status: $statusFilter';
      } else if (sectorFilter != null) {
        return 'Setor: $sectorFilter';
      } else if (statusFilter != null) {
        return 'Status: $statusFilter';
      }
      return 'Filtros ativos';
    } catch (e) {
      return 'Filtros ativos';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProtocolNotificationViewModel(),
      child: Builder(
        builder: (context) {
          // Carregar notificações aqui onde o Provider está disponível
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final notificationViewModel = context.read<ProtocolNotificationViewModel>();
              notificationViewModel.loadNotifications();
            }
          });
          
          if (!_isViewModelReady || _viewModel == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: protocolAppBar(
                title: 'Protocolos',
                actions: const [],
              ),
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            );
          }

    return Scaffold(
        key: const Key('protocol_list_scaffold'),
        backgroundColor: AppColors.background,
        appBar: protocolAppBar(
          title: 'Protocolos',
          actions: [
            Consumer<ProtocolNotificationViewModel>(
              builder: (context, notificationViewModel, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.white),
                      onPressed: () => _navigateToNotifications(context),
                      tooltip: 'Notificações',
                    ),
                    if (notificationViewModel.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            notificationViewModel.unreadCount > 9 
                                ? '9+' 
                                : '${notificationViewModel.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_viewModel!.loading)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _viewModel!.loadProtocols,
                tooltip: 'Atualizar',
              ),
          ],
        ),
        body: _buildBody(context, _viewModel!),
        floatingActionButton: FloatingActionButton(
          key: const Key('protocol_list_create_fab'),
          onPressed: _viewModel!.goCreate,
          backgroundColor: Colors.white,
          child: Icon(Icons.add, color: AppColors.primaryBlue),
        ),
      );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProtocolViewModel vm) {
    if (vm.loading && vm.protocols.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBlue),
            SizedBox(height: 16),
            Text('Carregando protocolos...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (vm.error != null && vm.protocols.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar protocolos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const SizedBox(height: 8),
              Text(
                vm.error!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: vm.loadProtocols,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.protocols.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum protocolo encontrado',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Crie seu primeiro protocolo usando o botão +',
              style: TextStyle(color: const Color(0xFF757575)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Campo de busca e filtros
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Campo de busca
              TextField(
                controller: _searchController,
                onChanged: (value) => _filterProtocols(),
                decoration: InputDecoration(
                  hintText: 'Buscar por número, assunto ou tipo...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                  suffixIcon: SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Filtro de protocolo
                        GestureDetector(
                          onTap: () => _showFilterOptions(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Icon(
                              Icons.filter_list,
                              color: (_selectedSectorId != null || _selectedStatus != null) 
                                  ? AppColors.primaryBlue 
                                  : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                        // Botão limpar busca
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterProtocols();
                            },
                          ),
                      ],
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
              
              // Filtros ativos
              if (_selectedSectorId != null || _selectedStatus != null)
                _buildFilterWidget(),
            ],
          ),
        ),

        // Lista de protocolos
        Expanded(
          child: _buildProtocolsList(vm),
        ),
      ],
    );
  }

  int get _totalPages {
    final hasFilters = _searchController.text.isNotEmpty || 
                     _selectedSectorId != null || 
                     _selectedStatus != null;
    final displayList = hasFilters ? _filteredProtocols : (_viewModel?.protocols ?? []);
    return (displayList.length / _itemsPerPage).ceil();
  }

  List<ProtocolModel> get _paginatedProtocols {
    final hasFilters = _searchController.text.isNotEmpty || 
                     _selectedSectorId != null || 
                     _selectedStatus != null;
    final displayList = hasFilters ? _filteredProtocols : (_viewModel?.protocols ?? []);
    
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= displayList.length) {
      return [];
    }
    
    return displayList.sublist(startIndex, endIndex.clamp(0, displayList.length));
  }

  Widget _buildProtocolsList(ProtocolViewModel vm) {
    final hasFilters = _searchController.text.isNotEmpty || 
                     _selectedSectorId != null || 
                     _selectedStatus != null;
    
    final displayList = hasFilters ? _filteredProtocols : vm.protocols;
    final paginatedList = _paginatedProtocols;

    if (displayList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Nenhum protocolo encontrado\npara os filtros selecionados',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _selectedSectorId = null;
                  _selectedStatus = null;
                  _filterProtocols();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: vm.loadProtocols,
            color: AppColors.primaryBlue,
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 6,
              radius: const Radius.circular(6),
              child: ListView.separated(
                key: const Key('protocol_list_view'),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: paginatedList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final protocol = paginatedList[index];
                  return _buildProtocolCard(protocol);
                },
              ),
            ),
          ),
        ),
        _buildPaginationControls(displayList.length),
      ],
    );
  }

  Widget _buildPaginationControls(int totalItems) {
    if (totalItems == 0 || _totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage + 1;
    final endIndex = (_currentPage * _itemsPerPage).clamp(0, totalItems);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mostrando $startIndex a $endIndex de $totalItems',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              DropdownButton<int>(
                value: _itemsPerPage,
                items: _itemsPerPageOptions.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value por página'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _itemsPerPage = value;
                      _currentPage = 1;
                    });
                  }
                },
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                underline: const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage = 1)
                    : null,
                icon: const Icon(Icons.first_page),
                iconSize: 20,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                iconSize: 20,
                disabledColor: Colors.grey.shade300,
              ),
              ...List.generate(_totalPages.clamp(0, 5), (index) {
                final pageNumber = index + 1;
                if (_totalPages > 5) {
                  if (pageNumber == 1 || 
                      pageNumber == _totalPages || 
                      (pageNumber >= _currentPage - 1 && pageNumber <= _currentPage + 1)) {
                    return _buildPageButton(pageNumber);
                  } else if (pageNumber == _currentPage - 2 || pageNumber == _currentPage + 2) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('...', style: TextStyle(color: Colors.grey.shade600)),
                    );
                  }
                  return const SizedBox.shrink();
                }
                return _buildPageButton(pageNumber);
              }),
              IconButton(
                onPressed: _currentPage < _totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                iconSize: 20,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                onPressed: _currentPage < _totalPages
                    ? () => setState(() => _currentPage = _totalPages)
                    : null,
                icon: const Icon(Icons.last_page),
                iconSize: 20,
                disabledColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int pageNumber) {
    final isSelected = pageNumber == _currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: () => setState(() => _currentPage = pageNumber),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade800,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolCard(ProtocolModel protocol) {
    return Container(
      key: ValueKey('protocol_list_card_${protocol.id}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('protocol_list_card_inkwell_${protocol.id}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProtocolDetailView(protocol: protocol)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com número e status
                Row(
                  children: [
                    // Número do protocolo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(protocol.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        protocol.number,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(protocol.status),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(protocol.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatStatus(protocol.status),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Assunto
                Text(
                  protocol.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Tipo de documento (se existir)
                if (protocol.documentType != null) ...[
                  Row(
                    children: [
                      Icon(Icons.category, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        protocol.documentType!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Data e setor
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(protocol.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    if (protocol.sector != null) ...[
                      Icon(Icons.business, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          protocol.sector!.name,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

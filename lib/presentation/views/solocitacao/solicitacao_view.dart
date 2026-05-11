// presentation/views/solocitacao/solicitacao_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../providers/solicitacao_provider.dart';
import '../../../data/models/solicitacao_model.dart';
import '../../widgets/solicitacoes/solicitacao_card.dart';
import 'solicitacao_detail_screen.dart';
import '../../widgets/common/breadcrumb_widget.dart';
import '../../../core/models/breadcrumb_model.dart';
import '../../providers/breadcrumb_provider.dart';

class SolicitacaoView extends StatefulWidget {
  final String tipo;
  final String slug;

  const SolicitacaoView({super.key, required this.tipo, required this.slug});

  @override
  State<SolicitacaoView> createState() => _SolicitacaoViewState();
}

class _SolicitacaoViewState extends State<SolicitacaoView> {
  final TextEditingController _searchController = TextEditingController();
  List<SolicitacaoModel> _filteredSolicitacoes = [];
  
  // Variáveis de filtro
  DateTime? _dataFiltro;
  DateTime? _dataInicioFiltro;
  DateTime? _dataFimFiltro;
  bool _modoPeriodo = false;
  
  // Cache seguro do provider
  SolicitacaoProvider? _provider;
  bool _isDisposed = false;
  
  // Controle de conectividade
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOffline = false;

  // Método para obter ícone baseado no tipo de solicitação
  IconData _getIconForTipo(String tipo) {
    final tipoLower = tipo.toLowerCase();
    
    // Mapeamento baseado nos ícones usados na home - com termos exatos da API
    if (tipoLower.contains('iluminação') || tipoLower.contains('iluminacao') || tipoLower.contains('luz')) {
      return Icons.lightbulb;
    } else if (tipoLower.contains('pavimentação') || tipoLower.contains('pavimentacao') || tipoLower.contains('via') || tipoLower.contains('rua')) {
      return Icons.construction;
    } else if (tipoLower.contains('limpeza') || tipoLower.contains('lixo') || tipoLower.contains('resíduo') || tipoLower.contains('residuo')) {
      return Icons.cleaning_services;
    } else if (tipoLower.contains('água') || tipoLower.contains('agua') || tipoLower.contains('esgoto') || tipoLower.contains('hidráulico') || tipoLower.contains('hidraulico')) {
      return Icons.water_drop;
    } else if (tipoLower.contains('árvore') || tipoLower.contains('arvore') || tipoLower.contains('jardim') || tipoLower.contains('parque')) {
      return Icons.park;
    } else if (tipoLower.contains('ruído') || tipoLower.contains('ruido') || tipoLower.contains('barulho') || tipoLower.contains('som')) {
      return Icons.volume_up;
    } else if (tipoLower.contains('animal') || tipoLower.contains('cachorro') || tipoLower.contains('gato')) {
      return Icons.pets;
    } else if (tipoLower.contains('transporte') || tipoLower.contains('ônibus') || tipoLower.contains('onibus') || tipoLower.contains('tráfego') || tipoLower.contains('trafego')) {
      return Icons.directions_bus;
    } else if (tipoLower.contains('segurança') || tipoLower.contains('seguranca') || tipoLower.contains('policial') || tipoLower.contains('crime')) {
      return Icons.security;
    } else if (tipoLower.contains('saúde') || tipoLower.contains('saude') || tipoLower.contains('ambulância') || tipoLower.contains('ambulancia') || tipoLower.contains('hospital')) {
      return Icons.local_hospital;
    } else if (tipoLower.contains('educação') || tipoLower.contains('educacao') || tipoLower.contains('escola') || tipoLower.contains('aula')) {
      return Icons.school;
    } else {
      // Ícone padrão para solicitações genéricas
      return Icons.assignment;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;
      
      if (_isOffline && !wasOffline && mounted) {
        // Acabou de ficar offline - mostrar mensagem igual à da tela de favoritos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📱 Não foi possível carregar os dados do serviço. Verifique sua conexão com a internet.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (!_isOffline && wasOffline && mounted) {
        // Voltou online - recarregar dados
        if (_provider != null) {
          _provider!.loadData();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Salvar referência segura do provider apenas uma vez
    if (_provider == null) {
      _provider = Provider.of<SolicitacaoProvider>(context, listen: false);
      
      // Inicializar provider após o build (apenas na primeira vez)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed && _provider != null) {
          _provider!.init(widget.tipo, widget.slug);
          
          // Configurar breadcrumbs para a tela de solicitações
          _setupBreadcrumbs();
          
          // Verificar conectividade inicial
          _checkInitialConnectivity();
        }
      });
    }
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _isOffline = result == ConnectivityResult.none;
      
      if (_isOffline && mounted) {
        // Mostrar mensagem offline igual à da tela de favoritos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Não foi possível carregar os dados do serviço. Verifique sua conexão com a internet.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Ignorar erro na verificação de conectividade
    }
  }

  void _setupBreadcrumbs() {
    final breadcrumbProvider = context.read<BreadcrumbProvider>();
    breadcrumbProvider.setBreadcrumbs([
      const BreadcrumbItem(title: 'Home', route: '/'),
      const BreadcrumbItem(
        title: 'Solicitações',
        route: '/solicitacoes',
      ),
      BreadcrumbItem(
        title: _provider?.title ?? widget.tipo,
        route: null, // Página atual
      ),
    ]);
    breadcrumbProvider.sendBreadcrumbToApi();
  }

  Future<void> _initializeLocale() async {
    try {
      await initializeDateFormatting('pt_BR', null);
    } catch (e) {
      // Ignorar erro de locale, continuar sem formatação
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    _searchController.dispose();
    _provider = null;
    super.dispose();
  }

  void _filterSolicitacoes(String query) {
    if (!mounted || _isDisposed) return;
    
    try {
      final provider = _provider ?? Provider.of<SolicitacaoProvider>(context, listen: false);
      final solicitacoes = provider.solicitacoes;
      
      _filteredSolicitacoes = solicitacoes.where((s) {
        // Filtro por texto
        final matchesText = query.isEmpty || 
            (s.codigo?.toLowerCase().contains(query.toLowerCase()) ?? false);
        
        // Filtro por data
        bool matchesDate = true;
        if (_modoPeriodo) {
          // Modo período
          if (_dataInicioFiltro != null && _dataFimFiltro != null) {
            matchesDate = _isDateInPeriod(
              s.dateTime,
              _dataInicioFiltro!,
              _dataFimFiltro!
            );
          } else {
            matchesDate = true; // Sem período definido, mostra tudo
          }
        } else {
          // Modo data fixa
          if (_dataFiltro != null) {
            matchesDate = _isSameDay(s.dateTime, _dataFiltro!);
          } else {
            matchesDate = true; // Sem data definida, mostra tudo
          }
        }
        
        return matchesText && matchesDate;
      }).toList();
      
      // setState seguro (apenas se necessário)
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    } catch (e) {
      // Ignorar erro de filtro
    }
  }
  
  bool _isSameDay(String? dateTimeStr, DateTime filterDate) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return false;
    
    try {
      final dataSolicitacao = DateTime.parse(dateTimeStr);
      
      // Normalizar data para comparação (ignorar horas)
      final dataSolicitacaoNormalizada = DateTime(
        dataSolicitacao.year, 
        dataSolicitacao.month, 
        dataSolicitacao.day
      );
      
      final filterDateNormalizada = DateTime(
        filterDate.year, 
        filterDate.month, 
        filterDate.day
      );
      
      return dataSolicitacaoNormalizada.isAtSameMomentAs(filterDateNormalizada);
    } catch (e) {
      return false;
    }
  }

  bool _isDateInPeriod(String? dateTimeStr, DateTime dataInicio, DateTime dataFim) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return false;
    
    try {
      final dataSolicitacao = DateTime.parse(dateTimeStr);
      
      // Normalizar todas as datas para meia-noite para comparação justa
      final dataSolicitacaoNormalizada = DateTime(dataSolicitacao.year, dataSolicitacao.month, dataSolicitacao.day);
      final dataInicioNormalizada = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
      final dataFimNormalizada = DateTime(dataFim.year, dataFim.month, dataFim.day);
      
      // Lógica simples e clara: data deve estar entre início e fim (inclusive)
      return (dataSolicitacaoNormalizada.isAtSameMomentAs(dataInicioNormalizada) || 
              dataSolicitacaoNormalizada.isAfter(dataInicioNormalizada)) &&
             (dataSolicitacaoNormalizada.isAtSameMomentAs(dataFimNormalizada) || 
              dataSolicitacaoNormalizada.isBefore(dataFimNormalizada));
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obter provider atualizado
    final provider = Provider.of<SolicitacaoProvider>(context);
    
    // Salvar referência se necessário
    _provider ??= provider;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, provider),
      body: _buildBodyContent(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mounted && !_isDisposed) {
            context.push(
              '/solicitacoes/nova',
              extra: {
                'tipo': provider.title, 
                'slug': provider.slug,
              },
            );
          }
        },
        foregroundColor: AppColors.primaryBlue,
        backgroundColor: AppColors.white,
        child: const Icon(Icons.post_add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    SolicitacaoProvider provider,
  ) {
    return AppBar(
      title: Text(provider.title.isNotEmpty ? provider.title : 'Solicitações'),
      actions: [
        // Ícone do tipo de solicitação
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(
            _getIconForTipo(provider.title),
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
      foregroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        tooltip: 'Voltar',
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onPressed: () => context.pop(),
      ),
      titleSpacing: -16,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.lightBlue,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(SolicitacaoProvider provider) {
    if (!mounted || _isDisposed) {
      return Container();
    }
    
    // Verificar se está carregando
    if (provider.isLoad) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    // Verificar se não há solicitações
    if (provider.solicitacoes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Nenhuma solicitação encontrada.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    // Sempre usar a lista filtrada quando há filtros ativos, mesmo que vazia
    final hasActiveFilters = _searchController.text.isNotEmpty || 
                           _dataFiltro != null || 
                           (_dataInicioFiltro != null && _dataFimFiltro != null);
    
    final displayList = hasActiveFilters 
        ? _filteredSolicitacoes  // Usa lista filtrada mesmo que vazia
        : provider.solicitacoes; // Usa lista completa apenas sem filtros
    final isEmpty = displayList.isEmpty;
    final hasSearch = _searchController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CONTAINER ÚNICO COM BREADCRUMB E TÍTULO
        Container(
          color: AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BREADCRUMB DENTRO DO CONTAINER
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 16, 8),
                child: BreadcrumbWidget(),
              ),
              // TÍTULO ABAIXO DO BREADCRUMB
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  'Solicitar ${provider.title}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildSearchField(),
        Expanded(
          child: isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      hasSearch 
                          ? 'Nenhuma solicitação encontrada para "${_searchController.text}".'
                          : 'Nenhuma solicitação encontrada.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 6,
                  radius: const Radius.circular(6),
                  child: ListView.separated(
                    key: const PageStorageKey('solicitacao_list'),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
                    itemCount: displayList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      return SolicitacaoCard(
                        item: item,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SolicitacaoDetailScreen(solicitacao: item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    if (!mounted || _isDisposed) {
      return Container();
    }
    
    return Container(
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
            onChanged: _filterSolicitacoes,
            decoration: InputDecoration(
              hintText: 'Buscar por código da solicitação...',
              prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filtro de data
                  GestureDetector(
                    onTap: () => _showDatePickerOptions(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.calendar_today,
                        color: (_dataFiltro != null || _dataInicioFiltro != null || _dataFimFiltro != null) 
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
                        if (mounted && !_isDisposed) {
                          _searchController.clear();
                          _filterSolicitacoes('');
                        }
                      },
                    )
                  else
                    SizedBox.shrink(),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
          
          // Filtros de data
          if (_dataFiltro != null || _dataInicioFiltro != null || _dataFimFiltro != null)
            _buildDateFilterWidget(),
        ],
      ),
    );
  }

  Widget _buildDateFilterWidget() {
    if (!mounted || _isDisposed) {
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
          if (_dataFiltro != null || _dataInicioFiltro != null || _dataFimFiltro != null)
            GestureDetector(
              onTap: () {
                if (!mounted || _isDisposed) return;
                setState(() {
                  _dataFiltro = null;
                  _dataInicioFiltro = null;
                  _dataFimFiltro = null;
                });
                _filterSolicitacoes(_searchController.text);
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
      if (_modoPeriodo) {
        if (_dataInicioFiltro != null && _dataFimFiltro != null) {
          return 'Período: ${_formatDate(_dataInicioFiltro!)} até ${_formatDate(_dataFimFiltro!)}';
        } else if (_dataInicioFiltro != null) {
          return 'A partir de: ${_formatDate(_dataInicioFiltro!)}';
        }
        return 'Selecione um período';
      } else {
        if (_dataFiltro != null) {
          return 'Data: ${_formatDate(_dataFiltro!)}';
        }
        return 'Selecione uma data';
      }
    } catch (e) {
      return 'Selecione uma data';
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDatePickerOptions(BuildContext context) {
    if (!mounted || _isDisposed) return;
    
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
              'Filtrar por Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Tipo de filtro:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (mounted && !_isDisposed) {
                        Navigator.pop(context);
                        _selectSingleDate(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryBlue),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.primaryBlue, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            'Data Fixa',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Text(
                            'Selecionar uma data específica',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (mounted && !_isDisposed) {
                        Navigator.pop(context);
                        _showPeriodSelector(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightBlue),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.date_range, color: AppColors.lightBlue, size: 30),
                          const SizedBox(height: 8),
                          Text(
                            'Período',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightBlue,
                            ),
                          ),
                          Text(
                            'Selecionar intervalo de datas',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  if (mounted && !_isDisposed) {
                    Navigator.pop(context);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodSelector(BuildContext context) {
    if (!mounted || _isDisposed) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar Período',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20),
            
            // Data de início
            Text(
              'Data de Início',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectStartDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    Text(
                      _dataInicioFiltro != null 
                          ? _formatDate(_dataInicioFiltro!)
                          : 'Selecione a data de início',
                      style: TextStyle(
                        fontSize: 16,
                        color: _dataInicioFiltro != null ? AppColors.darkText : Colors.grey,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Data de fim
            Text(
              'Data de Fim',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectEndDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    Text(
                      _dataFimFiltro != null 
                          ? _formatDate(_dataFimFiltro!)
                          : 'Selecione a data de fim',
                      style: TextStyle(
                        fontSize: 16,
                        color: _dataFimFiltro != null ? AppColors.darkText : Colors.grey,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (mounted && !_isDisposed) {
                        Navigator.pop(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (mounted && !_isDisposed && 
                          _dataInicioFiltro != null && 
                          _dataFimFiltro != null) {
                        setState(() {
                          _modoPeriodo = true;
                          _dataFiltro = null;
                        });
                        _filterSolicitacoes(_searchController.text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Aplicar Período',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Resumo do período
            if (_dataInicioFiltro != null && _dataFimFiltro != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Período selecionado: ${_formatDate(_dataInicioFiltro!)} até ${_formatDate(_dataFimFiltro!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    if (!mounted || _isDisposed) return;
    
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _dataInicioFiltro ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('pt', 'BR'),
        builder: _buildDatePickerTheme,
        cancelText: 'Cancelar',
        confirmText: 'Confirmar',
        helpText: 'Selecione a data de início',
      );
      
      if (picked != null && mounted && !_isDisposed) {
        setState(() {
          _dataInicioFiltro = picked;
          // Se a data fim for anterior à nova data início, limpar
          if (_dataFimFiltro != null && _dataFimFiltro!.isBefore(picked)) {
            _dataFimFiltro = null;
          }
        });
      }
    } catch (e) {
      // Ignorar erro
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (!mounted || _isDisposed) return;
    
    if (_dataInicioFiltro == null) {
      // Mostrar mensagem para selecionar data início primeiro
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, selecione a data de início primeiro'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _dataFimFiltro ?? (_dataInicioFiltro?.add(const Duration(days: 7)) ?? DateTime.now()),
        firstDate: _dataInicioFiltro ?? DateTime.now(), // Não pode ser antes da data início
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('pt', 'BR'),
        builder: _buildDatePickerTheme,
        cancelText: 'Cancelar',
        confirmText: 'Confirmar',
        helpText: 'Selecione a data de fim',
      );
      
      if (picked != null && mounted && !_isDisposed) {
        setState(() {
          _dataFimFiltro = picked;
        });
      }
    } catch (e) {
      // Ignorar erro
    }
  }

  Future<void> _selectSingleDate(BuildContext context) async {
    if (!mounted || _isDisposed) return;
    
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _dataFiltro ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        locale: const Locale('pt', 'BR'),
        builder: _buildDatePickerTheme,
        cancelText: 'Cancelar',
        confirmText: 'Confirmar',
        helpText: 'Selecione uma data',
      );
      
      if (picked != null && mounted && !_isDisposed) {
        setState(() {
          _modoPeriodo = false;
          _dataFiltro = picked;
          _dataInicioFiltro = null;
          _dataFimFiltro = null;
        });
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            _filterSolicitacoes(_searchController.text);
          }
        });
      }
    } catch (e) {
      // Ignorar erro do date picker
    }
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          onSurface: AppColors.darkText,
          surface: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      child: child ?? Container(),
    );
  }
}

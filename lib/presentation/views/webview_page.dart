import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/data/models/favorite_model.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:integra_app/presentation/views/categorias_e_servicos/service_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/tenant_model.dart' as models show Tenant;
import '../../services/category_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _showTutorial = false;
  bool _isLoading = false;
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
    
    // Mostra loading ao iniciar
    setState(() {
      _isLoading = true;
    });
    
    // Carrega favoritos e dados completos dos serviços
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoritesAndServices();
    });
  }

  /// Carrega favoritos e depois busca dados completos dos serviços
  Future<void> _loadFavoritesAndServices() async {
    final favoriteViewModel = context.read<FavoriteViewModel>();
    
    // Primeiro carrega os favoritos básicos
    await favoriteViewModel.loadFavorites();
    
    // Depois busca dados completos dos serviços (se tiver idService)
    await favoriteViewModel.loadFavoritesServicesData();
    
    // Esconde o loading
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Busca tenant atual
  Future<models.Tenant?> _getCurrentTenant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tenantJson = prefs.getString('current_tenant');
      if (tenantJson != null) {
        return models.Tenant.fromJson(jsonDecode(tenantJson));
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar tenant: $e');
    }
    return null;
  }

  // Busca token de autenticação
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('❌ Erro ao buscar token: $e');
    }
    return null;
  }

  // Busca serviço real nas categorias usando CategoryService
  Future<Map<String, dynamic>?> _findServiceInCategories(String slug) async {
    try {
      debugPrint('🔍 Buscando serviço real com slug: $slug');
      
      final tenant = await _getCurrentTenant();
      final token = await _getAuthToken();
      
      if (tenant != null && token != null) {
        final categories = await _categoryService.getCategories(tenant, token);
        
        for (final category in categories) {
          for (final service in category.services) {
            if (service.slug == slug) {
              debugPrint('✅ Serviço encontrado: ${service.title}');
              return {
                'service': service.toJson(),
                'category': category.toJson(),
              }; // ✅ Dados 100% reais!
            }
          }
        }
      }
      
      debugPrint('⚠️ Serviço não encontrado com slug: $slug');
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao buscar serviço: $e');
      return null;
    }
  }

  Future<void> _checkTutorialStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenTutorial = prefs.getBool('has_seen_favorites_tutorial') ?? false;
      
      // Não mostra tutorial automaticamente, apenas verifica status
      if (mounted) {
        setState(() {
          _showTutorial = false; // Sempre inicia como false
        });
      }
    } catch (e) {
      debugPrint('Erro ao verificar status do tutorial: $e');
      // Se falhar, não mostra o tutorial automaticamente
      if (mounted) {
        setState(() {
          _showTutorial = false;
        });
      }
    }
  }

  void _hideTutorial() async {
    if (mounted) {
      setState(() {
        _showTutorial = false;
      });
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_favorites_tutorial', true);
    } catch (e) {
      debugPrint('Erro ao salvar status do tutorial: $e');
      // Continua mesmo sem salvar
    }
  }

  void _showTutorialManually() {
    if (mounted) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.home);
      },
      child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 🔥 Adicione isto
      appBar: AppBar(
         automaticallyImplyLeading:false,
        title: const Text('Meus Favoritos'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading || favoriteViewModel.isLoading
          ? const AppLoader()
          : favoriteViewModel.favorites.isEmpty && _showTutorial
          ? _buildTutorialScreen()
          : favoriteViewModel.favorites.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favoriteViewModel.favorites.length,
              itemBuilder: (context, index) {
                final favorite = favoriteViewModel.favorites[index];
                return _buildFavoriteItem(context, favorite, favoriteViewModel);
              },
            ),
      ),
    );
  }

  Widget _buildTutorialScreen() {
    return _FavoritesTutorialWidget(
      onTutorialComplete: _hideTutorial,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Você ainda não tem favoritos.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 5),
          Text(
            'Toque no coração para adicionar um serviço.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _showTutorialManually,
            icon: const Icon(Icons.help_outline, size: 20),
            label: const Text(
              'Ver tutorial',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.primaryBlue, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    Favorite favorite,
    FavoriteViewModel viewModel,
  ) {
    // ✅ DEBUG: Mostra informações para debug
    debugPrint('[FavoritesScreen] Nome: ${favorite.serviceName}');
    debugPrint('[FavoritesScreen] IconCodePoint: ${favorite.iconCodePoint}');
    debugPrint('[FavoritesScreen] Route: ${favorite.route}');
    
    // ✅ SOLUÇÃO: Detecta tipo de categoria e usa estratégia adequada
    IconData iconData;
    
    // ✅ ESTRATÉGIA: Mapeamento de ícones por categoria
    switch (favorite.serviceName.toLowerCase()) {
      case 'mulher':
        iconData = Icons.person;
        break;
      case 'educação':
        iconData = Icons.school;
        break;
      case 'veículos e condutores':
        iconData = Icons.drive_eta;
        break;
      case 'trabalho e emprego':
        iconData = Icons.work;
        break;
      case 'agropecuária':
        iconData = Icons.agriculture;
        break;
      case 'poda de árvore':
      case 'poda de arvore':
        iconData = FontAwesomeIcons.tree;
        break;
      case 'reparo de iluminação':
      case 'reparo de iluminacao':
        iconData = Icons.lightbulb; // Ícone de lâmpada
        break;
        case 'iluminacao publica':
        case 'iluminação pública':
        iconData = Icons.lightbulb; // Ícone de lâmpada
        break;
      case 'pavimentação':
        iconData = Icons.construction; // Ícone de construção
        break;
      case 'limpeza pública':
      case 'limpeza publica':
        iconData = Icons.cleaning_services; // Ícone de serviços de limpeza
        break;
      case 'carteira de identidade':
        iconData = FontAwesomeIcons.fingerprint;
        break;
      case 'consulta cnh':
        iconData = FontAwesomeIcons.carSide;
        break;
      default:
        // ✅ ESTRATÉGIA: Usa apenas ícones constantes (para tree-shake funcionar)
        iconData = Icons.star; // ✅ Fallback garantido (constante)
        debugPrint('[FavoritesScreen] Usando ícone constante (fallback para tree-shake)');
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: AppColors.lightBackground,
      child: ListTile(
        leading: Icon(iconData, color: AppColors.primaryBlue, size: 30),
        title: Text(
          favorite.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Serviço disponível'),
        trailing: IconButton(
          
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => viewModel.toggleFavorite(favorite),
        ),
        onTap: () async {
                        // Navegar para o serviço com dados completos se disponíveis
                        if (favorite.idService != null) {
                          final servicesCache = context.read<FavoriteViewModel>().servicesCache;
                          final fullService = servicesCache[favorite.idService];
                          
                          if (fullService != null) {
                            // Navega com dados completos do serviço
                            context.push('/service-detail', extra: {
                              'service': fullService,
                              'category': fullService.category,
                            });
                            debugPrint('🧭 Navegando com dados completos do serviço: ${fullService.title}');
                            return;
                          }
                          
                          // Fallback: busca por CategoryService se não estiver no cache
                          if (favorite.slug != null) {
                            try {
                              final serviceData = await _findServiceInCategories(favorite.slug!);
                              if (serviceData != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceDetailScreen(
                                      service: serviceData['service'],
                                      category: serviceData['category'] ?? {
                                        'name': favorite.serviceName,
                                        'icon': favorite.iconCodePoint,
                                      },
                                    ),
                                  ),
                                );
                                debugPrint('🧭 Navegando com dados do CategoryService: ${favorite.serviceName}');
                                return;
                              }
                            } catch (e) {
                              debugPrint('❌ Erro ao buscar serviço com CategoryService: $e');
                            }
                          }
                        }
                        
                        // Navegação original específica para cada serviço
                        if (favorite.serviceName == "Iluminação Pública") {
                          context.push('/solicitacao_view', extra: {
                            'title': favorite.title ?? 'Iluminação Pública', 
                            'slug': favorite.slug ?? 'Iluminação Pública'
                          });
                        } else if (favorite.serviceName == "Pavimentação") {
                          context.push('/solicitacao_view', extra: {
                            'title': favorite.title ?? 'Pavimentação', 
                            'slug': favorite.slug ?? 'pavimentacao'
                          });
                        } else if (favorite.serviceName == "Limpeza Pública") {
                          context.push('/solicitacao_view', extra: {
                            'title': favorite.title ?? 'Limpeza Pública', 
                            'slug': favorite.slug ?? 'limpeza-publica'
                          });
                        } else if (favorite.serviceName == "Poda de Árvore") {
                          context.push('/solicitacao_view', extra: {
                            'title': favorite.title ?? 'Poda de Árvore', 
                            'slug': favorite.slug ?? 'poda-de-arvore'
                          });
                        } else if (favorite.route.startsWith('/')) {
                          try {
                            context.push(favorite.route);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Rota não encontrada: ${favorite.route}'),
                                backgroundColor: AppColors.orange,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Navegação não disponível para esta categoria'),
                              backgroundColor: AppColors.orange,
                            ),
                          );
                        }
                      },
      ),
    );
  }
}

// Widget de tutorial integrado diretamente na tela
class _FavoritesTutorialWidget extends StatefulWidget {
  final VoidCallback onTutorialComplete;

  const _FavoritesTutorialWidget({
    required this.onTutorialComplete,
  });

  @override
  State<_FavoritesTutorialWidget> createState() => _FavoritesTutorialWidgetState();
}

class _FavoritesTutorialWidgetState extends State<_FavoritesTutorialWidget> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Favoritando Serviço',
      instruction: 'Toque no serviço que deseja adicionar na sua lista de favoritos e clique no ícone de coração.',
      imagePath: 'assets/images/tutorial/favorite_service.png',
    ),
    TutorialStep(
      title: 'Desfavoritando Serviço',
      instruction: 'Toque no serviço que deseja remover da sua lista de favoritos e clique no ícone de coração.',
      imagePath: 'assets/images/tutorial/unfavorite_service.png',
    ),
    TutorialStep(
      title: 'Por que sua nota tem valor',
      instruction: 'Favoritar serviços ajuda o app a recomendar conteúdos relevantes para você, facilita encontrar seus serviços preferidos e personaliza sua experiência no aplicativo.',
      imagePath: 'assets/images/tutorial/favorite_benefits.png',
    ),
    TutorialStep(
      title: 'Lista de Favoritos',
      instruction: 'Para ter acesso à sua lista de serviços, acesse o menu de "Favoritos" na tela principal.',
      imagePath: 'assets/images/tutorial/favorites_menu.png',
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishTutorial();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTutorial() {
    _finishTutorial();
  }

  void _finishTutorial() {
    widget.onTutorialComplete();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStep];
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header com indicador de progresso
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Indicadores de progresso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentStep == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentStep == index
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Título principal
                  Text(
                    currentStep.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Instrução
                  Text(
                    currentStep.instruction,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Espaço para a imagem ilustrativa
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildIllustration(currentStep.imagePath),
              ),
            ),
            
            // Botões de navegação
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Botão principal
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        isLastStep ? 'Finalizar' : 'Próxima Etapa',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Botões secundários
                  Row(
                    children: [
                      // Botão Voltar (não aparece na primeira etapa)
                      if (!isFirstStep)
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                side: BorderSide(color: AppColors.primaryBlue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Voltar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      // Espaçamento
                      if (!isFirstStep) const SizedBox(width: 12),
                      
                      // Botão Pular
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: TextButton(
                            onPressed: _skipTutorial,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Pular',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(String imagePath) {
    // Tenta carregar a imagem, se não existir mostra um placeholder
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIllustration();
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderIllustration() {
    // Placeholder visual quando a imagem não existe
    switch (_currentStep) {
      case 0: // Favoritando
        return _buildFavoriteIllustration(true);
      case 1: // Desfavoritando
        return _buildFavoriteIllustration(false);
      case 2: // Benefícios
        return _buildBenefitsIllustration();
      case 3: // Menu
        return _buildMenuIllustration();
      default:
        return _buildGenericIllustration();
    }
  }

  Widget _buildFavoriteIllustration(bool isFavoriting) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simulação de card de serviço
            Container(
              width: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Serviço Exemplo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Animação simples do coração
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isFavoriting ? Icons.favorite_border : Icons.favorite,
                      color: isFavoriting ? Colors.grey : Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Indicador visual de toque
            Icon(
              Icons.touch_app,
              color: AppColors.primaryBlue,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              isFavoriting ? 'Toque para favoritar' : 'Toque para remover',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsIllustration() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 60,
            ),
            const SizedBox(height: 20),
            const Text(
              'Benefícios dos Favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem('⚡', 'Acesso rápido'),
            _buildBenefitItem('🎯', 'Conteúdo personalizado'),
            _buildBenefitItem('💡', 'Recomendações inteligentes'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIllustration() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simulação de menu inferior
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem(Icons.home, 'Início', false),
                  _buildMenuItem(Icons.favorite, 'Favoritos', true),
                  _buildMenuItem(Icons.person, 'Perfil', false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.arrow_upward,
              color: AppColors.primaryBlue,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              'Acesse pelo menu principal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primaryBlue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.primaryBlue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericIllustration() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info,
              color: AppColors.primaryBlue,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Ilustração não disponível',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modelo para representar cada etapa do tutorial
class TutorialStep {
  final String title;
  final String instruction;
  final String imagePath;

  TutorialStep({
    required this.title,
    required this.instruction,
    required this.imagePath,
  });
}

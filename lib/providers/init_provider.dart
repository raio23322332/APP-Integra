import 'package:http/http.dart' as http;
import 'package:integra_app/domain/services/login_authentication_service.dart';
import 'package:integra_app/providers/municipio_provider.dart';
import 'package:integra_app/providers/solicitacao_provider.dart';
import 'package:integra_app/services/auth/auth_service.dart' as auth_service;
import 'package:integra_app/core/contracts/category_service_contract.dart';
import 'package:integra_app/core/contracts/domain_service_contract.dart';
import 'package:integra_app/core/contracts/domain_http_contract.dart';
import 'package:integra_app/core/contracts/storage_service_contract.dart';
import 'package:integra_app/data/datasources/local/auth_local_datasource.dart';
import 'package:integra_app/data/datasources/local/auth_local_datasource_impl.dart';
import 'package:integra_app/domain/repositories/auth_repository.dart';
import 'package:integra_app/domain/repositories/auth_repository_impl.dart';
import 'package:integra_app/data/datasources/auth_remote_datasource.dart';
import 'package:integra_app/data/datasources/auth_remote_datasource_impl.dart';
import 'package:integra_app/domain/usecases/auth/register_usecase.dart';
import 'package:integra_app/domain/usecases/auth/login_usecase.dart';
import 'package:integra_app/domain/contracts/auth_service_contract.dart';
import 'package:integra_app/domain/contracts/logout_service.dart';
import 'package:integra_app/domain/services/form_validation_service.dart';
import 'package:integra_app/services/auth_service_adapter.dart';
import 'package:integra_app/services/logout_service_impl.dart';
import 'package:integra_app/data/dao/tenant_config_dao.dart';
import 'package:integra_app/data/dao/category_dao.dart';
import 'package:integra_app/domain/repositories/tenant_repository_impl.dart';
import 'package:integra_app/domain/usecases/tenant/get_tenants_usecase.dart';
import 'package:integra_app/domain/usecases/tenant/save_selected_tenant_usecase.dart';
import 'package:integra_app/services/storage/domain_storage_service_impl.dart';
import 'package:provider/provider.dart';
import 'package:integra_app/services/local/hive_local_storage_service.dart';
import 'package:integra_app/services/storage/local_storage_service.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/presentation/viewmodels/categorias_e_servicos/categories_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/cin_agendamento_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/educacao_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/profile/edit_profile_viewmodel.dart';
import 'package:integra_app/services/poda_de_arvore/image_service.dart';
import 'package:integra_app/presentation/viewmodels/poda_arvore/poda_de_arvore_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/tenant_select_viewmodel.dart';
import 'package:provider/single_child_widget.dart';
import 'package:integra_app/presentation/viewmodels/favorite_viewmodel.dart';
import '../services/category_service.dart';
import '../services/domain/domain_service.dart';
import '../services/http/domain_http.dart';
import '../services/search_service.dart';
import '../presentation/viewmodels/search_viewmodel.dart';
import '../presentation/viewmodels/auth/auth_viewmodel.dart';
import '../presentation/viewmodels/auth/login_viewmodel.dart';
import '../presentation/viewmodels/repair_request_viewmodel.dart';
import '../presentation/viewmodels/user_viewmodel.dart';
import '../presentation/viewmodels/emprego_viewmodel.dart';
import '../presentation/viewmodels/protocol/protocol_list_viewmodel.dart';
import '../presentation/viewmodels/profile/profile_viewmodel.dart';
import '../services/navigation_service.dart';
import '../presentation/providers/breadcrumb_provider.dart';
import '../presentation/providers/recent_search_provider.dart';

class InitProvider {
  /// Cria providers essenciais que são necessários imediatamente no startup
  static List<SingleChildWidget> createEssentialProviders({
    required AuthViewModel authViewModel,
    required DomainStorage domainStorage,
    required auth_service.AuthService authService,
  }) {
    return [
      // Providers essenciais para startup
      ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
      Provider<DomainStorage>.value(value: domainStorage),
      Provider<auth_service.AuthService>.value(value: authService),

      // DAOs essenciais
      Provider<TenantConfigDao>(create: (_) => TenantConfigDao()),
      Provider<CategoryDao>(create: (_) => CategoryDao()),

      // Navigation Service (essencial para MVVM)
      Provider<NavigationService>(create: (_) => NavigationService.instance),

      // Breadcrumb Provider (essencial para navegação)
      ChangeNotifierProvider<BreadcrumbProvider>(
        create: (_) => BreadcrumbProvider(),
      ),

      // Recent Search Provider (essencial para busca)
      ChangeNotifierProvider<RecentSearchProvider>(
        create: (_) => RecentSearchProvider(),
      ),

      // HTTP Services essenciais
      Provider<DomainHttpContract>(create: (_) => DomainHttp()),

      Provider<DomainService>(
        create: (context) => DomainService(
          tenantConfigDao: context.read<TenantConfigDao>(),
          domainHttp: context.read<DomainHttpContract>(),
        ),
      ),

      // Use Cases essenciais para navegação inicial
      Provider<GetTenantsUseCase>(
        create: (context) {
          final tenantRepository = TenantRepositoryImpl(
            domainService: context.read<DomainService>(),
            tenantConfigDao: context.read<TenantConfigDao>(),
            categoryDao: CategoryDao(), // Criar diretamente para evitar problemas de ordem
          );
          return GetTenantsUseCase(tenantRepository);
        },
      ),
      Provider<SaveSelectedTenantUseCase>(
        create: (context) {
          final tenantRepository = TenantRepositoryImpl(
            domainService: context.read<DomainService>(),
            tenantConfigDao: context.read<TenantConfigDao>(),
            categoryDao: CategoryDao(), // Criar diretamente para evitar problemas de ordem
          );
          return SaveSelectedTenantUseCase(tenantRepository);
        },
      ),

      // Service para logout (melhora isolamento)
      Provider<LogoutService>(
        create: (context) => LogoutServiceImpl(context.read<AuthViewModel>()),
      ),

      // ViewModels essenciais para primeira tela
      ChangeNotifierProvider(
        create: (context) => TenantSelectViewModel(
          getTenantsUseCase: context.read<GetTenantsUseCase>(),
          saveSelectedTenantUseCase: context.read<SaveSelectedTenantUseCase>(),
          logoutService: context.read<LogoutService>(),
          tenantConfigDao: context.read<TenantConfigDao>(),
        ),
      ),

      // Adapter para AuthServiceContract - melhora isolamento
      Provider<AuthServiceContract>(
        create: (context) => AuthServiceAdapter(context.read<AuthViewModel>()),
      ),

      // ✅ MVVM: Services essenciais para Login
      Provider<FormValidationService>(
        create: (context) => FormValidationService(),
      ),
      Provider<LoginUseCase>(
        create: (context) => LoginUseCase(
          LoginAuthenticationService(context.read<AuthServiceContract>()),
        ),
      ),

      // LoginViewModel também é essencial pois pode ser acessado diretamente via rota
      ChangeNotifierProvider(
        create: (context) => LoginViewModel(
          loginUseCase: context.read<LoginUseCase>(),
          validationService: context.read<FormValidationService>(),
          authViewModel: context.read<AuthViewModel>(),
        ),
      ),

      // SearchViewModel é essencial pois é usado pelo HomeViewModel
      ChangeNotifierProvider<SearchViewModel>(
        create: (context) => SearchViewModel(
          SearchService(
            categoryService: CategoryService(),
            domainService: context.read<DomainService>(),
            storage: DomainStorageServiceImpl(context.read<DomainStorage>()),
          ),
        ),
      ),

      // FavoriteViewModel é essencial pois é usado pelo HomeViewModel
      ChangeNotifierProvider<FavoriteViewModel>(
        create: (context) => FavoriteViewModel(
          domainStorage: context.read<DomainStorage>(),
        ),
      ),

      // HomeViewModel é essencial pois é a tela principal após login
      ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(
          domainStorage: context.read<DomainStorage>(),
          domainService: context.read<DomainService>(),
          categoryService: CategoryService(),
          authViewModel: context.read<AuthViewModel>(),
          searchViewModel: context.read<SearchViewModel>(),
          navigationService: context.read<NavigationService>(),
        ),
      ),

      // EducacaoViewModel é essencial pois pode ser acessado diretamente via rota
      ChangeNotifierProvider<EducacaoViewModel>(
        create: (_) => EducacaoViewModel(),
      ),

      // ProtocolListViewModel é essencial pois pode ser acessado diretamente via rota
      ChangeNotifierProvider<ProtocolListViewModel>(
        create: (context) => ProtocolListViewModel(
          authViewModel: context.read<AuthViewModel>(),
          navigationService: context.read<NavigationService>(),
        ),
      ),

      // EmpregoViewModel é essencial pois pode ser acessado diretamente via rota
      ChangeNotifierProvider<EmpregoViewModel>(
        create: (_) => EmpregoViewModel(),
      ),

      // PodaDeArvoreViewModel é essencial pois pode ser acessado diretamente via rota
      ChangeNotifierProvider<PodaDeArvoreViewModel>(
        create: (context) => PodaDeArvoreViewModel(
          context.read<AuthViewModel>(),
          ImageService(),
        ),
      ),

      // RepairRequestViewModel é essencial pois pode ser acessado diretamente via rota
      ChangeNotifierProxyProvider<AuthViewModel, RepairRequestViewModel>(
        create: (context) =>
            RepairRequestViewModel(context.read<AuthViewModel>()),
        update: (context, auth, previous) => RepairRequestViewModel(auth),
      ),

      // EditProfileViewModel é essencial pois pode ser acessado diretamente via rota
      ChangeNotifierProvider<EditProfileViewModel>(
        create: (context) => EditProfileViewModel(authViewModel: context.read<AuthViewModel>()),
      ),

      // ProfileViewModel global para evitar duplicatas
      ChangeNotifierProvider<ProfileViewModel>(
        create: (context) => ProfileViewModel(
          authViewModel: context.read<AuthViewModel>(),
          navigationService: context.read<NavigationService>(),
        ),
      ),

      ChangeNotifierProvider<SolicitacaoProvider>(
        create: (_) => SolicitacaoProvider(),
      ),

      // Em createLazyProviders() ou createEssentialProviders()
      ChangeNotifierProvider<MunicipioProvider>(
        create: (context) => MunicipioProvider(
          domainStorage: context.read<DomainStorage>(),
          domainService: context.read<DomainService>(),
          saveSelectedTenantUseCase: context.read<SaveSelectedTenantUseCase>(),
          tenantConfigDao: context.read<TenantConfigDao>(),
        ),
      ),
    ];
  }

  /// Cria providers que podem ser carregados sob demanda
  static List<SingleChildWidget> createLazyProviders() {
    return [
      // HTTP Client (lazy)
      Provider<http.Client>(create: (_) => http.Client()),

      // Auth related (lazy)
      Provider<AuthLocalDataSource>(
        create: (context) =>
            AuthLocalDataSourceImpl(context.read<DomainStorage>()),
      ),
      Provider<AuthRemoteDataSource>(
        create: (context) =>
            AuthRemoteDataSourceImpl(client: context.read<http.Client>()),
      ),
      Provider<AuthRepository>(
        create: (context) => AuthRepositoryImpl(
          remoteDataSource: context.read<AuthRemoteDataSource>(),
          localDataSource: context.read<AuthLocalDataSource>(),
        ),
      ),

      // Use Cases (lazy)
      Provider<RegisterUseCase>(
        create: (context) => RegisterUseCase(context.read<AuthRepository>()),
      ),

      // Services (lazy)
      Provider<LocalStorageService>(create: (_) => HiveLocalStorageService()),
      Provider<DomainHttpContract>(create: (_) => DomainHttp()),
      Provider<DomainServiceContract>(
        create: (context) => DomainService(
          tenantConfigDao: TenantConfigDao(),
          domainHttp: context.read<DomainHttpContract>(),
        ),
      ),
      Provider<CategoryServiceContract>(create: (_) => CategoryService()),
      Provider<CategoryService>(create: (_) => CategoryService()),
      Provider<StorageServiceContract>(
        create: (context) =>
            DomainStorageServiceImpl(context.read<DomainStorage>()),
      ),

      // User management (lazy)
      ChangeNotifierProxyProvider<AuthViewModel, UserViewModel>(
        create: (context) => UserViewModel(context.read<AuthViewModel>()),
        update: (context, auth, previous) => UserViewModel(auth),
      ),

      // Feature-specific ViewModels (lazy loaded)
      Provider<ImageService>(create: (_) => ImageService()),
      ChangeNotifierProvider(create: (_) => CinAgendamentoViewModel()),
      ChangeNotifierProvider(
        create: (context) => CategoriesViewModel(
          service: context.read<CategoryService>(),
          navigationService: context.read<NavigationService>(),
        ),
      ),
    ];
  }

  /// Método legado - cria todos os providers (para compatibilidade)
  /// Use createEssentialProviders + createLazyProviders para melhor performance
  @deprecated
  static List<SingleChildWidget> createProviders({
    required AuthViewModel authViewModel,
    required DomainStorage domainStorage,
    required auth_service.AuthService authService,
  }) {
    return [
      ...createEssentialProviders(
        authViewModel: authViewModel,
        domainStorage: domainStorage,
        authService: authService,
      ),
      ...createLazyProviders(),
    ];
  }
}

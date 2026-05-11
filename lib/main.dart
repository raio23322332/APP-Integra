import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/config/flavor_config.dart';
import 'core/helpers/console_log.dart';
import 'providers/init_provider.dart';
import 'presentation/routes/app_router.dart';
import 'core/theme/app_colors.dart';
import 'presentation/viewmodels/auth/auth_viewmodel.dart';
import 'services/storage/domain_storage.dart';
import 'services/storage/domain_storage_service_impl.dart';
import 'services/auth/auth_service.dart';
import 'services/auth/token_validator.dart';
import 'services/auth/credentials_handler.dart';
import 'services/auth/user_data_manager.dart';
import 'services/auth/offline_auth_handler.dart';
import 'services/navigation_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  ConsoleLog.debug('🚀 Iniciando aplicação...');
  WidgetsFlutterBinding.ensureInitialized();
  ConsoleLog.debug('✅ Widgets Flutter inicializados');
  await initializeDateFormatting('pt_BR', null);
  ConsoleLog.debug('✅ Locale pt_BR inicializado');
  await Hive.initFlutter();
  ConsoleLog.debug('✅ Hive inicializado');
  await dotenv.load(fileName: FlavorConfig.envFile);
  ConsoleLog.debug('✅ Arquivo ${FlavorConfig.envFile} carregado (flavor=${FlavorConfig.flavor})');
  final domainStorage = DomainStorage();
  await domainStorage.init();
  ConsoleLog.debug('✅ DomainStorage inicializado');
  final storageService = DomainStorageServiceImpl(domainStorage);
  final userDataManager = UserDataManager(domainStorage);
  final credentialsHandler = CredentialsHandler(domainStorage, userDataManager);
  final tokenValidator = TokenValidator(domainStorage);
  final offlineAuthHandler = OfflineAuthHandler(domainStorage);
  final authService = AuthService(
    tokenValidator: tokenValidator,
    credentialsHandler: credentialsHandler,
    offlineAuthHandler: offlineAuthHandler,
  );
  ConsoleLog.debug('✅ AuthService criado com dependências');
  final authViewModel = AuthViewModel(storageService, authService);
  ConsoleLog.debug('✅ AuthViewModel criado');
  ConsoleLog.debug('🔄 Carregando usuário atual...');
  await authViewModel.loadCurrentUser();
  ConsoleLog.debug(
    '✅ Usuário carregado: ${authViewModel.currentUser?.email ?? 'nenhum'}',
  );
  ConsoleLog.debug('✅ Está autenticado: ${authViewModel.isAuthenticated}');
  ConsoleLog.debug('🎯 Iniciando aplicação Flutter...');
  runApp(
    MultiProvider(
      providers: InitProvider.createEssentialProviders(
        authViewModel: authViewModel,
        domainStorage: domainStorage,
        authService: authService,
      ),
      child: const MyApp(),
    ),
  );
  ConsoleLog.debug('🎉 Aplicação iniciada com sucesso!');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;
  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    _appRouter = AppRouter(authViewModel);
  }

  @override
  Widget build(BuildContext context) {
    NavigationService.instance.setRouter(_appRouter.router);
    return MaterialApp.router(
      theme: AppColors.lightTheme,
      debugShowCheckedModeBanner: false,
      title: FlavorConfig.appName,
      routerConfig: _appRouter.router,
      locale: const Locale('pt', 'BR'),
      supportedLocales: [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: SafeArea(
            top: false,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

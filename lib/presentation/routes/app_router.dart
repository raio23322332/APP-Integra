import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/widgets/shared/webview_page.dart';
import 'package:integra_app/services/navigation_service.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/ConsultarIpva.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/ConsultarIpva_modelo.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/Dentran_intro_page.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/emitir_certidao_page.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/intro_veiculos_page.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/ipva_page.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/pagar_ipva_page.dart';
import 'package:integra_app/presentation/views/Veiculos_e_condutores/validar_certidao_page.dart';
import 'package:integra_app/presentation/views/agropecuaria/intro.dart';
import 'package:integra_app/presentation/views/categorias_e_servicos/service_detail_screen.dart';
import 'package:integra_app/presentation/views/categorias_e_servicos/services_screen.dart';
import 'package:integra_app/presentation/views/consulta_cnh/consulta.dart';
import 'package:integra_app/presentation/views/agropecuaria/servicos.dart';
import 'package:integra_app/presentation/views/emprego_e_trabalho/intro.dart';
import 'package:integra_app/presentation/views/servico_mulher/MulherCiencia.dart';
import 'package:integra_app/presentation/views/servico_mulher/MulherCiencia_info.dart';
import 'package:integra_app/presentation/views/servico_mulher/Mulher_projetos.dart';
import 'package:integra_app/presentation/views/servico_mulher/Mulhercapacitacao.dart';
import 'package:integra_app/presentation/views/servico_mulher/MulhercapacitacaoInfo.dart';
import 'package:integra_app/presentation/views/servico_mulher/casa_mulher_atendimento_especializado.dart';
import 'package:integra_app/presentation/views/servico_mulher/mulher_projetosInfo.dart';
import 'package:integra_app/presentation/views/servico_mulher/ouvidoria.dart';
import 'package:integra_app/presentation/views/webview_page.dart';
import '../views/home/home_screen.dart';
import '../views/perfil/profile_screen.dart';
import '../views/perfil/security_screen.dart';
import '../views/perfil/edit_profile_screen.dart';
import '../views/perfil/protocol_list_screen.dart';
import '../views/protocol_screens.dart';
import '../views/protocols/protocol_detail_view.dart';
import '../../data/models/protocol_model.dart';
import '../views/solocitacao/solicitacao_view.dart';
import '../views/solicitacoes/endereco_screen.dart';
import '../views/solicitacoes/upload_screen.dart';
import '../views/solicitacoes/nova_solicitacao_screen.dart';
import '../views/sectors_screen.dart';
import '../views/protocols_screen.dart';
import '../views/protocol_center_screen.dart';
import '../views/create_sector_screen.dart';
import '../views/create_protocol_screen.dart';
import '../widgets/shared/scaffold_with_navbar.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth/auth_viewmodel.dart';
import '../viewmodels/auth/login_viewmodel.dart';
import '../viewmodels/register_viewmodel.dart';
import '../views/auth/login.dart';
import '../views/auth/register_page.dart';
import '../views/tenant_select_page.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/services/login_authentication_service.dart';
import '../../services/auth_service_adapter.dart';
import '../../domain/services/form_validation_service.dart';
import 'package:integra_app/presentation/viewmodels/cin_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/iluminacao/iluminacao_viewmodel_map.dart';
import '../views/reparo_iluminacao/iluminacao_lugar.dart';
import '../views/reparo_iluminacao/iluminacao.dart';
import '../views/reparo_iluminacao/enviar_relatorio.dart';
import '../views/poda_arvore/poda_de_arvore_form.dart';
import '../views/poda_arvore/poda_de_arvore_success.dart';
import '../views/poda_arvore/poda_de_arvore_intro_screen.dart';
import '../views/carteira_identiddade/carteira_identidade_intro_screen.dart';
import '../views/carteira_identiddade/carteira_identidade_screen.dart';
import '../views/cin_acompanhamento_screen.dart';
import '../views/cin_aviso_agendamento_screen.dart';
import '../views/cin_agendamento_tipo_screen.dart';
import '../views/cin_agendamento_form_screen.dart';
import '../views/user_management_screen.dart';
import '../views/tapa-buraco.dart';
import '../views/search_screen.dart';
import '../views/educacao/intro.dart';
import '../views/educacao/intro001.dart';
import '../views/servico_mulher/servicos_mulher.dart';
import '../views/servico_mulher/ouvidoria-informacoes.dart';
import '../views/servico_mulher/casa_mulher.dart';
import '../views/servico_mulher/casa_mulher_informacao.dart';
import '../views/servico_mulher/casa_mulher_atendimento_informacoes.dart';
import "../views/servico_mulher/mulher_protese.dart";
import '../views/servico_mulher/mulher_proteseInfo.dart';
import '../views/servico_mulher/mulher_acolhimento.dart';
import '../views/servico_mulher/mulher_aconlhimentoinfo.dart';
import '../../da../../da../../da../../data/models/tenant_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String secondaryProfile = '/secondary-profile';
  static const String ProtocolListPage = '/minhas-solicitacoes';
  static const String ProtocolDetailPage = '/protocolo-detalhe';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String RelatarBuracoScreen = '/relatar-buraco';
  static const String AcessoPage = '/acesso-page';
  static const String CadastroPage = '/cadastro-page';
  static const String ReparoIluminacaoPage = '/reparo-iluminacao';
  static const String iluminacaolugar = '/iluminacao-lugar';
  static const String formulario_iluminacao = '/formulario-iluminacao';
  static const String tenantSelect = '/selecao-subdominio';
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String ChangePasswordPage = '/mudar-senha';
  static const String PodaDeArvoreIntroPage = '/poda-de-arvore-intro';
  static const String PodaDeArvoreFormPage = '/poda-de-arvore-form';
  static const String PodaDeArvoreSuccessPage = '/poda-de-arvore-sucesso';
  static const String CarteiraIdentidadeIntroPage =
      '/carteira-identidade-intro';
  static const String CarteiraIdentidadePage = '/carteira-identidade';
  static const String CinAcompanhamentoPage = '/cin-acompanhamento';
  static const String CinAvisoAgendamentoPage = '/cin-aviso-agendamento';
  static const String CinAgendamentoTipoPage = '/cin-agendamento-tipo';
  static const String CinAgendamentoFormPage = '/cin-agendamento-form';
  static const String UserManagementPage = '/gerenciamento-usuarios';
  static const String serviceDetail = '/service-detail';
  static const String services = '/services';
  static const String educacao = '/educacao';
  static const String educacaointro = '/educacaointro';
  static const String servicosMulher = '/servicos-mulher';
  static const String CasaMulher = '/CasaMulher';
  static const String CasaMulherinformacao = '/CasaMulherinformacao';
  static const String CasaMulherinformacaoespecializada =
      '/CasaMulherinformacaoespecializada';
  static const String CasaMulherinformacaoespecializadaGuia =
      '/CasaMulherinformacaoespecializadaGuia';
  static const String servicosMulherMaisInformacoes =
      '/servicos-mulher-mais-informacoes';
  static const String SalaGirassolPage = '/sala_girassol';
  static const String MulherProtese = '/MulherProtese';
  static const String MulherProteseInfo = '/MulherProteseInfo';
  static const String MulherProjetosInfo = '/MulherProjetosInfo';
  static const String MulherAcolhimentoinfo = '/MulherAcolhimentoinfo';
  static const String Mulhercienciainfo = '/Mulhercienciainfo';
  static const String MulherCapacitacaoInfo = '/MulherCapacitacaoInfo';
  static const String TrabalhoEEmprego = '/TrabalhoEEmprego';
  static const String consultacnh = '/consultacnh';
  static const String Introagropecuaria = '/Introagropecuaria';
  static const String ProdutorRuralPage = '/produtor-rural';
  static const String IntroVeiculos = '/veiculos-e-condutores';
  static const String MeuIpva = '/meu-ipva';
  static const String webview = '/webview';
  static const String SolicitacaoView = '/solicitacao_view';
  static const String SubtipoSelection = '/solicitacoes/subtipos';
  static const String EnderecoSelection = '/solicitacoes/endereco';
  static const String UploadImagens = '/solicitacoes/upload';
  static const String NovaSolicitacao = '/solicitacoes/nova';
  static const String security = '/security';
  static const String editProfile = '/edit-profile';
}

class AppRouter {
  final AuthViewModel authViewModel;
  late final GoRouter router;
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();
  AppRouter(this.authViewModel) {
    router = GoRouter(
      refreshListenable: authViewModel,
      initialLocation: AppRoutes.tenantSelect,
      redirect: (context, state) {
        final authViewModel = context.read<AuthViewModel>();
        if (authViewModel.isInitializing) {
          return null;
        }
        
        final isAuthenticated = authViewModel.isAuthenticated;
        final currentLocation = state.matchedLocation;
        
        const publicRoutes = [
          AppRoutes.tenantSelect,
          AppRoutes.login,
          AppRoutes.cadastro,
        ];
        
        // Só redireciona para tenantSelect se NÃO estiver autenticado E não estiver em rota pública
        // E só se não houver usuário salvo (evita redirecionamento durante navegação)
        if (!isAuthenticated && !publicRoutes.contains(currentLocation)) {
          if (authViewModel.currentUser == null) {
            print('🔄 Router: Redirecionando para tenantSelect (usuário null)');
            return AppRoutes.tenantSelect;
          } else {
            print('🔄 Router: Usuário existe mas isAuthenticated=false, mantendo na tela atual');
            return null;
          }
        }
        
        if (isAuthenticated && publicRoutes.contains(currentLocation)) {
          final extra = state.extra;
          if (extra is Map && extra['showSuccessSnackBar'] == true) {
            Future.delayed(const Duration(milliseconds: 500), () {});
            return AppRoutes.home;
          }
          return AppRoutes.home;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.tenantSelect,
          name: 'tenantSelect',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const TenantSelectPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeInOutCubic,
                    ).animate(animation),
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) {
            final tenant = state.extra;
            if (tenant is Tenant) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ChangeNotifierProvider(
                  create: (_) => LoginViewModel(
                    loginUseCase: LoginUseCase(
                      LoginAuthenticationService(
                        AuthServiceAdapter(context.read<AuthViewModel>()),
                      ),
                    ),
                    validationService: FormValidationService(),
                    authViewModel: context.read<AuthViewModel>(),
                  ),
                  child: LoginPage(tenant: tenant),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOutCubic,
                        ).animate(animation),
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 400),
              );
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.tenantSelect);
              });
              return const MaterialPage(
                child: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
          },
        ),
        GoRoute(
          path: AppRoutes.cadastro,
          name: 'cadastro',
          pageBuilder: (context, state) {
            final tenantObject = state.extra;
            if (tenantObject is Tenant) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ChangeNotifierProvider(
                  create: (context) =>
                      RegisterViewModel(context.read<NavigationService>()),
                  child: RegisterPage(tenant: tenantObject),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurveTween(
                          curve: Curves.easeInOutCubic,
                        ).animate(animation),
                        child: child,
                      );
                    },
              );
            }
            return CustomTransitionPage(
              key: state.pageKey,
              child: const Scaffold(
                body: Center(child: Text('Tenant não fornecido')),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeInOutCubic,
                      ).animate(animation),
                      child: child,
                    );
                  },
            );
          },
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) =>
                  const IntegraHomePage(child: SizedBox()),
            ),
            GoRoute(
              path: AppRoutes.educacaointro,
              name: 'educacaointro',
              builder: (context, state) => const EducacaoPage(),
            ),
            GoRoute(
              path: AppRoutes.educacao,
              name: 'educacao',
              builder: (context, state) => const SeducServicosPage(),
            ),
            GoRoute(
              path: AppRoutes.servicosMulherMaisInformacoes,
              name: 'servicosMulherMaisInformacoes',
              builder: (context, state) => MaisinformacoesPage(),
            ),
            GoRoute(
              path: AppRoutes.servicosMulher,
              name: 'servicos-mulher',
              builder: (context, state) => const ServicosPage(),
            ),
            GoRoute(
              path: '/sala_girassol',
              builder: (context, _) => const SalaGirassolPage(),
            ),
            GoRoute(
              path: '/CasaMulher',
              builder: (context, _) => const CasaMulherPage(),
            ),
            GoRoute(
              path: AppRoutes.CasaMulherinformacao,
              name: 'CasaMulherinformacao',
              builder: (context, state) => CasaMulherInformacao(),
            ),
            GoRoute(
              path: AppRoutes.CasaMulherinformacaoespecializadaGuia,
              name: 'CasaMulherinformacaoespecializadaGuia',
              builder: (context, state) => CasaMulherAtendimentoEspecializado(),
            ),
            GoRoute(
              path: AppRoutes.CasaMulherinformacaoespecializada,
              name: 'CasaMulherinformacaoespecializada',
              builder: (context, state) =>
                  CasaMulherInformacaoatendimentoEspecializado(),
            ),
            GoRoute(
              path: AppRoutes.MulherProtese,
              name: 'MulherProtese',
              builder: (context, state) => CasaMulherProtese(),
            ),
            GoRoute(
              path: AppRoutes.MulherProteseInfo,
              name: 'MulherProteseInfo',
              builder: (context, state) => MulherProteseinfo(),
            ),
            GoRoute(
              path: '/Projetos_mulher',
              builder: (context, _) => const MulherProjetosPage(),
            ),
            GoRoute(
              path: AppRoutes.MulherProjetosInfo,
              name: 'MulherProjetosInfo',
              builder: (context, state) => MulherProjetosinfo(),
            ),
            GoRoute(
              path: '/MulherAcolhimento',
              builder: (context, _) => const MulherAcolhimento(),
            ),
            GoRoute(
              path: AppRoutes.MulherAcolhimentoinfo,
              name: 'MulherAcolhimentoinfo',
              builder: (context, state) => MulherAconlhimentoinfo(),
            ),
            GoRoute(
              path: '/MulherCiencia',
              builder: (context, _) => const Mulherciencia(),
            ),
            GoRoute(
              path: AppRoutes.Mulhercienciainfo,
              name: 'Mulhercienciainfo',
              builder: (context, state) => MulhercienciaInfo(),
            ),
            GoRoute(
              path: AppRoutes.services,
              builder: (context, state) {
                final category = state.extra as dynamic;
                return ServicesScreen(category: category);
              },
            ),
            GoRoute(
              path: AppRoutes.serviceDetail,
              builder: (context, state) {
                try {
                  final Map<String, dynamic> extras =
                      state.extra as Map<String, dynamic>;
                  final service = extras['service'];
                  final category = extras['category'];
                  return ServiceDetailScreen(
                    service: service,
                    category: category,
                  );
                } catch (e) {
                  // Erro de type cast - geralmente ocorre quando não há internet
                  // e os dados não foram carregados corretamente
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Não foi possível carregar os dados do serviço. Verifique sua conexão com a internet e tente novamente.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    // Navega de volta após mostrar o snackbar
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (context.mounted) {
                        context.pop();
                      }
                    });
                  });
                  
                  // Retorna uma tela vazia enquanto o diálogo é mostrado
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
            GoRoute(
              path: '/Mulhercapacitacao',
              builder: (context, _) => const Mulhercapacitacao(),
            ),
            GoRoute(
              path: AppRoutes.MulherCapacitacaoInfo,
              name: 'MulherCapacitacaoInfo',
              builder: (context, state) => Mulhercapacitacaoinfo(),
            ),
            GoRoute(
              path: AppRoutes.secondaryProfile,
              name: 'secondaryProfile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.favorites,
              name: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: AppRoutes.search,
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/protocolos',
              name: 'protocols',
              builder: (context, state) => const ProtocolCenterScreen(),
              routes: [
                GoRoute(
                  path: '/detail',
                  name: 'protocolDetail',
                  builder: (context, state) {
                    final protocol = state.extra as ProtocolModel;
                    return ProtocolDetailView(protocol: protocol);
                  },
                ),
                GoRoute(
                  path: '/create',
                  name: 'createProtocol',
                  builder: (context, state) => const CreateProtocolScreen(),
                ),
                GoRoute(
                  path: '/forward',
                  name: 'protocolForward',
                  builder: (context, state) {
                    final protocol = state.extra as ProtocolModel;
                    return ProtocolForwardScreen(protocol: protocol);
                  },
                ),
                GoRoute(
                  path: '/receive',
                  name: 'protocolReceive',
                  builder: (context, state) {
                    final protocol = state.extra as ProtocolModel;
                    return ProtocolReceiveScreen(protocol: protocol);
                  },
                ),
                GoRoute(
                  path: '/comment',
                  name: 'protocolComment',
                  builder: (context, state) {
                    final protocol = state.extra as ProtocolModel;
                    return ProtocolCommentScreen(protocol: protocol);
                  },
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.RelatarBuracoScreen,
              name: 'RelatarBuracoScreen',
              builder: (context, state) => const TapaBuracoPage(),
            ),
            GoRoute(
              path: AppRoutes.ReparoIluminacaoPage,
              name: 'ReparoIluminacaoPage',
              builder: (context, state) => const RepairRequestScreen(),
            ),
            GoRoute(
              path: AppRoutes.iluminacaolugar,
              name: 'iluminacaolugar',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => IluminacaoViewModel(),
                child: const LocationSelectorScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.formulario_iluminacao,
              name: 'iformulario_iluminacao',
              builder: (context, state) => const ReportProblemScreen(),
            ),
            GoRoute(
              path: AppRoutes.consultacnh,
              name: 'consultacnh',
              builder: (context, state) => const ConsultaCnhPage(),
            ),
            GoRoute(
              path: AppRoutes.webview,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final title = extra?['title'] ?? 'Serviço';
                final url = extra?['url'] ?? '';
                return WebViewPage(title: title, url: url);
              },
            ),
            GoRoute(
              path: AppRoutes.PodaDeArvoreIntroPage,
              name: 'PodaDeArvoreIntroPage',
              builder: (context, state) => const PodaDeArvoreIntroScreen(),
            ),
            GoRoute(
              path: AppRoutes.PodaDeArvoreFormPage,
              name: 'PodaDeArvoreFormPage',
              builder: (context, state) => const PodaDeArvoreFormScreen(),
            ),
            GoRoute(
              path: AppRoutes.PodaDeArvoreSuccessPage,
              name: 'PodaDeArvoreSuccessPage',
              builder: (context, state) {
                final protocol = state.extra as String;
                return PodaDeArvoreSuccessScreen(protocol: protocol);
              },
            ),
            GoRoute(
              path: AppRoutes.TrabalhoEEmprego,
              name: 'TrabalhoEEmprego',
              builder: (context, state) => const TrabalhoEmpregoPage(),
            ),
            GoRoute(
              path: AppRoutes.CarteiraIdentidadeIntroPage,
              name: 'CarteiraIdentidadeIntroPage',
              builder: (context, state) =>
                  const CarteiraIdentidadeIntroScreen(),
            ),
            GoRoute(
              path: AppRoutes.CarteiraIdentidadePage,
              name: 'CarteiraIdentidadePage',
              builder: (context, state) => const CarteiraIdentidadeScreen(),
            ),
            GoRoute(
              path: AppRoutes.CinAcompanhamentoPage,
              name: 'CinAcompanhamentoPage',
              builder: (context, state) => const CinAcompanhamentoScreen(),
            ),
            GoRoute(
              path: AppRoutes.CinAvisoAgendamentoPage,
              name: 'CinAvisoAgendamentoPage',
              builder: (context, state) => const CinAvisoAgendamentoScreen(),
            ),
            GoRoute(
              path: AppRoutes.CinAgendamentoTipoPage,
              name: 'CinAgendamentoTipoPage',
              builder: (context, state) => ChangeNotifierProvider(
                create: (_) => CinViewModel(),
                child: const CinAgendamentoTipoScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.CinAgendamentoFormPage,
              name: 'CinAgendamentoFormPage',
              builder: (context, state) => const CinAgendamentoFormScreen(),
            ),
            GoRoute(
              path: AppRoutes.Introagropecuaria,
              name: 'Introagropecuari',
              builder: (context, state) => const AgropecuariaPage(),
            ),
            GoRoute(
              path: AppRoutes.ProdutorRuralPage,
              name: 'ProdutorRuralPage',
              builder: (context, state) => const ProdutorRuralPage(),
            ),
            GoRoute(
              path: AppRoutes.IntroVeiculos,
              name: 'IntroVeiculos',
              builder: (context, state) => const IntroVeiculosPage(),
            ),
            GoRoute(
              path: AppRoutes.MeuIpva,
              name: 'MeuIpva',
              builder: (context, state) => const MeuIPVATela(),
            ),
            GoRoute(
              path: '/PagarIpva',
              builder: (context, _) => const PagarIPVATela(),
            ),
            GoRoute(
              path: '/validar',
              builder: (context, _) => const ValidarCertidaoPage(),
            ),
            GoRoute(
              path: '/ConsultarIpva',
              builder: (context, _) => const ConsultarIpvaVeiculoPage(),
            ),
            GoRoute(
              path: '/ConsultarIpvaModelo',
              builder: (context, _) => const ConsultarIpvaModeloPage(),
            ),
            GoRoute(
              path: '/EmitirQuitacao',
              builder: (context, _) => const EmitirCertidaoPage(),
            ),
            GoRoute(
              path: '/detran',
              builder: (context, _) => const DetranServicesPage(),
            ),
            GoRoute(
              path: AppRoutes.SolicitacaoView,
              name: 'SolicitacaoView',
              builder: (context, state) {
                final extra = state.extra as Map<String, Object?>?;
                final tipo = (extra?['title'] as String?) ?? '';
                final slug = (extra?['slug'] as String?) ?? '';
                return SolicitacaoView(tipo: tipo, slug: slug);
              },
            ),
            GoRoute(
              path: AppRoutes.EnderecoSelection,
              name: 'EnderecoSelection',
              builder: (context, state) {
                final extra = state.extra as Map<String, Object?>?;
                return EnderecoScreen(dados: extra ?? {});
              },
            ),
            GoRoute(
              path: AppRoutes.UploadImagens,
              name: 'UploadImagens',
              builder: (context, state) {
                final extra = state.extra as Map<String, Object?>?;
                return UploadScreen(dados: extra ?? {});
              },
            ),
            GoRoute(
              path: AppRoutes.NovaSolicitacao,
              name: 'NovaSolicitacao',
              builder: (context, state) {
                final extra = state.extra as Map<String, Object?>?;
                return NovaSolicitacaoScreen(dados: extra ?? {});
              },
            ),
            GoRoute(
              path: AppRoutes.security,
              name: 'security',
              builder: (context, state) => const SecurityScreen(),
            ),
            GoRoute(
              path: AppRoutes.editProfile,
              name: 'editProfile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.UserManagementPage,
              name: 'UserManagementPage',
              builder: (context, state) => const UserManagementScreen(),
              redirect: (context, state) {
                final authViewModel = context.read<AuthViewModel>();
                if (!authViewModel.hasPermission('manage-users')) {
                  return AppRoutes.home;
                }
                return null;
              },
            ),
            GoRoute(
              path: '/setores',
              name: 'sectors',
              builder: (context, state) => const SectorsScreen(),
            ),
            GoRoute(
              path: '/setores/create',
              name: 'createSector',
              builder: (context, state) => const CreateSectorScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

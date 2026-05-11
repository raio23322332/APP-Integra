import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:integra_app/presentation/widgets/common/breadcrumb_widget.dart';
import 'package:integra_app/services/storage/domain_storage.dart' show DomainStorage;
import 'package:provider/provider.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/core/utils/icon_mapper.dart';
import 'package:integra_app/presentation/viewmodels/categorias_e_servicos/service_detail_viewmodel.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/presentation/views/categorias_e_servicos/service_webview_screen.dart';
import 'package:integra_app/core/models/breadcrumb_model.dart';
import 'package:integra_app/presentation/providers/breadcrumb_provider.dart';
import 'package:integra_app/presentation/routes/app_router.dart';


class ServiceDetailScreen extends StatefulWidget {
  final dynamic service;
  final dynamic category; // ✅ Adicionada categoria para navegação de volta
  const ServiceDetailScreen({
    required this.service,
    required this.category,
    super.key
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  StreamSubscription<ViewModelEvent>? _sub;

  @override
  void initState() {
    super.initState();
    
    // Debug logs
    debugPrint('🎯 ServiceDetailScreen - initState');
    debugPrint('🎯 Service recebido: ${widget.service}');
    debugPrint('🎯 Category recebida: ${widget.category}');
    debugPrint('🎯 Service title: ${widget.service?.title}');
    debugPrint('🎯 Category name: ${widget.category?.name}');
    
    // Atualiza breadcrumbs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BreadcrumbProvider>();
      provider.setBreadcrumbs([
        const BreadcrumbItem(title: 'Home', route: AppRoutes.home),
        BreadcrumbItem(
          title: widget.category?.name ?? 'Categoria',
          route: AppRoutes.services,
          extra: widget.category,
        ),
        BreadcrumbItem(
          title: widget.service?.title ?? 'Serviço',
          route: AppRoutes.serviceDetail,
          extra: {'service': widget.service, 'category': widget.category},
        ),
      ]);
      provider.sendBreadcrumbToApi();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Color _getBadgeColor(ServiceChannel channel) {
    switch (channel) {
      case ServiceChannel.semiDigital:
        return const Color(0xFFFFC107); // amarelo
      case ServiceChannel.digital:
        return const Color(0xFF28A745); // verde
      case ServiceChannel.nonDigital:
        return const Color(0xFF0A1F33); // azul escuro
      case ServiceChannel.unknown:
        return const Color(0xFF0A1F33);
    }
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    if (event is ShowSnackBarEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.message),
          backgroundColor: event.isError ? Colors.red : Colors.green,
        ),
      );
      return;
    }

    if (event is NavigationEvent) {
      context.go(event.route, extra: event.extra);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ServiceDetailViewModel>(
      create: (context) => ServiceDetailViewModel(
        domainStorage: Provider.of<DomainStorage>(context, listen: false),
        service: widget.service,
      ),
      child: Consumer<ServiceDetailViewModel>(
        builder: (context, viewModel, child) {
          // Assina events 1 vez (com segurança)
          _sub ??= viewModel.events.listen(_handleEvent);

          final service = viewModel.service;

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              title: Text(
                service.title.length > 20 
                    ? '${service.title.substring(0, 20)}...' 
                    : service.title,
              ),
              actions: [
                if (widget.category?.icon?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _CategoryIcon(iconName: widget.category.icon),
                  ),
              ],
              foregroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                tooltip: 'Voltar',
                padding: EdgeInsets.zero,
                splashRadius: 20,
                onPressed: () {
                  // Remover apenas o último item do breadcrumb ao voltar
                  final breadcrumbProvider = context.read<BreadcrumbProvider>();
                  breadcrumbProvider.removeLast();
                  
                  if (GoRouter.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
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
            ),

            body: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 6,
              radius: const Radius.circular(6),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(), // Evita overflow no final
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BREADCRUMB COM PADDING CONSISTENTE
                      const Padding(
                        padding: EdgeInsets.fromLTRB(4, 4, 16, 8),
                        child: BreadcrumbWidget(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildCard(
                          child: Column(
                            children: [
                              _buildDetailRowWithBadge(
                                Icons.info_outline,
                                'Tipo de Serviço',
                                viewModel.formatServiceType(service.type),
                                _getBadgeColor(viewModel.channel),
                              ),
                              _buildDetailRow(Icons.location_on_outlined, 'Endereço', service.address),
                              _buildDetailRow(Icons.monetization_on_outlined, 'Custo', viewModel.formatCost(service.cost)),
                              _buildDetailRow(Icons.timer_outlined, 'Prazo', service.duration),
                              _buildDetailRow(Icons.people_outline, 'Quem pode solicitar?', service.users),
                              _buildDetailRow(Icons.account_balance_outlined, 'Unidade Responsável', service.unit),
                              _buildDetailRow(Icons.person_outline, 'Responsável', service.responsible),
                              _buildDetailRow(Icons.update_outlined, 'Última atualização', viewModel.formatLastUpdate(service.lastUpdate)),
                              const SizedBox(height: 16),

                              if (viewModel.canOpenWeb)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: viewModel.isLoading
                                        ? Container(
                                            width: 24,
                                            height: 24,
                                            padding: const EdgeInsets.all(2.0),
                                            child: const AppLoader(),
                                          )
                                        : const Icon(Icons.web),
                                    label: Text(viewModel.isLoading ? 'Carregando...' : 'Abrir no Web'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 3,
                                    ),
                                    onPressed: viewModel.isLoading ? null : () => _openServiceWebView(context, viewModel),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: service.sections.map((section) => _buildAccordionSection(section, viewModel)).toList(),
                        ),
                      ),
                      const SizedBox(height: 32), // Espaçamento final aumentado
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.primaryBlue, width: 4)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _buildDetailRowWithBadge(
    IconData icon,
    String label,
    String value,
    Color badgeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: AppColors.lightSecondaryText)),
                _buildBadge(value, badgeColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: AppColors.lightSecondaryText)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightPrimaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionSection(Map<String, dynamic> section, ServiceDetailViewModel viewModel) {
    final title = section['title'] as String? ?? 'Detalhes';
    final processedContent = viewModel.processSectionContent(section['content']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.primaryBlue, width: 4)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.lightPrimaryText),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSectionContent(processedContent)],
      ),
    );
  }

  Widget _buildSectionContent(ProcessedSectionContent processedContent) {
    const textStyle = TextStyle(fontSize: 15, height: 1.5, color: AppColors.lightSecondaryText);

    switch (processedContent.type) {
      case ProcessedSectionContentType.text:
        return Text(processedContent.textContent ?? '', style: textStyle);

      case ProcessedSectionContentType.steps:
        final steps = processedContent.stepsContent!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (steps.online.isNotEmpty) ...[
              const Text('Passos online:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              ...steps.online.map(
                (step) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(step, style: textStyle)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (steps.presencial.isNotEmpty) ...[
              const Text('Passos presenciais:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              ...steps.presencial.map(
                (step) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(step, style: textStyle)),
                  ],
                ),
              ),
            ],
          ],
        );

      case ProcessedSectionContentType.unavailable:
        return const Text('Conteúdo indisponível.', style: TextStyle(fontStyle: FontStyle.italic));
    }
  }

  /// ✅ Função para abrir WebView MVVM do serviço
  Future<void> _openServiceWebView(BuildContext context, ServiceDetailViewModel viewModel) async {
    // ✅ Chama o método do ViewModel para obter os dados
    final webData = await viewModel.openOnWeb();

    if (webData != null && mounted) {
      // ✅ Navegação para WebView MVVM com os dados reais
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ServiceWebViewScreen(
            title: viewModel.service.title.length > 20 
                ? '${viewModel.service.title.substring(0, 20)}...' 
                : viewModel.service.title,
            url: webData['url'] ?? 'https://www.google.com',
          ),
        ),
      );
    } else if (mounted) {
      // ✅ Mostra mensagem de erro se não conseguiu abrir
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este serviço não pode ser aberto no Web.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _CategoryIcon extends StatelessWidget {
  final String iconName;

  const _CategoryIcon({required this.iconName});

  @override
  Widget build(BuildContext context) {
    // Verifica se é uma URL (começa com http) ou um nome de ícone
    if (iconName.startsWith('http')) {
      // Se for URL, usa Image/Svg
      if (iconName.endsWith('.svg')) {
        return Image.network(
          iconName,
          width: 30,
          height: 30,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.category, color: Colors.white),
        );
      } else {
        return Image.network(
          iconName,
          width: 30,
          height: 30,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.category, color: Colors.white),
        );
      }
    } else {
      // Se for nome de ícone da API, usa o mapeamento
      final iconData = mapCategoryIcon(iconName);
      return Icon(iconData, color: Colors.white, size: 30);
    }
  }
}

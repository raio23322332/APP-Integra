// lib/presentation/views/protocol/protocol_list_screen.dart
import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/data/models/solicitacao_model.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/protocol/protocol_list_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';

import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';





class ProtocolListScreen extends StatefulWidget {
  const ProtocolListScreen({super.key});

  @override
  State<ProtocolListScreen> createState() => _ProtocolListScreenState();
}

class _ProtocolListScreenState extends State<ProtocolListScreen> {
  final primaryBlue = const Color(0xFF28669b);
  final secondaryGreen = const Color(0xFF4b8c40);
  final highlightTeal = const Color(0xFF248e95);
  final textDark = const Color(0xFF263860);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ MVVM: Inicialização delegada para ViewModel
      final viewModel = context.read<ProtocolListViewModel>();
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ MVVM: ViewModel fornece tudo que a View precisa
    final protocolListVM = context.watch<ProtocolListViewModel>();

    return Scaffold(
      key: const Key('protocol_list_scaffold'),
      backgroundColor: AppColors.background,
      appBar: AppBar(

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.go("/profile"),
        ),
        title: const Text('Minhas Solicitações (Protocolos)'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,

      ),
      body: !protocolListVM.isAuthenticated
          ? _buildLoginPrompt()
          : Column(
              key: const Key('protocol_list_column'),
              children: [
                _buildFilters(),
                Expanded(
                  child: Consumer<ProtocolListViewModel>(
                    key: const Key('protocol_list_consumer'),
                    builder: (context, protocolListVM, child) {
                      final state = protocolListVM;
                      
                      if (state.isLoading) {
                        return const AppLoader();
                      }
                      
                      if (state.error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Erro ao carregar solicitações: ${state.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => protocolListVM.refresh(),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (state.requests.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      return RefreshIndicator(
                        key: const Key('protocol_list_refresh_indicator'),
                        onRefresh: () async => protocolListVM.refresh(),
                        child: ListView.builder(
                          key: const Key('protocol_list_view'),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: state.requests.length,
                          itemBuilder: (context, index) {
                            return _buildProtocolCard(
                              state.requests[index],
                              protocolListVM,
                              index,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Consumer<ProtocolListViewModel>(
      key: const Key('protocol_filters_consumer'),
      builder: (context, viewModel, child) {
        return Container(
          key: const Key('protocol_filters_container'),
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const Spacer(),
                  if (viewModel.selectedTipoId != null || viewModel.selectedSubtipoId != null)
                    TextButton(
                      onPressed: () => viewModel.clearFilters(),
                      child: Text(
                        'Limpar',
                        style: TextStyle(color: primaryBlue),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    initialValue: viewModel.selectedTipoId,
                    items: viewModel.tiposDisponiveis.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo.id,
                        child: Text(tipo.descricao ?? 'Sem nome'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setTipoFilter(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Subtipo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    initialValue: viewModel.selectedSubtipoId,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Todos os subtipos'),
                      ),
                      ...viewModel.subtiposDisponiveis.map((subtipo) {
                        return DropdownMenuItem<String>(
                          value: subtipo.id,
                          child: Text(subtipo.descricao ?? 'Sem nome'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setSubtipoFilter(value);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      key: const Key('protocol_login_prompt'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.userLock, size: 60, color: primaryBlue),
            const SizedBox(height: 20),
            Text(
              'Acesso Necessário',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Para visualizar suas solicitações e protocolos, por favor, faça login.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(FontAwesomeIcons.rightToBracket),
              label: const Text('Ir para o Inicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const Key('protocol_empty_state'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.boxOpen, size: 60, color: highlightTeal),
            const SizedBox(height: 20),
            Text(
              'Nenhuma Solicitação Encontrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Você ainda não abriu nenhuma solicitação. Use o menu principal para iniciar um novo serviço.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolCard(
    SolicitacaoModel request,
    ProtocolListViewModel viewModel,
    int index,
  ) {
    return Card(
      key: ValueKey('protocol_card_${request.id}'),
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      color: const Color(0xFFF9FAFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () => viewModel.navigateToDetail(request), // ✅ Delega navegação
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Protocolo: ${request.codigo ?? "N/A"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryBlue,
                    ),
                  ),
                  _buildStatusChip(
                    request.status ?? 'Pendente',
                    viewModel.getStatusColor(request.status ?? 'Pendente'),
                    viewModel.getStatusIcon(request.status ?? 'Pendente'),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                'Aberto em: ${viewModel.formatDate(request.dateTime)}',
                style: TextStyle(color: textDark.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 5),
              if (request.tipoId != null)
                Text(
                  'Tipo: ${request.getDescricaoTipo(request.tipoId!)}',
                  style: TextStyle(
                    color: textDark.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              if (request.subtipoId != null)
                Text(
                  'Subtipo: ${request.getDescricaoTipoSubTipo(request.tipoId ?? "0", request.subtipoId!)}',
                  style: TextStyle(
                    color: textDark.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 5),
              Text(
                viewModel.extractProblemFromDescription(request.descricao),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Ver Detalhes >',
                  style: TextStyle(
                    color: highlightTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

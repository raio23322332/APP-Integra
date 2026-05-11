// presentation/views/solocitacao/solicitacao_detail_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/solicitacao_model.dart';
import '../../../widgets/dialogs/confirmation_dialog.dart';
import '../../widgets/common/breadcrumb_widget.dart';
import '../../../core/models/breadcrumb_model.dart';
import '../../providers/breadcrumb_provider.dart';
import '../../../core/helpers/console_log.dart';
import 'solicitacao_edit_screen.dart';
import '../../../services/http/solicitacao_http.dart';
import '../../widgets/shared/custom_snack_bar.dart';
import '../../widgets/common/app_loader.dart';

class SolicitacaoDetailScreen extends StatelessWidget {
  final SolicitacaoModel solicitacao;

  const SolicitacaoDetailScreen({super.key, required this.solicitacao});

  // Sua cor primária preferida
  static const Color _primaryColor = Color(0xFF2b529c);

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SolicitacaoEditScreen(solicitacao: solicitacao),
      ),
    );

    // Se a edição foi bem-sucedida, redireciona para home
    if (result == true && context.mounted) {
      CustomSnackBar.showSuccess(context, 'Solicitação atualizada com sucesso!');
      // Redireciona para home após edição bem-sucedida
      context.go('/');
    }
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Excluir Solicitação',
      message: 'Tem certeza que deseja excluir esta solicitação?',
      // detailText: solicitacao.descricao,
      confirmText: 'Comfirmar',
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red,
      confirmColor: Colors.red,
      showWarning: false,
    );
    
    if (confirmed == true && context.mounted) {
      _deleteSolicitacao(context);
    }
  }

  Future<void> _deleteSolicitacao(BuildContext context) async {
  AppLoader.show(context, message: 'Excluindo solicitação...');
  
  try {
    final solicitacaoHttp = SolicitacaoHttp();
    
    ConsoleLog.informacao('Excluindo solicitação ID: ${solicitacao.id}');
    
    final response = await solicitacaoHttp.deletarSolicitacao(
      int.parse(solicitacao.id),
    );

    ConsoleLog.informacao('Status Code: ${response.statusCode}');
    ConsoleLog.informacao('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      if (context.mounted) {
        CustomSnackBar.showSuccess(context, 'Solicitação excluída com sucesso!');
        AppLoader.hide(context);
        // Redireciona para home após exclusão bem-sucedida
        context.go('/');
      }
    } else {
      throw Exception('Erro ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
    ConsoleLog.error('Erro ao excluir solicitação: $e');
    if (context.mounted) {
      CustomSnackBar.showError(context, 'Erro ao excluir solicitação: $e');
    }
  } finally {
    if (context.mounted) {
      AppLoader.hide(context);
    }
  }
}

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

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Não informada';
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateTime;
    }
  }

  void _setupBreadcrumbs(BuildContext context) {
    final breadcrumbProvider = context.read<BreadcrumbProvider>();
    breadcrumbProvider.setBreadcrumbs([
      const BreadcrumbItem(title: 'Home', route: '/'),
      const BreadcrumbItem(
        title: 'Solicitações',
        route: '/solicitacoes',
      ),
      const BreadcrumbItem(
        title: 'Detalhes da Solicitação',
        route: null, // Página atual
      ),
    ]);
    breadcrumbProvider.sendBreadcrumbToApi();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    // Configurar breadcrumbs para a tela de detalhes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupBreadcrumbs(context);
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context, isSmallScreen),
        body: SafeArea(
          child: Column(
            children: [
              // BREADCRUMB ALINHADO À ESQUERDA
              Align(
                alignment: Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 4, 16, 8),
                  child: BreadcrumbWidget(),
                ),
              ),
              // Abas
              Container(
                color: Colors.white,
                child: TabBar(
                  indicatorColor: _primaryColor,
                  labelColor: _primaryColor,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Dados'),
                    Tab(text: 'Arquivos'),
                  ],
                ),
              ),
              // Conteúdo das abas
              Expanded(
                child: TabBarView(
                  children: [
                    _buildDadosTab(screenWidth, isSmallScreen, context),
                    _buildArquivosTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isSmallScreen) {
    return AppBar(
      title: Text(
        'Detalhes da Solicitação',
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Ícone do tipo de solicitação
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(
            _getIconForTipo(solicitacao.getDescricaoTipo(solicitacao.tipoId ?? '')),
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
        onPressed: () {
          // Remover o último breadcrumb antes de voltar
          context.read<BreadcrumbProvider>().removeLast();
          Navigator.of(context).pop();
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
    );
  }

  Widget _buildDadosTab(double screenWidth, bool isSmallScreen, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(isSmallScreen, context),
          const SizedBox(height: 16),
          if (solicitacao.descricao?.isNotEmpty == true)
            _buildDescriptionCard(),
          const SizedBox(height: 16),
          _buildDetailsCardWithoutImagens(),
        ],
      ),
    );
  }

  Widget _buildArquivosTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildImagensGrid(),
    );
  }

  Widget _buildStatusCard(bool isSmallScreen, BuildContext context) {
    final status = solicitacao.status ?? 'N/A';
    final statusColor = _getStatusColor(status);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.assignment_turned_in,
                color: statusColor,
                size: isSmallScreen ? 28 : 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          solicitacao.codigo ?? 'N/A',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      // Botões de ação pequenos e legais
                      if (solicitacao.status?.toLowerCase() == 'aguardando') ...[
                        // Botão editar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _navigateToEdit(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Botão apagar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _confirmDelete(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Descrição',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              solicitacao.descricao!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCardWithoutImagens() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: _primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Informações Detalhadas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo
            if (solicitacao.tipoId != null)
              _buildDetailItem(
                icon: Icons.article_rounded,
                label: 'Tipo',
                value: solicitacao.getDescricaoTipo(solicitacao.tipoId!),
              ),

            // Subtipo
            if (solicitacao.subtipoId != null)
              _buildDetailItem(
                icon: Icons.category,
                label: 'Categoria',
                value: solicitacao.getDescricaoTipoSubTipo(
                  solicitacao.tipoId.toString(),
                  solicitacao.subtipoId!,
                ),
              ),

            // Data de criação
            _buildDetailItem(
              icon: Icons.access_time,
              label: 'Criado em',
              value: _formatDateTime(solicitacao.dateTime),
            ),

            // Última atualização
            /*
            _buildDetailItem(
              icon: Icons.update,
              label: 'Última atualização',
              value: _formatDateTime(solicitacao.updatedAt),
            ),
            */

            // Prazo
            if (solicitacao.prazo?.isNotEmpty == true)
              _buildDetailItem(
                icon: Icons.schedule,
                label: 'Prazo',
                value: solicitacao.prazo!,
              ),

            // Observação
            if (solicitacao.observacao?.isNotEmpty == true)
              _buildDetailItem(
                icon: Icons.note,
                label: 'Observação',
                value: solicitacao.observacao!,
              ),

            // Endereço(s)
            _buildDetailItem(
              icon: Icons.location_on,
              label: 'Endereço(s)',
              value: null,
            ),
            ..._buildEnderecos(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEnderecos() {
    final enderecos = solicitacao.enderecos ?? [];
    if (enderecos.isEmpty) {
      return [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Text(
            'Nenhum endereço cadastrado',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ];
    }

    return enderecos.map((endereco) {
      final linha1 = '${endereco.logradouro}, ${endereco.numero}';
      final linha2 =
          '${endereco.bairro}, ${endereco.cidade} - ${endereco.estado}';
      return Padding(
        padding: const EdgeInsets.only(left: 40, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(linha1, style: const TextStyle(fontSize: 14)),
            if (endereco.complemento?.isNotEmpty == true)
              Text(endereco.complemento!, style: const TextStyle(fontSize: 14)),
            Text(linha2, style: const TextStyle(fontSize: 14)),
            if (endereco.cep.isNotEmpty)
              Text(
                'CEP: ${endereco.cep}',
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildImagensGrid() {
    final arquivos = solicitacao.arquivos;
    if (arquivos == null || arquivos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Nenhuma imagem anexada',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: arquivos.length,
      itemBuilder: (context, index) {
        final url = arquivos[index].url.toString();
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(16),
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Imagem não carregou',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: value == null ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primaryColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                if (value != null)
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'andamento':
        return Colors.blue;
      case 'concluido':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

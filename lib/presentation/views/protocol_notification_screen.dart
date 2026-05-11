import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/protocol/protocol_notification_viewmodel.dart';
import '../widgets/common/network_error_widget.dart';
import '../../data/models/protocol_notification_model.dart';
import '../../core/utils/notification_utils.dart';
import '../views/protocols/protocol_app_bar.dart';
import '../views/protocols/protocol_detail_view.dart';

class ProtocolNotificationScreen extends StatefulWidget {
  const ProtocolNotificationScreen({Key? key}) : super(key: key);

  @override
  State<ProtocolNotificationScreen> createState() => _ProtocolNotificationScreenState();
}

class _ProtocolNotificationScreenState extends State<ProtocolNotificationScreen> {
  late ProtocolNotificationViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProtocolNotificationViewModel();
    _loadNotifications();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    _viewModel.loadNotifications();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _viewModel.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: protocolAppBar(
          title: 'Notificações',
          actions: [
            Consumer<ProtocolNotificationViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.unreadCount > 0) {
                  return IconButton(
                    icon: const Icon(Icons.mark_email_read, color: Colors.white),
                    onPressed: () => _showMarkAllAsReadDialog(context),
                    tooltip: 'Marcar todas como lidas',
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: viewModel.refresh,
                  tooltip: 'Atualizar',
                );
              },
            ),
          ],
        ),
        body: Consumer<ProtocolNotificationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.error != null && viewModel.notifications.isEmpty) {
              return NetworkErrorWidget(
                customMessage: viewModel.error,
                onRetry: _loadNotifications,
              );
            }

            if (viewModel.notifications.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                if (viewModel.unreadCount > 0)
                  _buildUnreadCountHeader(viewModel.unreadCount),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: viewModel.refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.notifications.length + 
                                (viewModel.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == viewModel.notifications.length) {
                          return viewModel.isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }

                        final notification = viewModel.notifications[index];
                        return _buildNotificationCard(notification, viewModel);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você não possui notificações de protocolo no momento.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadCountHeader(int unreadCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$unreadCount notificação${unreadCount != 1 ? 'ões' : ''} não lida${unreadCount != 1 ? 's' : ''}',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showMarkAllAsReadDialog(context),
            child: Text(
              'Marcar todas como lidas',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkAllAsReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar todas como lidas'),
        content: const Text(
          'Deseja marcar todas as notificações como lidas? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewModel.markAllAsRead();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(ProtocolNotificationModel notification, ProtocolNotificationViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: NotificationUtils.getBackgroundColor(notification.type, notification.isRead),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          NotificationUtils.getIcon(notification.type),
                          size: 14,
                          color: NotificationUtils.getTextColor(notification.type, notification.isRead),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NotificationUtils.getDisplayName(notification.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NotificationUtils.getTextColor(notification.type, notification.isRead),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (notification.message != null) ...[
                const SizedBox(height: 4),
                Text(
                  notification.message!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              if (notification.protocol != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Protocolo: ${notification.protocol!.number}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (notification.protocol != null)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProtocolDetailView(protocol: notification.protocol!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.description, size: 16),
                      label: const Text('Ver protocolo'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  if (!notification.isRead) ...[
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => viewModel.markAsRead(notification.id),
                      icon: const Icon(Icons.mark_email_read, size: 16),
                      label: const Text('Marcar como lida'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleNotificationTap(ProtocolNotificationModel notification) {
    // Marcar como lida automaticamente ao tocar
    if (!notification.isRead) {
      _viewModel.markAsRead(notification.id);
    }

    // Se tiver um protocolo associado, navegar para os detalhes
    if (notification.protocol != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProtocolDetailView(protocol: notification.protocol!),
        ),
      );
    } else {
      // Mostrar mensagem se não houver protocolo associado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta notificação não possui um protocolo associado'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

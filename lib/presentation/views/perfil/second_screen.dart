import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:integra_app/data/models/repair_request_model.dart';
import 'package:integra_app/presentation/viewmodels/auth/auth_viewmodel.dart';
import 'package:integra_app/presentation/viewmodels/repair_request_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:provider/provider.dart';


class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userId = authViewModel.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu perfil'),
      ),
      body: Column(
        
        
        children: <Widget>[
          
          Padding(
            
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  authViewModel.currentUser?.email ?? 'Visitante',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: authViewModel.logout,
                  icon: const Icon(Icons.logout, size: 24),
                  label: const Text(
                    'Sair da Conta',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Minhas Solicitações (Protocolos)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Expanded(
            child: userId != null
                ? FutureBuilder<List<RepairRequest>>(
                    future: context.read<RepairRequestViewModel>().getRequestsByUserId(userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const AppLoader();
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar protocolos: ${snapshot.error}',
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma solicitação de reparo encontrada.',
                          ),
                        );
                      }

                      final requests = snapshot.data!;
                      return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return ProtocolTile(request: request);
                        },
                      );
                    },
                  )
                : const Center(
                    child: Text('Faça login para ver suas solicitações.'),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: OutlinedButton.icon(
              onPressed: () => print('Compartilhar o Ceará App pressionado'),
              icon: Icon(Icons.share, size: 24, color: Theme.of(context).colorScheme.primary),
              label: Text(
                'Compartilhe o Ceará App',
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProtocolTile extends StatelessWidget {
  final RepairRequest request;

  const ProtocolTile({required this.request, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          leading: Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
          title: Text(
            'Protocolo: ${request.protocol}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Status: ${request.status} - ${request.date.day}/${request.date.month}/${request.date.year}',
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Detalhes do Protocolo: ${request.description}'),
              ),
            );
          },
        ),
        const Divider(height: 1, thickness: 1, indent: 16),
      ],
    );
  }
}


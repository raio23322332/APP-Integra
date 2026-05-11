import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/viewmodels/mulher_viewmodel/servico_mulher.dart';
import 'package:integra_app/presentation/widgets/widgets_mulher/servicos-mulher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




class ServicosPage extends StatelessWidget {
  const ServicosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = ServicosViewModel();
    final servicos = viewModel.servicos;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF28669b), Color(0xFF3FA9F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botão de voltar
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => context.go('/'), // volta pra home
                  ),

                  // Título
                  const Text(
                    'Sala Girassol',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  // Ícone
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(FontAwesomeIcons.venus, size: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: servicos.length,
        itemBuilder: (context, index) {
          return ServicoCard(servico: servicos[index]);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integra_app/presentation/widgets/common/smooth_animations.dart';
import 'package:integra_app/presentation/widgets/home/access_grid_widget.dart';
import 'package:integra_app/presentation/widgets/home/category_list_widget.dart';
import 'package:integra_app/presentation/widgets/common/section_title_widget.dart';
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:provider/provider.dart';

/// ✅ MVVM: Widget separado para o conteúdo principal da home
/// Exibe conteúdo padrão (busca agora está integrada no WelcomeSectionWidget)
/// Usa Consumer para reatividade
class HomeContentWidget extends StatelessWidget {
  const HomeContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textDark = const Color(0xFF263860);

    // ✅ Busca agora está integrada no WelcomeSectionWidget
    // Aqui exibimos apenas o conteúdo padrão
    return StaggeredFadeIn(
      children: [
        // Seção Mais Acessados
        SmoothFadeIn(
          delay: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitleWidget(
                title: "Mais acessados",
                color: textDark,
                icon: FontAwesomeIcons.chartLine,
              ),
              const AccessGridWidget(),
            ],
          ),
        ),

        // Seção Categorias
        SmoothFadeIn(
          delay: const Duration(milliseconds: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<HomeViewModel>(
                builder: (context, homeVM, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitleWidget(
                        title: "Categorias",
                        subtitle: homeVM.isOffline ? "Modo Offline - Dados locais" : null,
                        color: textDark,
                        icon: FontAwesomeIcons.tableCellsLarge,
                      ),
                      CategoryListWidget(homeVM: homeVM),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

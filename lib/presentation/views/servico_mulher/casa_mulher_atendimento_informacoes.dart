import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/viewmodels/mulher_viewmodel/casa_mulher_info_atendimento_especializado_viewmodel.dart';
import 'package:provider/provider.dart';


class CasaMulherInformacaoatendimentoEspecializado extends StatelessWidget {
  const CasaMulherInformacaoatendimentoEspecializado({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CasaMulherInfoAtendimentoEspecializadoViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF28669b), Color(0xFF3FA9F5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => context.go(vm.backRoute),
                    ),
                    Text(
                      vm.pageTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.sentiment_very_satisfied,
                        color: Color(0xFF3F4E63),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(vm.subtitle, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  vm.lastModifiedLabel,
                  style: TextStyle(
                    color:
                        isDark ? Colors.green.shade300 : Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ...vm.sections.map((secao) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: Colors.blue, width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      iconColor:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      collapsedIconColor:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      title: Text(
                        secao.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(
                            secao.content,
                            style: TextStyle(
                              color: isDark
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

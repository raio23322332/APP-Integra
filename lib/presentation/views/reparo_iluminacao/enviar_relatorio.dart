import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/presentation/viewmodels/repair_request_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/app_loader.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Necessário para File()
import 'package:flutter/widgets.dart'; // Necessário para Image.file

// Cores padrão do módulo Reparo de Iluminação
const Color primaryBlue = Color(0xFF28669b);
const Color lightBlue = Color(0xFF3FA9F5);
const Color backgroundLight = Color(0xFFF6F7F8);
const Color backgroundDark = Color(0xFF101922);
const Color surfaceLight = Colors.white;
const Color surfaceDark = Color(0xFF1F2937);

class ProblemTag extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const ProblemTag({
    super.key,
    required this.text,
    this.isSelected = false,
    required this.isDarkMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? (isDarkMode ? Colors.white : primaryBlue)
        : (isDarkMode ? const Color(0xFFC7D2E2) : const Color(0xFF334155));
    final Color backgroundColor = isSelected
        ? primaryBlue.withOpacity(0.15)
        : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 40,
          minWidth: 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  late RepairRequestViewModel _vm;
  StreamSubscription? _eventSubscription;
  static const List<String> _problems = [
    'Lâmpada queimada',
    'Poste danificado',
    'Luz piscando',
    'Fiação exposta',
  ];

  bool _locationSet = false;

  @override
  void initState() {
    super.initState();

    // Obtém a instância do ViewModel
    _vm = Provider.of<RepairRequestViewModel>(context, listen: false);

    // Escuta os eventos do ViewModel
    _eventSubscription = _vm.events.listen(_handleEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_locationSet) {
      final uri = GoRouterState.of(context).uri;
      final lat = double.tryParse(uri.queryParameters['lat'] ?? '');
      final lng = double.tryParse(uri.queryParameters['lng'] ?? '');

      if (lat != null && lng != null) {
        Provider.of<RepairRequestViewModel>(
          context,
          listen: false,
        ).setLocation(lat, lng);
        _locationSet = true;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _handleEvent(ViewModelEvent event) {
    if (!mounted) return;

    if (event is NavigationEvent) {
      context.go(event.route);
    } else if (event is ShowSnackBarEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.message),
          backgroundColor: event.isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RepairRequestViewModel>();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color surfaceColor = isDarkMode ? surfaceDark : surfaceLight;
    final Color backgroundColor = isDarkMode ? backgroundDark : backgroundLight;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Reportar Problema',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Evita erro de pop quando não há páginas
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go(
                '/iluminacao-lugar',
              ); // Rota segura caso seja a primeira tela
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Qual o problema com a iluminação?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Selecione o tipo de problema',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? const Color(0xFFC7D2E2)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxWidth: double.infinity),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _problems
                      .map(
                        (problem) => ProblemTag(
                          text: problem,
                          isSelected: vm.selectedProblem == problem,
                          isDarkMode: isDarkMode,
                          onTap: () => vm.selectProblem(problem),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Descrição Detalhada (Opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode
                      ? const Color(0xFFC7D2E2)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                onChanged: vm.setDescription,
                maxLines: 6,
                minLines: 4,
                decoration: InputDecoration(
                  hintText: 'Adicione detalhes, pontos de referência...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),

              if (vm.errorMessage != null)
                Text(
                  vm.errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 12),
              const SizedBox(height: 24),

              Text(
                'Adicionar Foto ou Vídeo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode
                      ? const Color(0xFFC7D2E2)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  GestureDetector(
                    onTap: vm.pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: vm.imagePath != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(vm.imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: vm.clearImage,
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                                size: 28,
                              ),
                            ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.videocam, color: Colors.grey, size: 28),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF475569)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_photo_alternate,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: surfaceColor,
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: vm.isLoading
                ? null
                : () {
                    vm.setDescription(
                      _descriptionController.text,
                    ); // Garante que a descrição mais recente seja salva
                    vm.submitRequest();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: vm.isLoading
                ? const AppLoader()
                : const Text(
                    'Enviar Relatório',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}

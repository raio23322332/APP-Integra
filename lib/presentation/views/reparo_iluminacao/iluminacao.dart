import 'package:flutter/material.dart';
import 'package:integra_app/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:integra_app/data/models/accordion_item_model.dart';
import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/viewmodels/iluminacao/iluminacao_viewmodel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';





// Definição das cores base
const Color primaryBlue = Color(0xFF28669b);
const Color lightBlue = Color(0xFF3FA9F5);
const Color secondaryGreen = Color(0xFF4b8c40);
const Color darkText = Color(0xFF263860);
const Color lightBackground = Color(0xFFf6f8f6);

class RepairRequestScreen extends StatefulWidget {
  const RepairRequestScreen({super.key});

  @override
  State<RepairRequestScreen> createState() => _RepairRequestScreenState();
}

class _RepairRequestScreenState extends State<RepairRequestScreen> {
  /// ✅ Estado do accordion fica na View (isso é UI state, OK)
  int _expandedIndex = 0; // começa com o primeiro aberto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderContent(context),
            _buildDetailsContainer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white, // Deixa o título branco
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text('Reparo de Iluminação'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(FontAwesomeIcons.lightbulb, size: 24, color: Colors.white), // Ícone de iluminação no canto direito
        ),
      ],
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solicitar reparo na iluminação pública',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: darkText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.SolicitacaoView, extra: {
                'tipo': 'Iluminação Pública',
                'slug': 'iluminacao-publica'
              }),
              icon: const Icon(FontAwesomeIcons.handPointRight, size: 20),
              label: const Text(
                'Iniciar Serviço',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Última atualização: 26/10/2025',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContainer() {
    final List<AccordionItemModel> data = iluminacaoAccordionData;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        materialGapSize: 0,
        animationDuration: const Duration(milliseconds: 300),
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _expandedIndex = isExpanded ? -1 : index;
          });
        },
        children: List.generate(data.length, (index) {
          final item = data[index];
          final isExpanded = _expandedIndex == index;

          return ExpansionPanel(
            backgroundColor: Colors.white,
            isExpanded: isExpanded,
            headerBuilder: (context, _) => _accordionHeader(item),
            body: _accordionBody(item),
          );
        }),
      ),
    );
  }

  Widget _accordionHeader(AccordionItemModel item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.header,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accordionBody(AccordionItemModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Text(
        item.body,
        style: TextStyle(
          fontSize: 14,
          color: darkText.withOpacity(0.8),
          height: 1.6,
        ),
      ),
    );
  }
}

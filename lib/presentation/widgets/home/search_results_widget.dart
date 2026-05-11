import 'package:flutter/material.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/presentation/viewmodels/home/home_viewmodel.dart';
import 'package:integra_app/presentation/widgets/common/section_title_widget.dart';
import 'package:integra_app/utils/service_type_formatter.dart';

/// ✅ MVVM: Widget separado para resultados de busca
/// Centraliza lógica de UI, remove código da View principal
class SearchResultsWidget extends StatelessWidget {
  final List<models.Service> services;
  final HomeViewModel homeVM;

  const SearchResultsWidget({
    super.key,
    required this.services,
    required this.homeVM,
  });

  @override
  Widget build(BuildContext context) {
    final textDark = const Color(0xFF263860);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitleWidget(title: "Resultados da Busca", color: textDark),
          const SizedBox(height: 10),
          ...services.map((service) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.miscellaneous_services,
                  color: Color(0xFF28669b),
                ),
                title: Text(service.title),
                subtitle: Text('Tipo: ${ServiceTypeFormatter.formatServiceType(service.type)}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  homeVM.onSearchResultTapped(service);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

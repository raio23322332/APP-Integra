import 'package:flutter/material.dart';
import '../../../core/models/estado_model.dart';
import '../../../core/models/cidade_model.dart';

class SelectionModal<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) getItemName;
  final ValueChanged<T?> onItemSelected;
  final String searchHint;

  const SelectionModal({
    super.key,
    required this.title,
    required this.items,
    required this.getItemName,
    required this.onItemSelected,
    this.searchHint = 'Buscar...',
  });

  @override
  State<SelectionModal<T>> createState() => _SelectionModalState<T>();
}

class _SelectionModalState<T> extends State<SelectionModal<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        final itemName = widget.getItemName(item).toLowerCase();
        return itemName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Campo de busca
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: widget.searchHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            // Lista com scroll
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 6,
                radius: const Radius.circular(6),
                child: ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return ListTile(
                      title: Text(widget.getItemName(item)),
                      onTap: () {
                        widget.onItemSelected(item);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Métodos utilitários para mostrar os modais
class ModalHelper {
  static void showEstadoModal(
    BuildContext context, {
    required List<Estado> estados,
    required ValueChanged<Estado?> onEstadoSelected,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SelectionModal<Estado>(
          title: 'Selecione estado',
          items: estados,
          getItemName: (estado) => '${estado.sigla} - ${estado.nome}',
          onItemSelected: onEstadoSelected,
          searchHint: 'Buscar estado...',
        );
      },
    );
  }

  static void showCidadeModal(
    BuildContext context, {
    required List<Cidade> cidades,
    required ValueChanged<Cidade?> onCidadeSelected,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SelectionModal<Cidade>(
          title: 'Selecione cidade',
          items: cidades,
          getItemName: (cidade) => cidade.nome,
          onItemSelected: onCidadeSelected,
          searchHint: 'Buscar cidade...',
        );
      },
    );
  }
}

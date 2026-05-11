import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:integra_app/presentation/viewmodels/iluminacao/iluminacao_viewmodel_map.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:provider/provider.dart';

// Cores padrão do módulo Reparo de Iluminação
const Color primaryBlue = Color(0xFF28669b);
const Color lightBlue = Color(0xFF3FA9F5);
const Color backgroundLight = Color(0xFFF6F7F8);
const Color backgroundDark = Color(0xFF101922); 
const Color textDark = Color(0xFF1F2937);

class LocationSelectorScreen extends StatelessWidget {
  final bool isDarkMode;

  const LocationSelectorScreen({super.key, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<IluminacaoViewModel>(context);

    final Color currentBackgroundColor =
        isDarkMode ? backgroundDark : backgroundLight;
    final Color currentSurfaceColor =
        isDarkMode ? const Color(0xFF27323F) : Colors.white;
    final Color currentTextColor = isDarkMode ? Colors.white : textDark;
    final Color currentIconColor =
        isDarkMode ? Colors.white : const Color(0xFF4B5563);

    return EventSubscriber(
      viewModel: viewModel,
      child: Scaffold(
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
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
          ),
          title: const Center(
            child: Text(
              'Onde fica o problema?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          actions: const [SizedBox(width: 56)],
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: viewModel.mapController,
              options: MapOptions(
                initialCenter: viewModel.selectedLocation,
                initialZoom: 13.0,
                onPositionChanged: (position, hasGesture) {
                  viewModel.onMapMoved(position);
                },
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.example.app',
                ),
              ],
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 50,
                      color: Color(0xFFFACC15),
                      shadows: [
                        BoxShadow(color: Colors.black54, blurRadius: 4)
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Consumer<IluminacaoViewModel>(
              builder: (context, viewModel, child) {
                return Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: currentSurfaceColor.withOpacity(
                        0.9,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: viewModel.searchController,
                              style: TextStyle(color: currentTextColor),
                              decoration: InputDecoration(
                                hintText: viewModel.searchController.text.isEmpty
                                    ? 'Ex: Brasília, Rua X, Avenida Y...'
                                    : 'Buscar endereço, rua, cidade...',
                                hintStyle: TextStyle(
                                  color: currentIconColor.withOpacity(0.7),
                                ),
                                prefixIcon: Icon(Icons.search, color: currentIconColor),
                                suffixIcon: viewModel.searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear, color: currentIconColor),
                                        onPressed: viewModel.clearSearch,
                                      )
                                    : viewModel.isSearching
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(currentIconColor),
                                            ),
                                          )
                                        : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (value) => viewModel.onSearchQueryChanged(value),
                              onSubmitted: (value) {
                                if (viewModel.searchResults.isNotEmpty) {
                                  viewModel.selectSearchResult(viewModel.searchResults.first);
                                }
                              },
                            ),
                            if (viewModel.searchQuery.isNotEmpty && !viewModel.isSearching)
                              Padding(
                                padding: const EdgeInsets.only(left: 16, top: 4),
                                child: Text(
                                  'Buscando: "${viewModel.searchQuery}"',
                                  style: TextStyle(
                                    color: currentIconColor.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (viewModel.searchResults.isNotEmpty)
                          Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: currentSurfaceColor.withOpacity(0.95),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: viewModel.searchResults.length,
                              itemBuilder: (context, index) {
                                final result = viewModel.searchResults[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    result.displayName,
                                    style: TextStyle(
                                      color: currentTextColor,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => viewModel.selectSearchResult(result),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 24,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    onPressed: viewModel.goToCurrentLocation,
                    backgroundColor: currentSurfaceColor,
                    foregroundColor: currentIconColor,
                    elevation: 6,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: currentBackgroundColor,
            border: Border(
              top: BorderSide(
                color: isDarkMode
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
              ),
            ),
          ),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: viewModel.onConfirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Confirmar Localização'),
            ),
          ),
        ),
      ),
    );
  }
}

class EventSubscriber extends StatefulWidget {
  final IluminacaoViewModel viewModel;
  final Widget child;

  const EventSubscriber(
      {super.key, required this.viewModel, required this.child});

  @override
  State<EventSubscriber> createState() => _EventSubscriberState();
}

class _EventSubscriberState extends State<EventSubscriber> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.viewModel.events.listen((event) {
      if (event is ShowSnackBarEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message),
            backgroundColor: event.isError ? Colors.red : null,
          ),
        );
      } else if (event is NavigationEvent) {
        context.go(event.route, extra: event.extra);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:integra_app/presentation/routes/app_router.dart';
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:latlong2/latlong.dart';

class SearchResult {
  final String displayName;
  final LatLng latLng;
  final String type;
  final String category;

  SearchResult({
    required this.displayName,
    required this.latLng,
    required this.type,
    required this.category,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      displayName: json['display_name'] ?? '',
      latLng: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
      type: json['type'] ?? '',
      category: json['class'] ?? '',
    );
  }
}

class IluminacaoViewModel extends ChangeNotifier {
  final _mapController = MapController();
  MapController get mapController => _mapController;

  LatLng _selectedLocation = const LatLng(-15.7801, -47.9292);
  LatLng get selectedLocation => _selectedLocation;

  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  bool _disposed = false;

  // Search properties
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounceTimer;
  final Map<String, List<SearchResult>> _searchCache = {};

  String get searchQuery => _searchQuery;
  List<SearchResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void onMapMoved(MapPosition position) {
    _selectedLocation = position.center!;
    notifyListeners();
  }

  Future<void> goToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _eventController
          .add(const ShowSnackBarEvent('Serviços de localização desabilitados.', isError: true));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _eventController.add(const ShowSnackBarEvent('Permissão de localização negada.', isError: true));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _eventController.add(const ShowSnackBarEvent(
          'Permissão de localização negada permanentemente. Por favor, habilite nas configurações do seu dispositivo.',
          isError: true));
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );

      _mapController.move(currentLatLng, 15.0);

      _selectedLocation = currentLatLng;
      notifyListeners();
    } catch (e) {
      _eventController.add(ShowSnackBarEvent('Não foi possível obter sua localização: $e', isError: true));
    }
  }

  // Search methods
  void onSearchQueryChanged(String query) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      searchPlaces(query);
    });
  }

  Future<void> searchPlaces(String query) async {
    if (_disposed) return;

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      _isSearching = false;
      notifyListeners();
      return;
    }

    // Check cache first
    if (_searchCache.containsKey(trimmedQuery)) {
      _searchQuery = trimmedQuery;
      _searchResults = _searchCache[trimmedQuery]!;
      _isSearching = false;
      notifyListeners();
      return;
    }

    _searchQuery = trimmedQuery;
    _isSearching = true;
    _searchResults = [];
    notifyListeners();

    try {
      // Usar o pacote geocoding do Flutter para busca mais profissional
      List<Location> locations = [];

      // Tentar busca direta primeiro
      try {
        locations = await locationFromAddress(trimmedQuery);
      } catch (e) {
        // Se falhar, tentar variações
        final searchVariations = _generateSearchVariations(trimmedQuery);

        for (final variation in searchVariations) {
          if (_disposed) return;

          try {
            final variationLocations = await locationFromAddress(variation);
            locations.addAll(variationLocations);
            if (locations.length >= 10) break; // Limitar resultados
          } catch (e) {
            // Ignorar variações que falharem
            continue;
          }
        }
      }

      // Converter para SearchResult
      final searchResults = locations.take(25).map((location) {
        return SearchResult(
          displayName: trimmedQuery, // O geocoding não retorna nome detalhado
          latLng: LatLng(location.latitude, location.longitude),
          type: 'address',
          category: 'geocoding',
        );
      }).toList();

      // Remover duplicatas e ordenar por relevância
      _searchResults = _removeDuplicateResults(searchResults);

      // Tentar obter nomes mais detalhados usando placemarkFromCoordinates
      if (_searchResults.isNotEmpty) {
        final detailedResults = <SearchResult>[];

        for (final result in _searchResults.take(10)) {
          try {
            final placemarks = await placemarkFromCoordinates(
              result.latLng.latitude,
              result.latLng.longitude,
            );

            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              final detailedName = [
                placemark.street,
                placemark.subLocality,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country,
              ].where((part) => part != null && part.isNotEmpty).join(', ');

              detailedResults.add(SearchResult(
                displayName: detailedName.isNotEmpty ? detailedName : trimmedQuery,
                latLng: result.latLng,
                type: placemark.locality != null ? 'city' : 'address',
                category: 'geocoding',
              ));
            } else {
              detailedResults.add(result);
            }
          } catch (e) {
            detailedResults.add(result);
          }
        }

        _searchResults = detailedResults;
      }

      // Cache the results
      _searchCache[trimmedQuery] = _searchResults;

      if (_searchResults.isEmpty) {
        _eventController.add(const ShowSnackBarEvent('Nenhum local encontrado. Tente uma busca diferente.', isError: false));
      }
    } catch (e) {
      _eventController.add(ShowSnackBarEvent('Erro de geocoding: $e', isError: true));
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Gera variações da busca para aumentar as chances de encontrar resultados
  List<String> _generateSearchVariations(String query) {
    final variations = <String>[];
    final lowerQuery = query.toLowerCase().trim();

    // Adicionar a busca original SEMPRE
    variations.add(query);

    // Se for apenas uma palavra, tentar diferentes combinações
    final words = lowerQuery.split(' ');
    if (words.length == 1) {
      final word = words[0];

      // Priorizar busca como cidade/estado primeiro
      variations.add('$word, Brasil');
      variations.add('cidade $word');
      variations.add('$word, PI'); // Piauí (Teresina)
      variations.add('$word, CE'); // Ceará
      variations.add('$word, PE'); // Pernambuco
      variations.add('$word, BA'); // Bahia
      variations.add('$word, PR'); // Paraná
      variations.add('$word, SC'); // Santa Catarina
      variations.add('$word, GO'); // Goiás
      variations.add('$word, MT'); // Mato Grosso
      variations.add('$word, MS'); // Mato Grosso do Sul
      variations.add('$word, ES'); // Espírito Santo
      variations.add('$word, RN'); // Rio Grande do Norte
      variations.add('$word, PB'); // Paraíba
      variations.add('$word, AL'); // Alagoas
      variations.add('$word, SE'); // Sergipe
      variations.add('$word, TO'); // Tocantins
      variations.add('$word, RO'); // Rondônia
      variations.add('$word, AC'); // Acre
      variations.add('$word, AM'); // Amazonas
      variations.add('$word, RR'); // Roraima
      variations.add('$word, AP'); // Amapá
      variations.add('$word, PA'); // Pará
      variations.add('$word, MA'); // Maranhão

      // Depois tentar como rua/bairro em capitais
      variations.add('rua $word');
      variations.add('avenida $word');
      variations.add('praça $word');
      variations.add('$word, Brasília');
      variations.add('$word, São Paulo');
      variations.add('$word, Rio de Janeiro');
      variations.add('$word, Salvador');
      variations.add('$word, Belo Horizonte');
      variations.add('$word, Curitiba');
      variations.add('$word, Porto Alegre');
    } else if (words.length >= 2) {
      // Para múltiplas palavras, tentar rearranjos mais abrangentes
      variations.add('$lowerQuery, Brasil');
      variations.add('$lowerQuery, PI'); // Piauí
      variations.add('$lowerQuery, CE'); // Ceará
      variations.add('$lowerQuery, PE'); // Pernambuco
      variations.add('$lowerQuery, BA'); // Bahia
      variations.add('$lowerQuery, Brasília');
      variations.add('$lowerQuery, São Paulo');
      variations.add('$lowerQuery, Rio de Janeiro');
      variations.add('rua $lowerQuery');
      variations.add('avenida $lowerQuery');
      variations.add('praça $lowerQuery');
    }

    // Limitar variações para não fazer muitas chamadas, mas permitir mais
    return variations.take(8).toList();
  }

  // Remove resultados duplicados baseados em proximidade das coordenadas
  List<SearchResult> _removeDuplicateResults(List<SearchResult> results) {
    final uniqueResults = <SearchResult>[];
    const double threshold = 0.001; // ~100 metros

    for (final result in results) {
      bool isDuplicate = false;

      for (final existing in uniqueResults) {
        final distance = (result.latLng.latitude - existing.latLng.latitude).abs() +
                        (result.latLng.longitude - existing.latLng.longitude).abs();

        if (distance < threshold) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        uniqueResults.add(result);
      }
    }

    return uniqueResults;
  }

  void selectSearchResult(SearchResult result) {
    _selectedLocation = result.latLng;
    _mapController.move(result.latLng, 16.0);
    _searchResults = [];
    searchController.text = result.displayName;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    searchController.clear();
    notifyListeners();
  }

  void onConfirmLocation() {
    final locationData = {
      'lat': _selectedLocation.latitude.toString(),
      'lng': _selectedLocation.longitude.toString(),
    };

    _eventController.add(
      NavigationEvent(
        '${AppRoutes.formulario_iluminacao}?lat=${locationData['lat']}&lng=${locationData['lng']}',
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _searchDebounceTimer?.cancel();
    _eventController.close();
    searchController.dispose();
    super.dispose();
  }
}

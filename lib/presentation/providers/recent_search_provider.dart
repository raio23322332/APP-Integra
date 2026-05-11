import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:integra_app/core/models/recent_search_model.dart';

class RecentSearchProvider extends ChangeNotifier {
  static const String _storageKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<RecentSearch> _recentSearches = [];
  List<String> _suggestions = [];

  List<RecentSearch> get recentSearches => List.unmodifiable(_recentSearches);
  List<String> get suggestions => List.unmodifiable(_suggestions);

  RecentSearchProvider() {
    _loadRecentSearches();
    _loadSuggestions();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final searchesJson = await _storage.read(key: _storageKey);
      debugPrint('Loading recent searches from storage: $searchesJson');

      if (searchesJson != null && searchesJson.isNotEmpty) {
        final List<dynamic> searchesList = jsonDecode(searchesJson);
        _recentSearches = searchesList
            .map((json) => RecentSearch.fromJson(json))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        debugPrint('Loaded ${_recentSearches.length} recent searches');
      } else {
        _recentSearches = [];
        debugPrint('No recent searches found in storage');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
      _recentSearches = [];
      notifyListeners();
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      final searchesJson = jsonEncode(
        _recentSearches.map((search) => search.toJson()).toList(),
      );

      await _storage.write(key: _storageKey, value: searchesJson);
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  void _loadSuggestions() {
    // No hardcoded suggestions - only recent searches will be shown
    _suggestions = [];
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    debugPrint('Adding recent search: "$query"');

    final normalizedQuery = query.trim().toLowerCase();

    // Check if search already exists
    final existingIndex = _recentSearches.indexWhere(
      (search) => search.query.toLowerCase() == normalizedQuery,
    );

    if (existingIndex != -1) {
      // Update existing search
      final existing = _recentSearches[existingIndex];
      _recentSearches[existingIndex] = existing.copyWith(
        timestamp: DateTime.now(),
        searchCount: existing.searchCount + 1,
      );
      debugPrint('Updated existing search at index $existingIndex');
    } else {
      // Add new search
      _recentSearches.insert(
        0,
        RecentSearch(
          query: query.trim(),
          timestamp: DateTime.now(),
        ),
      );

      // Keep only the most recent searches
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }
      debugPrint('Added new search. Total searches: ${_recentSearches.length}');
    }

    // Re-sort by timestamp and search count
    _recentSearches.sort((a, b) {
      final timeCompare = b.timestamp.compareTo(a.timestamp);
      if (timeCompare != 0) return timeCompare;
      return b.searchCount.compareTo(a.searchCount);
    });

    await _saveRecentSearches();
    notifyListeners();
    debugPrint('Recent search saved and UI notified');
  }

  Future<void> removeRecentSearch(String query) async {
    _recentSearches.removeWhere((search) => search.query == query);
    await _saveRecentSearches();
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    debugPrint('Clearing recent searches...');
    _recentSearches.clear();
    await _saveRecentSearches();
    notifyListeners();
    debugPrint('Recent searches cleared successfully');
  }

  List<String> getFilteredSuggestions(String query) {
    if (query.isEmpty) return suggestions;

    final queryLower = query.toLowerCase();
    return suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(queryLower))
        .toList();
  }
}

import 'package:flutter/material.dart';
import 'package:integra_app/core/models/breadcrumb_model.dart';

class BreadcrumbProvider extends ChangeNotifier {
  final List<BreadcrumbItem> _breadcrumbs = [];

  List<BreadcrumbItem> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  void setBreadcrumbs(List<BreadcrumbItem> items) {
    _breadcrumbs.clear();
    _breadcrumbs.addAll(items);
    notifyListeners();
  }

  void addBreadcrumb(BreadcrumbItem item) {
    _breadcrumbs.add(item);
    notifyListeners();
  }

  void removeLast() {
    if (_breadcrumbs.isNotEmpty) {
      _breadcrumbs.removeLast();
      notifyListeners();
    }
  }

  void clear() {
    _breadcrumbs.clear();
    notifyListeners();
  }

  void navigateToBreadcrumb(BreadcrumbItem item) {
    final index = _breadcrumbs.indexOf(item);
    if (index != -1) {
      _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);
      notifyListeners();
    }
  }

  // API integration methods
  Future<void> sendBreadcrumbToApi() async {
    // TODO: Implement API call to send breadcrumb path
    // This could be called when navigating or at certain points
    final breadcrumbData = _breadcrumbs.map((b) => b.toJson()).toList();
    // Send to API endpoint
    debugPrint('Sending breadcrumbs to API: $breadcrumbData');
  }
}

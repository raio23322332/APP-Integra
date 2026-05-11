import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:integra_app/data/models/category_model.dart' as models;
import 'package:integra_app/presentation/widgets/shared/view_model_event.dart';
import 'package:integra_app/services/storage/domain_storage.dart';
import 'package:integra_app/utils/html_text_extractor.dart';
import 'package:integra_app/utils/service_type_formatter.dart';

/// Regra de domínio: canal do serviço (digital/semi/não-digital)
enum ServiceChannel { digital, semiDigital, nonDigital, unknown }

/// Conteúdo processado das seções
enum ProcessedSectionContentType { text, steps, unavailable }

class SectionSteps {
  final List<String> online;
  final List<String> presencial;

  const SectionSteps({
    this.online = const [],
    this.presencial = const [],
  });
}

class ProcessedSectionContent {
  final ProcessedSectionContentType type;
  final String? textContent;
  final SectionSteps? stepsContent;

  const ProcessedSectionContent.text(this.textContent)
      : type = ProcessedSectionContentType.text,
        stepsContent = null;

  const ProcessedSectionContent.steps(this.stepsContent)
      : type = ProcessedSectionContentType.steps,
        textContent = null;

  const ProcessedSectionContent.unavailable()
      : type = ProcessedSectionContentType.unavailable,
        textContent = null,
        stepsContent = null;
}

class ServiceDetailViewModel extends ChangeNotifier {
  final DomainStorage _domainStorage;
  final models.Service _service;

  ServiceDetailViewModel({
    required DomainStorage domainStorage,
    required models.Service service,
  })  : _domainStorage = domainStorage,
        _service = service;

  // -------------------------
  // Events (para View reagir)
  // -------------------------
  final _eventController = StreamController<ViewModelEvent>.broadcast();
  Stream<ViewModelEvent> get events => _eventController.stream;

  void _emit(ViewModelEvent event) {
    if (!_eventController.isClosed) _eventController.add(event);
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }

  models.Service get service => _service;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // -------------------------
  // LÓGICA DE NEGÓCIO (DOMÍNIO)
  // -------------------------

  ServiceChannel get channel => ServiceTypeFormatter.parseChannel(_service.type);

  bool get canOpenWeb => channel != ServiceChannel.nonDigital;

  String formatServiceType(String type) {
    return ServiceTypeFormatter.formatServiceType(type);
  }

  String formatCost(dynamic cost) {
    if (cost == null) return "R\$ 0,00";
    if (cost is num) return "R\$ ${cost.toDouble().toStringAsFixed(2)}";

    if (cost is String) {
      final trimmed = cost.trim();
      if (trimmed.isEmpty) return "R\$ 0,00";
      return "R\$ $trimmed";
    }

    return "R\$ 0,00";
  }

  String formatLastUpdate(DateTime lastUpdate) {
    final d = lastUpdate.toLocal();
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "$yyyy-$mm-$dd";
  }

  ProcessedSectionContent processSectionContent(dynamic content) {
    if (content is String) {
      // Extrai texto puro do HTML antes de retornar
      String cleanText = extractTextFromHtml(content);
      return ProcessedSectionContent.text(cleanText);
    }

    if (content is Map) {
      final presencial = (content['presencial'] as List<dynamic>?)
              ?.map((e) => extractTextFromHtml(e.toString())) // Extrai HTML dos itens também
              .toList() ??
          const <String>[];
      final online = (content['online'] as List<dynamic>?)
              ?.map((e) => extractTextFromHtml(e.toString())) // Extrai HTML dos itens também
              .toList() ??
          const <String>[];
      return ProcessedSectionContent.steps(
        SectionSteps(online: online, presencial: presencial),
      );
    }

    return const ProcessedSectionContent.unavailable();
  }

  // -------------------------
  // AÇÃO DE NEGÓCIO: abrir web (diretamente)
  // -------------------------
  Future<Map<String, String>?> openOnWeb() async {
    // regra de domínio
    if (!canOpenWeb) {
      return null; // Retorna null para indicar que não pode abrir
    }

    if (_isLoading) return null;

    _setLoading(true);
    try {
      final url = await _buildServiceUrl(_service.id.toString());

      if (url == null) {
        return null; // Não conseguiu construir URL
      }

      // Retorna os dados diretamente para a View
      return {
        'title': _service.title,
        'url': url,
      };
    } catch (_) {
      return null; // Erro ao abrir
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> _buildServiceUrl(String serviceId) async {
    final tenant = await _domainStorage.getSelectedTenant();
    if (tenant == null) return null;

    final domain = tenant.devDomain ?? tenant.primaryDomain ?? tenant.urlSubdomainBase;
    if (domain == null || domain.trim().isEmpty) return null;

    final uri = Uri(
      scheme: 'https',
      host: domain,
      path: 'serviços/$serviceId',
    );

    return uri.toString();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

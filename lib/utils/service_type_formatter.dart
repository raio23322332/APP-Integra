import '../presentation/viewmodels/categorias_e_servicos/service_detail_viewmodel.dart';

/// Utilitário para formatação de tipos de serviço
class ServiceTypeFormatter {
  static String formatServiceType(String type) {
    final t = type.toLowerCase().trim();
    
    if (t.contains('no-digital') || t.contains('não digital') || t.contains('nao digital') || t.contains('non-digital')) {
      return "Não Digital";
    }
    if (t.contains('semi digital') || t.contains('semi-digital')) {
      return "Parcialmente Digital";
    }
    if (t.contains('digital')) {
      return "Digital";
    }
    return type; // Retorna original se não reconhecer
  }

  static ServiceChannel parseChannel(String type) {
    final t = type.toLowerCase().trim();

    if (t.contains('no-digital') || t.contains('não digital') || t.contains('nao digital')|| t.contains('non-digital')) {
      return ServiceChannel.nonDigital;
    }
    if (t.contains('semi digital') || t.contains('semi-digital')) {
      return ServiceChannel.semiDigital;
    }
    if (t.contains('digital')) {
      return ServiceChannel.digital;
    }
    return ServiceChannel.unknown;
  }
}

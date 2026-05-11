/// Função para extrair texto puro de tags HTML
String extractTextFromHtml(String htmlContent) {
  if (htmlContent.isEmpty) return '';
  
  // Remove todas as tags HTML, mantendo apenas o texto
  String cleanText = htmlContent
      .replaceAll(RegExp(r'<[^>]*>'), '') // Remove tags como <p>, <ul>, <li>, etc.
      .replaceAll(RegExp(r'&nbsp;'), ' ') // Espaços não quebráveis
      .replaceAll(RegExp(r'&lt;'), '<')   // Símbolo <
      .replaceAll(RegExp(r'&gt;'), '>')   // Símbolo >
      .replaceAll(RegExp(r'&amp;'), '&')   // Símbolo &
      .replaceAll(RegExp(r'&quot;'), '"') // Aspas
      .replaceAll(RegExp(r'&#39;'), "'")  // Apóstrofo
      .replaceAll(RegExp(r'\s+'), ' ')     // Remove espaços extras
      .trim();
  
  return cleanText;
}

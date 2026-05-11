class AccordionItem {
  final String id;
  final String title;
  final String content;
  final String iconCode; // Código do ícone FontAwesome
  
  const AccordionItem({
    required this.id,
    required this.title,
    required this.content,
    required this.iconCode,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccordionItem &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}
class BreadcrumbItem {
  final String title;
  final String? route;
  final dynamic extra;

  const BreadcrumbItem({
    required this.title,
    this.route,
    this.extra,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'route': route,
        'extra': extra,
      };

  factory BreadcrumbItem.fromJson(Map<String, dynamic> json) => BreadcrumbItem(
        title: json['title'],
        route: json['route'],
        extra: json['extra'],
      );
}

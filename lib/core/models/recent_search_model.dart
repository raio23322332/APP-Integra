class RecentSearch {
  final String query;
  final DateTime timestamp;
  final int searchCount;

  const RecentSearch({
    required this.query,
    required this.timestamp,
    this.searchCount = 1,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'timestamp': timestamp.toIso8601String(),
        'searchCount': searchCount,
      };

  factory RecentSearch.fromJson(Map<String, dynamic> json) => RecentSearch(
        query: json['query'],
        timestamp: DateTime.parse(json['timestamp']),
        searchCount: json['searchCount'] ?? 1,
      );

  RecentSearch copyWith({
    String? query,
    DateTime? timestamp,
    int? searchCount,
  }) {
    return RecentSearch(
      query: query ?? this.query,
      timestamp: timestamp ?? this.timestamp,
      searchCount: searchCount ?? this.searchCount,
    );
  }
}

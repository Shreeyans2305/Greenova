import 'package:hive/hive.dart';

part 'search_history_model.g.dart';

@HiveType(typeId: 3)
class SearchHistoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String query;

  @HiveField(2)
  final String searchType;

  @HiveField(3)
  final DateTime searchedAt;

  @HiveField(4)
  final String? reportId;

  SearchHistoryItem({
    required this.id,
    required this.query,
    required this.searchType,
    required this.searchedAt,
    this.reportId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'query': query,
    'searchType': searchType,
    'searchedAt': searchedAt.toIso8601String(),
    'reportId': reportId,
  };

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id'] as String,
      query: json['query'] as String,
      searchType: json['searchType'] as String,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
      reportId: json['reportId'] as String?,
    );
  }
}

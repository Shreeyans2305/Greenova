import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final double totalCarbonFootprint;

  @HiveField(3)
  final int totalPurchases;

  @HiveField(4)
  final int totalScans;

  @HiveField(5)
  final List<String> achievements;

  @HiveField(6)
  final String footprintLevel;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime lastUpdatedAt;

  UserProfile({
    required this.id,
    this.name,
    required this.totalCarbonFootprint,
    required this.totalPurchases,
    required this.totalScans,
    required this.achievements,
    required this.footprintLevel,
    required this.createdAt,
    required this.lastUpdatedAt,
  });

  factory UserProfile.initial() {
    final now = DateTime.now();
    return UserProfile(
      id: 'user_1',
      name: null,
      totalCarbonFootprint: 0,
      totalPurchases: 0,
      totalScans: 0,
      achievements: [],
      footprintLevel: 'Low',
      createdAt: now,
      lastUpdatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalCarbonFootprint': totalCarbonFootprint,
    'totalPurchases': totalPurchases,
    'totalScans': totalScans,
    'achievements': achievements,
    'footprintLevel': footprintLevel,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      totalCarbonFootprint: (json['totalCarbonFootprint'] as num).toDouble(),
      totalPurchases: json['totalPurchases'] as int,
      totalScans: json['totalScans'] as int,
      achievements: List<String>.from(json['achievements'] ?? []),
      footprintLevel: json['footprintLevel'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    double? totalCarbonFootprint,
    int? totalPurchases,
    int? totalScans,
    List<String>? achievements,
    String? footprintLevel,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      totalCarbonFootprint: totalCarbonFootprint ?? this.totalCarbonFootprint,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalScans: totalScans ?? this.totalScans,
      achievements: achievements ?? this.achievements,
      footprintLevel: footprintLevel ?? this.footprintLevel,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  UserProfile addPurchase(double carbonScore) {
    final newTotal = totalCarbonFootprint + carbonScore;
    final newPurchases = totalPurchases + 1;
    final avgScore = newTotal / newPurchases;

    String newLevel;
    if (avgScore < 30) {
      newLevel = 'Low';
    } else if (avgScore < 60) {
      newLevel = 'Medium';
    } else {
      newLevel = 'High';
    }

    final newAchievements = List<String>.from(achievements);

    // Check for new achievements
    if (newPurchases == 1 && !newAchievements.contains('First Scan!')) {
      newAchievements.add('First Scan!');
    }
    if (newPurchases == 10 && !newAchievements.contains('Eco Explorer')) {
      newAchievements.add('Eco Explorer');
    }
    if (newPurchases == 50 && !newAchievements.contains('Sustainability Champion')) {
      newAchievements.add('Sustainability Champion');
    }
    if (newPurchases == 100 && !newAchievements.contains('Green Guardian')) {
      newAchievements.add('Green Guardian');
    }
    if (avgScore < 30 && !newAchievements.contains('Low Impact Hero')) {
      newAchievements.add('Low Impact Hero');
    }

    return copyWith(
      totalCarbonFootprint: newTotal,
      totalPurchases: newPurchases,
      totalScans: totalScans + 1,
      footprintLevel: newLevel,
      achievements: newAchievements,
      lastUpdatedAt: DateTime.now(),
    );
  }

  UserProfile incrementScans() {
    return copyWith(
      totalScans: totalScans + 1,
      lastUpdatedAt: DateTime.now(),
    );
  }
}

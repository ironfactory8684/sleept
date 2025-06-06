import 'package:flutter/foundation.dart';

class SharedHabitList {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<Map<String, dynamic>> habits;
  final bool isPublic;
  final DateTime createdAt;

  SharedHabitList({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.habits,
    required this.isPublic,
    required this.createdAt,
  });

  factory SharedHabitList.fromJson(Map<String, dynamic> json) {
    return SharedHabitList(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      habits: (json['habits'] as List).map((habit) => Map<String, dynamic>.from(habit)).toList(),
      isPublic: json['is_public'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'habits': habits,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SharedHabitList &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        listEquals(other.habits.map((e) => e.toString()).toList(), habits.map((e) => e.toString()).toList()) &&
        other.isPublic == isPublic &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        habits.hashCode ^
        isPublic.hashCode ^
        createdAt.hashCode;
  }
}

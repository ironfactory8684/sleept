class HabitModel {
  final String? id;
  final int? duration;
  final int? count;
  final String type;
  final String selectedHabit;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final String? userId;
  final String? groupId;
  final DateTime? createdAt;

  HabitModel({
    this.id,
    this.duration,
    this.count,
    required this.type,
    required this.selectedHabit,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.userId,
    this.groupId,
    this.createdAt,
  });

  HabitModel copy({
    String? id,
    int? duration,
    int? count,
    String? type,
    String? selectedHabit,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    String? userId,
    String? groupId,
  }) => HabitModel(
        id: id ?? this.id,
        duration: duration ?? this.duration,
        count: count ?? this.count,
        type: type ?? this.type,
        selectedHabit: selectedHabit ?? this.selectedHabit,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isCompleted: isCompleted ?? this.isCompleted,
        userId: userId ?? this.userId,
        groupId: groupId ?? this.groupId,
        createdAt: this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'duration': duration,
        'count': count,
        'type': type,
        'selected_habit': selectedHabit,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_completed': isCompleted,
        'user_id': userId,
        'group_id': groupId,
        'created_at': createdAt?.toIso8601String(),
      };

  factory HabitModel.fromMap(Map<String, dynamic> map) => HabitModel(
        id: map['id']?.toString(),
        duration: map['duration'] ?? map['duration_days'],
        count: map['count'] ?? 0,
        type: map['type'],
        selectedHabit: map['selected_habit'] ?? map['selectedHabit'],
        startDate: map['start_date'] != null 
            ? DateTime.parse(map['start_date']) 
            : DateTime.parse(map['startDate']),
        endDate: map['end_date'] != null 
            ? DateTime.parse(map['end_date']) 
            : DateTime.parse(map['endDate']),
        isCompleted: map['is_completed'] is bool 
            ? map['is_completed'] 
            : (map['isCompleted'] is bool 
                ? map['isCompleted'] 
                : map['is_completed'] == 1 || map['isCompleted'] == 1),
        userId: map['user_id'],
        groupId: map['group_id'],
        createdAt: map['created_at'] != null 
            ? DateTime.parse(map['created_at']) 
            : null,
      );
}

class TrackingEntry {
  final String? id;
  final String habitId;
  final DateTime completionDate;
  final String? userId;
  final DateTime? createdAt;

  TrackingEntry({
    this.id,
    required this.habitId,
    required this.completionDate,
    this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'habit_id': habitId,
        'completion_date': completionDate.toIso8601String(),
        'user_id': userId,
        'created_at': createdAt?.toIso8601String(),
      };

  factory TrackingEntry.fromMap(Map<String, dynamic> map) => TrackingEntry(
        id: map['id']?.toString(),
        habitId: map['habit_id'] ?? map['habitId'],
        completionDate: map['completion_date'] != null 
            ? DateTime.parse(map['completion_date']) 
            : DateTime.parse(map['completionDate']),
        userId: map['user_id'],
        createdAt: map['created_at'] != null 
            ? DateTime.parse(map['created_at']) 
            : null,
      );
}

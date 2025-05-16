class TrackingEntry {
  final int? id;
  final int habitId; // Link to the habit
  final DateTime completionDate; // Date the habit was completed

  TrackingEntry({
    this.id,
    required this.habitId,
    required this.completionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completionDate': completionDate.toIso8601String().split('T')[0], // Save only the date part
    };
  }

  static TrackingEntry fromMap(Map<String, dynamic> map) {
    return TrackingEntry(
      id: map['id'] as int,
      habitId: map['habitId'] as int,
      completionDate: DateTime.parse(map['completionDate'] as String),
    );
  }
}
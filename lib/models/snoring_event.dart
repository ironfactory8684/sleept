class SnoringEvent {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final double? intensity; // Audio energy level of the snoring event

  SnoringEvent({
    this.id,
    required this.startTime,
    required this.endTime,
    this.intensity,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'intensity': intensity,
    };
  }

  factory SnoringEvent.fromMap(Map<String, dynamic> map) {
    return SnoringEvent(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      intensity: map['intensity'] as double?,
    );
  }
}

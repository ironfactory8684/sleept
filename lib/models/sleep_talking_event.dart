import 'package:flutter/foundation.dart';

/// Represents a sleep talking event detected during sleep tracking
class SleepTalkingEvent {
  final DateTime startTime;
  final DateTime endTime;
  final String? audioPath;
  final String? transcription;
  final double? intensity;

  /// Creates a new SleepTalkingEvent
  /// 
  /// [startTime] is when the talking was first detected
  /// [endTime] is when the talking stopped
  /// [audioPath] optional path to the audio recording of this event
  /// [transcription] optional text transcription of the sleep talking
  /// [intensity] optional measurement of the talking intensity
  SleepTalkingEvent({
    required this.startTime,
    required this.endTime,
    this.audioPath,
    this.transcription,
    this.intensity,
  });

  /// Duration of the talking event
  Duration get duration => endTime.difference(startTime);

  /// Creates a copy of this SleepTalkingEvent with the given fields replaced with new values
  SleepTalkingEvent copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? audioPath,
    String? transcription,
    double? intensity,
  }) {
    return SleepTalkingEvent(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      audioPath: audioPath ?? this.audioPath,
      transcription: transcription ?? this.transcription,
      intensity: intensity ?? this.intensity,
    );
  }

  /// Creates a SleepTalkingEvent from a map (for database operations)
  factory SleepTalkingEvent.fromMap(Map<String, dynamic> map) {
    return SleepTalkingEvent(
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      audioPath: map['audioPath'],
      transcription: map['transcription'],
      intensity: map['intensity'],
    );
  }

  /// Converts this SleepTalkingEvent to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'audioPath': audioPath,
      'transcription': transcription,
      'intensity': intensity,
    };
  }

  @override
  String toString() {
    return 'SleepTalkingEvent(startTime: $startTime, endTime: $endTime, duration: $duration, transcription: $transcription)';
  }
}

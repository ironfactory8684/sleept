import 'package:sleept/models/snoring_event.dart';
import 'package:sleept/models/sleep_talking_event.dart';

/// Represents a complete sleep tracking session
class SleepSession {
  final DateTime startTime;
  final DateTime endTime;
  final String sessionDirectory;
  final List<SnoringEvent> snoringEvents;
  final List<SleepTalkingEvent> sleepTalkingEvents;
  final Map<String, dynamic>? sleepStages; // Optional calculated sleep stages
  final double? sleepScore; // Optional overall sleep quality score

  /// Creates a new SleepSession
  /// 
  /// [startTime] is when the sleep tracking started
  /// [endTime] is when the sleep tracking ended
  /// [sessionDirectory] is the path to the directory containing all audio files
  /// [snoringEvents] is a list of snoring events detected during the session
  /// [sleepTalkingEvents] is a list of sleep talking events detected during the session
  /// [sleepStages] is an optional map of sleep stages (can include duration of each stage)
  /// [sleepScore] is an optional calculated sleep quality score
  SleepSession({
    required this.startTime,
    required this.endTime,
    required this.sessionDirectory,
    required this.snoringEvents,
    required this.sleepTalkingEvents,
    this.sleepStages,
    this.sleepScore,
  });

  /// Total duration of the sleep session
  Duration get duration => endTime.difference(startTime);

  /// Percentage of time spent snoring
  double get snoringPercentage {
    if (snoringEvents.isEmpty) return 0.0;
    
    final int totalSnoringSecs = snoringEvents.fold(
      0, 
      (total, event) => total + event.duration.inSeconds
    );
    
    return (totalSnoringSecs / duration.inSeconds) * 100;
  }

  /// Percentage of time spent talking in sleep
  double get talkingPercentage {
    if (sleepTalkingEvents.isEmpty) return 0.0;
    
    final int totalTalkingSecs = sleepTalkingEvents.fold(
      0, 
      (total, event) => total + event.duration.inSeconds
    );
    
    return (totalTalkingSecs / duration.inSeconds) * 100;
  }

  /// Creates a copy of this SleepSession with the given fields replaced with new values
  SleepSession copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? sessionDirectory,
    List<SnoringEvent>? snoringEvents,
    List<SleepTalkingEvent>? sleepTalkingEvents,
    Map<String, dynamic>? sleepStages,
    double? sleepScore,
  }) {
    return SleepSession(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sessionDirectory: sessionDirectory ?? this.sessionDirectory,
      snoringEvents: snoringEvents ?? this.snoringEvents,
      sleepTalkingEvents: sleepTalkingEvents ?? this.sleepTalkingEvents,
      sleepStages: sleepStages ?? this.sleepStages,
      sleepScore: sleepScore ?? this.sleepScore,
    );
  }

  /// Creates a SleepSession from a map (for database operations)
  factory SleepSession.fromMap(Map<String, dynamic> map) {
    return SleepSession(
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      sessionDirectory: map['sessionDirectory'],
      snoringEvents: (map['snoringEvents'] as List)
          .map((e) => SnoringEvent.fromMap(e))
          .toList(),
      sleepTalkingEvents: (map['sleepTalkingEvents'] as List)
          .map((e) => SleepTalkingEvent.fromMap(e))
          .toList(),
      sleepStages: map['sleepStages'],
      sleepScore: map['sleepScore'],
    );
  }

  /// Converts this SleepSession to a map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'sessionDirectory': sessionDirectory,
      'snoringEvents': snoringEvents.map((e) => e.toMap()).toList(),
      'sleepTalkingEvents': sleepTalkingEvents.map((e) => e.toMap()).toList(),
      'sleepStages': sleepStages,
      'sleepScore': sleepScore,
    };
  }

  @override
  String toString() {
    return 'SleepSession(startTime: $startTime, endTime: $endTime, duration: $duration, '
           'snoringEvents: ${snoringEvents.length}, sleepTalkingEvents: ${sleepTalkingEvents.length}, '
           'sleepScore: $sleepScore)';
  }
}

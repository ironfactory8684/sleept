import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/tracking_entry.dart';
import '../../../models/snoring_event.dart';

class HabitModel {
  final int? id;
  final int? duration;
  final int? count;
  final String type;
  final String selectedHabit;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  HabitModel({
    this.id,
    this.duration,
    this.count,
    required this.type,
    required this.selectedHabit,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  HabitModel copy({
    int? id,
    int? duration,
    int? count,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
  }) => HabitModel(
        id: id ?? this.id,
        duration: duration ?? this.duration,
        count: count ?? this.count,
        type: type,
        selectedHabit: selectedHabit,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'duration': duration,
        'count': count,
        'type': type,
        'selectedHabit': selectedHabit,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isCompleted': isCompleted ? 1 : 0,
      };

  static HabitModel fromMap(Map<String, dynamic> map) => HabitModel(
        id: map['id'] as int,
        duration: map['duration'] as int,
        count: map['count'] as int,
        type: map['type'] as String,
        selectedHabit: map['selectedHabit'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        isCompleted: (map['isCompleted'] as int) == 1,
      );
}

class HabitDatabase {
  static final HabitDatabase instance = HabitDatabase._init();
  static Database? _database;

  HabitDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        // Ensure snoring_events table exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS snoring_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    await db.execute('''
      CREATE TABLE habits (
        id $idType,
        duration $intType,
        count $intType,
        type $textType,
        selectedHabit $textType,
        startDate $textType,
        endDate $textType,
        isCompleted $intType
      )
    ''');

    // Create the tracking table
    await db.execute('''
      CREATE TABLE habit_tracking (
        id $idType,
        habitId $intType,
        completionDate $textType,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE snoring_events (
        id $idType,
        startTime $textType,
        endTime $textType
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE habits ADD COLUMN startDate TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE habits ADD COLUMN endDate TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE habits ADD COLUMN isCompleted INTEGER NOT NULL DEFAULT 0');
    }
    // Add snoring_events table for existing DBs upgrading to v3
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE snoring_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          startTime TEXT NOT NULL,
          endTime TEXT NOT NULL
        )
      ''');
    }
  }

  Future<HabitModel> create(HabitModel habit) async {
    final db = await instance.database;
    final id = await db.insert('habits', habit.toMap());
    return habit.copy(id: id);
  }

  Future<List<HabitModel>> readAllHabits() async {
    final db = await instance.database;
    final result = await db.query('habits');
    return result.map((map) => HabitModel.fromMap(map)).toList();
  }

  // Method to update habit count and isCompleted status
  Future<int> updateHabit(HabitModel habit) async {
    final db = await instance.database;
    return db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }


  // Tracking methods
  Future<TrackingEntry> createTracking(TrackingEntry trackingEntry) async {
    final db = await instance.database;
    final id = await db.insert('habit_tracking', trackingEntry.toMap());
    return TrackingEntry(
        id: id, habitId: trackingEntry.habitId, completionDate: trackingEntry.completionDate);
  }

  Future<List<TrackingEntry>> readTrackingForHabit(int habitId) async {
    final db = await instance.database;
    final result = await db.query(
      'habit_tracking',
      where: 'habitId = ?',
      whereArgs: [habitId],
      orderBy: 'completionDate ASC', // Optional: Order by date
    );
    return result.map((map) => TrackingEntry.fromMap(map)).toList();
  }

  // Create snoring event
  Future<SnoringEvent> createSnoringEvent(SnoringEvent event) async {
    final db = await instance.database;
    final id = await db.insert('snoring_events', event.toMap());
    return SnoringEvent(id: id, startTime: event.startTime, endTime: event.endTime);
  }

  // Read snoring events
  Future<List<SnoringEvent>> readSnoringEvents() async {
    final db = await instance.database;
    final result = await db.query('snoring_events', orderBy: 'startTime ASC');
    return result.map((map) => SnoringEvent.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

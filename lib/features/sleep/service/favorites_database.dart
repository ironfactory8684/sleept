import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteDatabase {
  static final FavoriteDatabase instance = FavoriteDatabase._init();
  static Database? _database;

  FavoriteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        musicPath TEXT UNIQUE
      )
    ''');
  }

  Future<void> addFavorite(String path) async {
    final db = await instance.database;
    await db.insert(
      'favorites',
      {'musicPath': path},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFavorite(String path) async {
    final db = await instance.database;
    await db.delete(
      'favorites',
      where: 'musicPath = ?',
      whereArgs: [path],
    );
  }

  Future<bool> isFavorited(String path) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'musicPath = ?',
      whereArgs: [path],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}

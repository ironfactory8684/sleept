import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/music_model.dart';

class MusicDatabase {
  static final MusicDatabase instance = MusicDatabase._init();
  static Database? _database;

  MusicDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('musics.db');
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
      CREATE TABLE musics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        duration TEXT NOT NULL,
        musicPath TEXT NOT NULL UNIQUE
      )
    ''');

    // Seed initial data
    final musics = [
      // Top10
      {'imagePath':'assets/images/top_10_card_background_2.png','title':'신비로운 모래성에서 사각거리는 소리','category':'ASMR','duration':'2시간 30분','musicPath':'assets/music/sand_sound.mp3'},
      {'imagePath':'assets/images/top_10_card_background_1.png','title':'비 내린 오후 숲 새들의 노래','category':'명상','duration':'1시간 30분','musicPath':'assets/music/forest_bird_sound.mp3'},
      {'imagePath':'assets/images/featured_card_background.png','title':'포근한 자장가 같은 속삭임 팟캐스트','category':'팟캐스트','duration':'2시간 30분','musicPath':'assets/music/podcast_lullaby.mp3'},
      // Recent
      {'imagePath':'assets/images/recent_play_image_1.png','title':'여유로운 낮잠같은 날','category':'팟캐스트','duration':'1시간 30분','musicPath':'assets/music/podcast_nap.mp3'},
      {'imagePath':'assets/images/recent_play_image_2.png','title':'여유로운 낮잠같은 날','category':'팟캐스트','duration':'1시간 30분','musicPath':'assets/music/podcast_nap.mp3'},
      // 스르륵
      {'imagePath':'assets/images/card_image_1.png','title':'깊은 수면을 위한 움직임','category':'스트레칭','duration':'15분','musicPath':'assets/music/bathroom-chill-background-music-14977.mp3'},
      {'imagePath':'assets/images/card_image_2.png','title':'비 내리는 숲 속의 연주','category':'ASMR','duration':'3시간','musicPath':'assets/music/midnight-forest-184304.mp3'},
      {'imagePath':'assets/images/card_image_3.png','title':'느긋한 오후와 차 한잔','category':'명상','duration':'2시간 30분','musicPath':'assets/music/quiet-sleep-2-263254.mp3'},
      // 자연의 소리
      {'imagePath':'assets/images/card_image_4.png','title':'나만의 세계와 바람 소리','category':'ASMR','duration':'2시간','musicPath':'assets/music/soothing-deep-sleep-music-432-hz-191708.mp3'},
      {'imagePath':'assets/images/card_image_5.png','title':'도시 속 폭우와 나','category':'ASMR','duration':'1시간 20분','musicPath':'assets/music/the-old-water-mill-meditation-8005.mp3'},
      {'imagePath':'assets/images/card_image_6.png','title':'붉은 노을이 지는 해변가에 서서 파도 소리를 들으며','category':'ASMR','duration':'2시간 30분','musicPath':'assets/music/wave_sound.mp3'},
    ];
    // Ignore duplicates on seed
    for (var m in musics) {
      await db.insert(
        'musics',
        m,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<MusicModel>> readAllMusics() async {
    final db = await instance.database;
    final results = await db.query('musics', orderBy: 'id ASC');
    return results.map((map) => MusicModel.fromMap(map)).toList();
  }
}

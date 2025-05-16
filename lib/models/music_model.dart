class MusicModel {
  final int id;
  final String imagePath;
  final String title;
  final String category;
  final String duration;
  final String musicPath;

  MusicModel({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.category,
    required this.duration,
    required this.musicPath,
  });
  factory MusicModel.fromMap(Map<String, dynamic> json){
    return MusicModel(
        id:json['id'],
      imagePath:json['imagePath'],
      title:json['title'],
      category:json['category'],
      duration:json['duration'],
      musicPath:json['musicPath'],
    );
  }
}
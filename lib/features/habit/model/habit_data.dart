class HabitData {
  final String imagePath;
  final String title;
  final String subtitle;
  bool isSelected;

  HabitData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
  });
}

class SleeptFormater {
  static String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    // return '$hours시간 $minutes분 뒤에 깨워드릴게요'; // 기존 방식
    return '${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분'; // 시:분:초 형식
  }
}
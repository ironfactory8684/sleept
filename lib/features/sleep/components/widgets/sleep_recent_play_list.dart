import 'package:flutter/material.dart';
import 'package:sleept/features/sleep/components/widgets/sleep_recent_play_card.dart';


class SleepRecentPlayList extends StatefulWidget {
  const SleepRecentPlayList({super.key});

  @override
  State<SleepRecentPlayList> createState() => _SleepRecentPlayListState();
}

class _SleepRecentPlayListState extends State<SleepRecentPlayList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 183, // 카드 높이에 맞게 조정
      child:
      ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SleepRecentPlayCard(imagePath: 'assets/images/recent_play_image_1.png', title: '여유로운 낮잠같은 날', category: '팟캐스트', totalTime: '1시간 30분', remainingTime: '30분 17초 남음', progress: 0.7, musicPath: 'assets/music/podcast_nap.mp3',),
          SleepRecentPlayCard(imagePath: 'assets/images/recent_play_image_1.png', title: '여유로운 낮잠같은 날', category: '팟캐스트', totalTime: '1시간 30분', remainingTime: '30분 17초 남음', progress: 0.7, musicPath: 'assets/music/podcast_nap.mp3',),
        ],
      ),
    );
  }
}

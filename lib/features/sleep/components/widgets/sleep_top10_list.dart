import 'package:flutter/material.dart';
import 'package:sleept/features/sleep/components/widgets/sleep_top10_card.dart';

class SleepTop10List extends StatefulWidget {
  const SleepTop10List({super.key});

  @override
  State<SleepTop10List> createState() => _SleepTop10ListState();
}

class _SleepTop10ListState extends State<SleepTop10List> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 240, // 카드의 높이에 맞게 조정
        child: SingleChildScrollView(
          child: Row(
            children: [
              SleepTop10Card(
                rank: '1',
                imagePath: 'assets/images/top_10_card_background_2.png',
                title: '신비로운 모래성에서 사각거리는 소리',
                category: 'ASMR',
                duration: '2시간 30분',
                isLiked: true,
                musicPath: 'assets/music/sand_sound.mp3',
              ),
              SleepTop10Card(
                rank: '2',
                imagePath: 'assets/images/top_10_card_background_1.png',
                title: '비 내린 오후 숲 새들의 노래',
                category: '명상',
                duration: '1시간 30분',
                isLiked: false,
                musicPath: 'assets/music/forest_bird_sound.mp3',
              ),
              SleepTop10Card(
                rank: '3',
                imagePath: 'assets/images/featured_card_background.png',
                title: '포근한 자장가 같은 속삭임 팟캐스트',
                category: '팟캐스트',
                duration: '2시간 30분',
                isLiked: false,
                musicPath: 'assets/music/podcast_lullaby.mp3',
              ),

            ],
          ),
        )
    );
  }
}

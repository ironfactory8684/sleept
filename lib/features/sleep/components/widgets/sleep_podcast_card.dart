
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/app_colors.dart';

class SleepPodcastCard extends StatefulWidget {
  const SleepPodcastCard({super.key});

  @override
  State<SleepPodcastCard> createState() => _SleepPodcastCardState();
}

class _SleepPodcastCardState extends State<SleepPodcastCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 150, // 높이 조정
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18), // 피그마 Rectangle 77 borderRadius
          image: DecorationImage(
            image: AssetImage('assets/images/featured_card_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 그라데이션 오버레이
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.mainBackground.withOpacity(0.4),
                    AppColors.mainBackground.withOpacity(1.0),
                  ],
                  stops: [0.0, 0.65, 1.0], // 피그마 그라데이션 stop 값 참고
                ),
              ),
            ),
            // 텍스트 및 태그
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '포근한 자장가 같은\n속삭임 팟캐스트',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container( // 피그마 Rectangle 169 + Group 38 유사하게
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.heartIconBackground, // 피그마 fill_CMLRR5
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                            'assets/images/music_icon_white.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(AppColors.textWhite, BlendMode.srcIn)
                        ),
                        const SizedBox(width: 5),
                        Text('팟캐스트', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textWhite)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Container( // Ellipse 19
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.dotColor, // 피그마 fill_0C95R3
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Text('2시간 30분', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSubtleGray)), // textGray or textSubtleGray
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

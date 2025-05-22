import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utils/app_colors.dart';
import '../../music_player_screen.dart';


class SleepTop10Card extends StatefulWidget {
  const SleepTop10Card({super.key, required this.rank, required this.imagePath, required this.title, required this.category, required this.duration, required this.isLiked, required this.musicPath});

  final String rank;
  final String imagePath;
  final String title;
  final String category;
  final String duration;
  final bool isLiked;
  final String musicPath;

  @override
  State<SleepTop10Card> createState() => _SleepTop10CardState();
}

class _SleepTop10CardState extends State<SleepTop10Card> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPlayerScreen(
              imagePath: widget.imagePath,
              title: widget.title,
              category: widget.category,
              duration: widget.duration,
              musicPath: widget.musicPath, // 전달받은 musicPath 사용
            ),
          ),
        );
      },
      child: Container(
        width: 162, // 피그마 Group 34624 너비 (추정)
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          children: [
            // 배경 이미지 및 그라데이션
            ClipRRect(
                borderRadius: BorderRadius.circular(18), // 피그마 Rectangle 71 borderRadius
                child: Container(
                  height: 240, // 임의 높이 지정
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.mainBackground.withOpacity(0.4),
                          AppColors.mainBackground.withOpacity(1.0),
                        ],
                        stops: [0.0, 0.6, 1.0], // 피그마 그라데이션 stop 값 참고
                      ),
                    ),
                  ),
                )
            ),
            // 컨텐츠 내용
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // 피그마 style_7AVG7E / style_WK692V 유사하게
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                        height: 1.38,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/music_icon_gray.svg', // 또는 music_icon_gray_2.svg
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(AppColors.textSubtleGray, BlendMode.srcIn),
                        ),
                        const SizedBox(width: 4),
                        _buildTag(widget.category, widget.duration, AppColors.textSubtleGray),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // 랭크 표시
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 30, // 크기 조정 필요
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.numberBadgeBackground,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.rank,
                    style: TextStyle(
                      // 피그마 style_CDF07S 유사하게
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
            ),
            // 좋아요 버튼
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 30, // 크기 조정 필요
                height: 30,
                decoration: BoxDecoration(
                    color: widget.isLiked ? AppColors.heartIconBackground : AppColors.outlineHeartIconBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.isLiked ? AppColors.heartIconBorder : AppColors.outlineHeartIconBorder, width: 1)
                ),
                child: Center(
                    child: SvgPicture.asset(
                      widget.isLiked ? 'assets/images/heart_icon_filled.svg' : 'assets/images/heart_icon_outline.svg',
                      width: 16, // 아이콘 크기 조정 필요
                      height: 16,
                      colorFilter: ColorFilter.mode(widget.isLiked ? AppColors.textWhite : AppColors.outlineHeartIconBorder, BlendMode.srcIn),
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String category, String duration, Color textColor) {
    return Row(
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container( // Ellipse 20
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dotColor, // 피그마 Ellipse fill or recentDotColor
              shape: BoxShape.circle,
            ),
          ),
        ),
        Text(
          duration,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textColor,
          ),
        ),
      ],
    );
  }

}



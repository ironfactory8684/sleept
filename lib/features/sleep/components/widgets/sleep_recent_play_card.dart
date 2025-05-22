import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../music_player_screen.dart';


class SleepRecentPlayCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String category;
  final String totalTime;
  final String remainingTime;
  final double progress;
  final String musicPath;

  const SleepRecentPlayCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.category,
    required this.totalTime,
    required this.remainingTime,
    required this.progress,
    required this.musicPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MusicPlayerScreen(
              imagePath: imagePath,
              title: title,
              category: category,
              duration: totalTime,
              musicPath: musicPath,
            ),
          ),
        );
      },
      child: Container(
        width: 309,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.recentPlayBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 106,
                height: 145,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  _buildTag(context),
                  const SizedBox(height: 17),
                  Text(
                    remainingTime,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.recentProgressText,
                    ),
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.progressBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 9),
                  OutlinedButton(
                    onPressed: () {
                      // 이어서 재생 기능
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.buttonBorder, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(145, 40),
                    ),
                    child: const Text(
                      '이어서 재생',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.chipSelectedBackground,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context) {
    return Row(
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.recentTagText,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: CircleAvatar(
            radius: 2,
            backgroundColor: AppColors.dotColor,
          ),
        ),
        Text(
          totalTime,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.recentTagText,
          ),
        ),
      ],
    );
  }
}

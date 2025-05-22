import 'package:flutter/material.dart';
import 'package:sleept/utils/app_colors.dart';
import '../../music_player_screen.dart';

class SleepContentCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String category;
  final String duration;
  final String musicPath;

  const SleepContentCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.category,
    required this.duration,
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
              duration: duration,
              musicPath: musicPath,
            ),
          ),
        );
      },
      child: Container(
        width: 162,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                height: 173,
                width: 162,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textWhite,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            _buildTag(),
          ],
        ),
      ),
    );
  }

  Widget _buildTag() {
    return Row(
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
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
          duration,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }
}

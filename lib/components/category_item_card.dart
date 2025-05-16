import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';

import '../constants/habit_datas.dart';

class CategoryItemCard extends StatelessWidget {
  final String type;

  final VoidCallback? onTap;

  const CategoryItemCard({
    super.key,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final habit = habitData[type];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      habit['iconPath'],
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      type,
                      style: AppTextStyles.cardItemTitle.copyWith(color: habit['iconColor']),
                    ),
                  ],
                ),
                SvgPicture.asset(
                  'assets/images/arrow.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(AppColors.tagText, BlendMode.srcIn),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit['subtitle'],
                  style: AppTextStyles.cardItemDescription,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:
                Row(
                  children: habit['tags'].map<Widget>((tag) => Padding( // Explicitly map to Widget
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      tag.toString(), // Ensure tag is treated as a String
                      style: AppTextStyles.tagText,
                    ),
                  )).toList(), // .toList() will now produce List<Widget>
                )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
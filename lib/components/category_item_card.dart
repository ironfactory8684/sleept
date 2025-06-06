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
        height: 192,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF242030),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Row(
              children: [
                SvgPicture.asset(
                  habit['iconPath'],
                  width: 13,
                  height: 13,
                ),
                const SizedBox(width: 2),
                Text(
                  type,
                  style: AppTextStyles.cardItemTitle.copyWith(color: habit['iconColor']),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 제목
            Text(
              habit['subtitle'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Min Sans',
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const Spacer(),
            // 해시태그
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (habit['tags'] as List<String>).map((tag) {
                return Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFFCECDD4),
                    fontSize: 12,
                    fontFamily: 'Min Sans',
                    fontWeight: FontWeight.w400,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

    );
  }
}
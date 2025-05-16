import 'package:flutter/material.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';

class HabitInfoCard extends StatelessWidget {
  const HabitInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 339,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.transparentCardBackground.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '습관 추천 상세 인포',
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 10),
          const Text(
            '아직 실행한 습관이 없어서 설명드릴 내용이나추천 인포가 없어요.',
            style: AppTextStyles.infoText,
          ),
        ],
      ),
    );
  }
} 
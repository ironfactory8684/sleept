import 'package:flutter/material.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';

class HabitInterestCard extends StatelessWidget {
  const HabitInterestCard({super.key});

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
          const Row(
            children: [
              Text(
                '습관별 관심도',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInterestItem(
                    label: '일상',
                    percent: 0,
                    backgroundColor: AppColors.dailyBackgroundColor,
                    textColor: AppColors.dailyColor,
                  ),
                  _buildInterestItem(
                    label: '운동',
                    percent: 0,
                    backgroundColor: AppColors.exerciseBackgroundColor,
                    textColor: AppColors.exerciseColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInterestItem(
                    label: '명상',
                    percent: 0,
                    backgroundColor: AppColors.meditationBackgroundColor,
                    textColor: AppColors.meditationColor,
                  ),
                  _buildInterestItem(
                    label: '스트레칭',
                    percent: 0,
                    backgroundColor: AppColors.stretchingBackgroundColor,
                    textColor: AppColors.stretchingColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestItem({
    required String label,
    required int percent,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Row(
      children: [
        Text(
          '$percent%',
          style: AppTextStyles.percentText,
        ),
        const SizedBox(width: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: AppTextStyles.categoryLabel.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
} 
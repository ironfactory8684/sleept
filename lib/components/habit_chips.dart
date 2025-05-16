import 'package:flutter/material.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';

class HabitChips extends StatelessWidget {
  const HabitChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: AppColors.tabBarBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip(label: '맞춤 습관', isSelected: true),
            _buildChip(label: '운동', isSelected: false),
            _buildChip(label: '일상', isSelected: false),
            _buildChip(label: '명상', isSelected: false),
            _buildChip(label: '스트레칭', isSelected: false),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: isSelected
            ? AppTextStyles.chipTextActive
            : AppTextStyles.chipTextInactive,
      ),
    );
  }
} 
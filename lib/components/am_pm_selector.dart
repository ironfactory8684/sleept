import 'package:flutter/material.dart';
import 'package:sleept/constants/colors.dart';

class AmPmSelector extends StatelessWidget {
  final bool isAm;
  final Function(bool) onChanged;

  const AmPmSelector({
    super.key,
    required this.isAm,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSelectorButton(
          label: '오전',
          isSelected: isAm,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 16),
        _buildSelectorButton(
          label: '오후',
          isSelected: !isAm,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }

  Widget _buildSelectorButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.primaryGray850,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.primaryGray750,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : const Color(0xFF7E7993),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 
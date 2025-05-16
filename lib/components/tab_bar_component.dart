import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';

class TabBarComponent extends StatelessWidget {
  const TabBarComponent({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.tabBarBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(
            index: 0,
            label: '홈',
            iconPath: 'assets/images/home_icon.svg',
          ),
          _buildTabItem(
            index: 1,
            label: '수면',
            iconPath: 'assets/images/moon_icon.svg',
          ),
          _buildTabItem(
            index: 2,
            label: '습관',
            iconPath: 'assets/images/habit_active.svg',
          ),
          _buildTabItem(
            index: 3,
            label: '트래킹',
            iconPath: 'assets/images/tracking_icon.svg',
          ),
          _buildTabItem(
            index: 4,
            label: '라이브러리',
            iconPath: 'assets/images/library_icon.svg',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required String iconPath,
  }) {
    final bool isSelected = index == currentIndex;
    
    return SizedBox(
      width: 55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.primary : AppColors.inactiveIcon,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: isSelected
                ? AppTextStyles.tabBarTextActive
                : AppTextStyles.tabBarTextInactive,
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/habit/habit_screen.dart';
import 'package:sleept/features/tracking/tracking_screen.dart';
import 'package:sleept/features/sleep/sleep_screen.dart';

import '../home/home_screen.dart';
import '../library/library_screen.dart';
class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _currentIndex = 0;
  
  // 각 탭에 해당하는 화면들
  final List<Widget> _screens = [
    const HomeScreen(),
    const SleepScreen(),
    const HabitScreen(),
    const TrackingScreen(),
    const LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 98,
      decoration: const BoxDecoration(
        color: AppColors.tabBarBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 탭 아이콘 영역
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(index: 0, label: '홈', iconPath: 'assets/images/home_icon.svg'),
                _buildTabItem(index: 1, label: '수면', iconPath: 'assets/images/moon_icon.svg'),
                _buildTabItem(index: 2, label: '습관', iconPath: 'assets/images/habit_icon.svg'),
                _buildTabItem(index: 3, label: '트래킹', iconPath: 'assets/images/tracking_active.svg'),
                _buildTabItem(index: 4, label: '라이브러리', iconPath: 'assets/images/library_icon.svg'),
              ],
            ),
          ),

          // 홈 인디케이터 영역 (iOS 하단 안전 영역)
          Container(
            width: double.infinity,
            color: AppColors.tabBarBackground,

          ),

          // 인디케이터 바
          // Container(
          //   alignment: Alignment.center,
          //   child: Container(
          //     width: 134,
          //     height: 5,
          //     decoration: BoxDecoration(
          //       color: Colors.white, // ← 인디케이터 바 색상 변경 가능
          //       borderRadius: BorderRadius.circular(100),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }


  Widget _buildTabItem({
    required int index,
    required String label,
    required String iconPath,
  }) {
    final bool isSelected = index == _currentIndex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 15.5, left: 15.5, bottom: 4),
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.primary : AppColors.inactiveIcon,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.inactiveTabText,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
} 
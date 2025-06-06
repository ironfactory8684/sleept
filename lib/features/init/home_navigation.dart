import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/habit/habit_screen.dart';
import 'package:sleept/features/tracking/tracking_screen.dart';
import 'package:sleept/features/sleep/sleep_screen.dart';
import '../home/home_screen.dart';
import '../mypage/mypage_screen.dart';
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
    const MypageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(
                  index: 0,
                  label: '홈',
                  iconPath: 'home',
                ),
                _buildTabItem(
                  index: 1,
                  label: '수면',
                  iconPath: 'moon',
                ),
                _buildTabItem(
                  index: 2,
                  label: '습관',
                  iconPath: 'habit',
                ),
                _buildTabItem(
                  index: 3,
                  label: '트래킹',
                  iconPath: 'tracking',
                ),
                _buildTabItem(
                  index: 4,
                  label: '마이페이지',
                  iconPath: 'library',
                ),
              ],
            ),
          ),
          Container(
            height: 5,
            color: AppColors.tabBarBackground,
            alignment: Alignment.center,
            child: Container(
              width: 134,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
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
            SvgPicture.asset(
              'assets/svg/nav_${iconPath}_${isSelected?'active':'inactive'}.svg',
              width: 24,
              height: 24,
              // colorFilter: ColorFilter.mode(
              //   isSelected ? AppColors.primary : AppColors.inactiveIcon,
              //   BlendMode.srcIn,
              // ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Min Sans',
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
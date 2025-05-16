import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/components/category_item_card.dart';
import 'package:sleept/components/habit_chips.dart';
import 'package:sleept/components/habit_info_card.dart';
import 'package:sleept/components/habit_interest_card.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';
import 'package:sleept/features/habit/habit_detail_screen.dart'; // Add this line

class HabitScreen extends StatelessWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 상태바 스타일 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            const SliverToBoxAdapter(
              child: HabitChips(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInterestCard(),
                    const SizedBox(height: 16),
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildCategoryCards(context),
                    const SizedBox(height: 20), // 탭바 제거 후 하단 여백 추가
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd.withOpacity(0),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 메인 타이틀 및 설명
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '내 수면을 돕는 맞춤 습관',
                style: AppTextStyles.mainHeaderTitle,
              ),
              const SizedBox(height: 8),
              const Text(
                'Siha님의 습관 프로필과\n맞춤 습관을 알려줄게요',
                style: AppTextStyles.subHeaderTitle,
              ),
            ],
          ),
          // 도움말 아이콘
          Positioned(
            top: 6,
            right: 0,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  SvgPicture.asset(
                    'assets/images/question_circle.svg',
                    width: 36,
                    height: 36,
                    colorFilter: const ColorFilter.mode(
                      AppColors.questionCircle,
                      BlendMode.srcIn,
                    ),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/question_mark.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.questionIcon,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestCard() {
    return const HabitInterestCard();
  }

  Widget _buildInfoCard() {
    return const HabitInfoCard();
  }

  Widget _buildCategoryCards(BuildContext context) {
    return Column(
      children: [
        CategoryItemCard(
          type: '운동',

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(
                  type: '운동',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        CategoryItemCard(
          type: '스트레칭',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(
                  type: '스트레칭',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        CategoryItemCard(
          type: '일상',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(
                  type: '일상',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        CategoryItemCard(
          type: '명상',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(
                  type: '명상',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
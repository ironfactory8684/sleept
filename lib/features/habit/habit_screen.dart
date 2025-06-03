import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/components/category_item_card.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';
import 'package:sleept/features/habit/habit_detail_screen.dart';
import 'package:sleept/features/habit/my_habits_screen.dart';
import 'package:sleept/providers/auth_provider.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            SliverToBoxAdapter(child: _buildHeader(ref)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryCards(context),
                    const SizedBox(height: 20), // 탭바 제거 후 하단 여백 추가
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '유저들이 공유한 습관 리스트',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Min Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: ShapeDecoration(
                        color: const Color(
                          0xFF242030,
                        ) /* Primitive-Color-gray-900 */,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: NetworkImage("https://placehold.co/68x68"),
                                fit: BoxFit.cover,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '출근하기 전 간단 운동',
                                  style: TextStyle(
                                    color: Colors.white /* Primitive-Color-White */,
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                    height: 1.50,
                                  ),
                                ),
                                Text(
                                  '평소보다 30분 일찍 일어나고 개운하게 하루를 시작하기에 딱 좋아요💜',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFCECDD4,
                                    ) /* Primitive-Color-gray-200 */,
                                    fontSize: 13,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final BuildContext context = ref.context;
    final authState = ref.watch(authProvider);
    final bool isLogin = authState is AuthStateAuthenticated;
    
    // AsyncValue를 처리하여 데이터 추출
    final userInfoAsync = ref.watch(userNicknameProvider);
    final userInfo = userInfoAsync.when(
      data: (data) => data ?? {},
      loading: () => {},
      error: (_, __) => {},
    );
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // 메인 타이틀 및 설명
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLogin && userInfo.containsKey('nickname') && userInfo['nickname'] != null
                    ? '${userInfo['nickname']}님,\n이런 습관 리스트는 어때요?'
                    : '안녕하세요,\n이런 습관 리스트는 어때요?',
                style: AppTextStyles.subHeaderTitle,
              ),
            ],
          ),

        ],
      ),
    );
  }
  
  Widget _buildCategoryCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CategoryItemCard(
                type: '운동',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(type: '운동'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CategoryItemCard(
                type: '스트레칭',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(type: '스트레칭'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CategoryItemCard(
                type: '일상',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(type: '일상'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CategoryItemCard(
                type: '명상',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HabitDetailScreen(type: '명상'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

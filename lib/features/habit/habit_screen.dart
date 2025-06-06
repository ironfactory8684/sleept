import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/components/category_item_card.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/text_styles.dart';
import 'package:sleept/features/habit/habit_detail_screen.dart';
import 'package:sleept/features/habit/model/shared_habit_list_model.dart';
import 'package:sleept/features/habit/shared_habit_detail_screen.dart';
import 'package:sleept/providers/auth_provider.dart';
import 'package:sleept/providers/shared_habit_provider.dart';

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
            // Display public shared habit lists
            Consumer(
              builder: (context, ref, child) {
                final sharedHabitsAsync = ref.watch(publicSharedHabitsProvider);
                
                return sharedHabitsAsync.when(
                  data: (sharedHabits) {
                    if (sharedHabits.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                          child: Center(
                            child: Text(
                              '아직 공유된 습관 리스트가 없습니다.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final habit = sharedHabits[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 16.0, 
                              right: 16.0, 
                              top: index == 0 ? 16.0 : 8.0,
                              bottom: index == sharedHabits.length - 1 ? 16.0 : 8.0,
                            ),
                            child: _buildSharedHabitListCard(context, habit),
                          );
                        },
                        childCount: sharedHabits.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          '습관 리스트를 불러오는 중 오류가 발생했습니다: $error',
                          style: TextStyle(
                            color: Colors.red[300],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
  
  Widget _buildSharedHabitListCard(BuildContext context, SharedHabitList habit) {
    // Default placeholder image if none is provided
    final imageUrl = habit.imageUrl?.isNotEmpty == true
        ? habit.imageUrl!
        : "assets/images/sleept_basic.png";
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SharedHabitDetailScreen(sharedHabitId: habit.id),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: ShapeDecoration(
          color: const Color(0xFF242030),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image container
          Container(
            width: 68,
            height: 68,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: imageUrl.startsWith('http')
                    ? NetworkImage(imageUrl)
                    : AssetImage("assets/images/sleept_basic.png") as ImageProvider,
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
          // Text content container
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                if (habit.description?.isNotEmpty == true) ...[  
                  const SizedBox(height: 2),
                  Text(
                    habit.description!,
                    style: const TextStyle(
                      color: Color(0xFFCECDD4),
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "습관 ${habit.habits.length}개",
                  style: const TextStyle(
                    color: Color(0xFFB8B6C0),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

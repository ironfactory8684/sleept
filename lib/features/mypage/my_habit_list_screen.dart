import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/habit/model/shared_habit_list_model.dart';
import 'package:sleept/features/habit/shared_habit_detail_screen.dart';
import 'package:sleept/providers/shared_habit_provider.dart';

import 'my_habit_add_screen.dart';

class MyHabitListScreen extends ConsumerWidget {
  const MyHabitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자의 공유 습관 리스트 불러오기
    final userSharedHabitsAsync = ref.watch(userSharedHabitsProvider);
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        title: Text(
          '습관 리스트',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.50,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHabitAddScreen()));
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '만들기',
                style: TextStyle(
                  color: const Color(0xFF724BFF) /* Primary-Color */,
                  fontSize: 16,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: userSharedHabitsAsync.when(
          data: (sharedHabitLists) {
            if (sharedHabitLists.isEmpty) {
              // 공유 습관 리스트가 없을 때
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      '아직 비어 있어요.\n나만의 습관 리스트를 만들어보세요 :)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8E8AA1),
                        fontSize: 14,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                  )
                ],
              );
            }
            
            // 공유 습관 리스트가 있을 때
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sharedHabitLists.length,
              itemBuilder: (context, index) {
                final sharedHabit = sharedHabitLists[index];
                return _buildSharedHabitListCard(context, sharedHabit);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '습관 리스트를 불러오는데 오류가 발생했습니다: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontFamily: 'Min Sans',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // 공유 습관 리스트 카드 생성
  Widget _buildSharedHabitListCard(BuildContext context, SharedHabitList sharedHabit) {

    final imageUrl = sharedHabit.imageUrl?.isNotEmpty == true
        ? sharedHabit.imageUrl!
        : "assets/images/sleept_basic.png";
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF242030),
      elevation: 3,
      child:

      InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // 습관 리스트 상세 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SharedHabitDetailScreen(
                sharedHabitId: sharedHabit.id,
              ),
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
                      sharedHabit.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                    if (sharedHabit.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        sharedHabit.description!,
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
                      "습관 ${sharedHabit.habits.length}개",
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

      ),
    );
  }
}

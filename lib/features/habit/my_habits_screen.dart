import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/habit/model/habit_model.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';
import 'package:sleept/providers/auth_provider.dart';
import 'package:sleept/providers/habit_provider.dart';

class MyHabitsScreen extends ConsumerWidget {
  const MyHabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final bool isLogin = authState is AuthStateAuthenticated;

    if (!isLogin) {
      return Scaffold(
        backgroundColor: AppColors.mainBackground,
        appBar: AppBar(
          backgroundColor: AppColors.mainBackground,
          elevation: 0,
          title: const Text('내 습관 목록', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '로그인이 필요합니다',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // 로그인 화면으로 이동
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text('로그인하기'),
              ),
            ],
          ),
        ),
      );
    }

    // 사용자 습관 데이터 불러오기
    final userHabitsAsync = ref.watch(userHabitsProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        title: const Text('내 습관 목록', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: userHabitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '아직 등록된 습관이 없습니다',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return _buildHabitCard(context, habit, ref);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            '데이터를 불러오는데 실패했습니다: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // 습관 카테고리 선택 화면으로 이동
          Navigator.of(context).pushNamed('/habit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Map<String, dynamic> habitData, WidgetRef ref) {
    final habit = HabitModel.fromMap(habitData);
    final startDate = DateFormat('yyyy.MM.dd').format(habit.startDate);
    final endDate = DateFormat('yyyy.MM.dd').format(habit.endDate);
    final now = DateTime.now();
    
    // 진행 상황 계산
    final totalDays = habit.endDate.difference(habit.startDate).inDays;
    final passedDays = now.difference(habit.startDate).inDays;
    final progress = passedDays / totalDays;
    final normalizedProgress = progress < 0 
        ? 0.0 
        : progress > 1 
            ? 1.0 
            : progress;

    // 트래킹 데이터 가져오기
    final trackingAsync = ref.watch(habitTrackingProvider(habit.id ?? ''));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF242030),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    habit.selectedHabit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    habit.type,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$startDate ~ $endDate',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // 진행 바
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: normalizedProgress,
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 10,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '완료 횟수: ${habit.count}/${habit.duration}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                trackingAsync.when(
                  data: (trackingData) {
                    final isCompletedToday = trackingData.any((tracking) {
                      final date = DateTime.parse(tracking['completion_date']);
                      return date.year == now.year && 
                             date.month == now.month && 
                             date.day == now.day;
                    });
                    
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompletedToday 
                            ? Colors.grey 
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: isCompletedToday
                          ? null
                          : () => _markHabitComplete(context, habit, ref),
                      child: Text(
                        isCompletedToday ? '오늘 완료' : '완료하기',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  error: (_, __) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _markHabitComplete(context, habit, ref),
                    child: const Text('완료하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markHabitComplete(BuildContext context, HabitModel habit, WidgetRef ref) async {
    try {
      // 1. 트래킹 데이터 추가
      await HabitSupabaseService.instance.addHabitTracking(
        habitId: habit.id!,
        completionDate: DateTime.now(),
      );
      
      // 2. 습관 카운트 증가
      await HabitSupabaseService.instance.updateUserHabit(
        habitId: habit.id!,
        count: (habit.count ?? 0) + 1,
        isCompleted: habit.duration != null && (habit.count ?? 0) + 1 >= habit.duration!,
      );
      
      // 3. 데이터 갱신
      ref.invalidate(userHabitsProvider);
      ref.invalidate(habitTrackingProvider(habit.id!));
      
      // 4. 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('습관 완료 처리되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

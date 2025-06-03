import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';

// 습관 카테고리 데이터 프로바이더
final habitCategoriesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await HabitSupabaseService.instance.getAllHabitCategories();
});

// 사용자 습관 데이터 프로바이더
final userHabitsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await HabitSupabaseService.instance.getUserHabits();
  } catch (e) {
    // 로그인하지 않은 경우 빈 리스트 반환
    return [];
  }
});

// 특정 카테고리의 습관 아이템 프로바이더
final habitItemsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, categoryId) async {
    return await HabitSupabaseService.instance.getHabitItemsByCategory(categoryId);
  },
);

// 선택된 습관 상태 프로바이더
final selectedHabitProvider = StateProvider<String?>((ref) => null);

// 단일 습관 데이터 프로바이더 (ID로 조회)
final singleHabitProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, habitId) async {
    final habit = await HabitSupabaseService.instance.getUserSingleHabit(habitId);

    return habit;
  },
);

// 습관 트래킹 데이터 프로바이더
final habitTrackingProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, habitId) async {
    return await HabitSupabaseService.instance.getHabitTracking(habitId);
  },
);

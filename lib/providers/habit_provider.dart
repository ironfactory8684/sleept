import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';

// 습관 카테고리 데이터 프로바이더
final habitCategoriesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await HabitSupabaseService.instance.getAllHabitCategories();
});

final habitAllItemsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  print("hello");
  try {
    return await HabitSupabaseService.instance.getHabitAllItems();
  } catch (e) {
    // 로그인하지 않은 경우 빈 리스트 반환
    print(e);
    return [];
  }

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

// New StateNotifier for selected habit items
class SelectedHabitItemsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  SelectedHabitItemsNotifier() : super([]);

  void addHabit(Map<String, dynamic> habit) {
    // Ensure 'id' key exists and is not null
    if (habit['id'] == null) {
      print("Error: Habit item is missing an 'id'. Cannot add to selected list.");
      return;
    }
    if (!state.any((item) => item['id'] == habit['id'])) {
      state = [...state, habit];
    }
  }

  void removeHabit(dynamic habitId) {
    state = state.where((item) => item['id'] != habitId).toList();
  }

  bool isSelected(dynamic habitId) {
    return state.any((item) => item['id'] == habitId);
  }
}

final selectedHabitItemsNotifierProvider =
    StateNotifierProvider<SelectedHabitItemsNotifier, List<Map<String, dynamic>>>((ref) {
  return SelectedHabitItemsNotifier();
});

// 습관 트래킹 데이터 프로바이더
final habitTrackingProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, habitId) async {
    return await HabitSupabaseService.instance.getHabitTracking(habitId);
  },
);

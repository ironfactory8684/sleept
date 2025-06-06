import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/providers/habit_provider.dart';
import '../../habit/model/habit_model.dart';
import '../../habit/service/habit_supabase_service.dart';

class HabitTrackingState {
  final int currentMonth;
  final int currentYear;
  final int today;
  final int ddays;
  final int lastDayOfMonth;
  final Map<String, dynamic>? currentData;
  final List<Map<String, dynamic>> completedEntries;
  final HabitModel? habit;
  final bool isSubmitting;
  final String? error;

  HabitTrackingState({
    required this.currentMonth,
    required this.currentYear,
    required this.today,
    required this.ddays,
    required this.lastDayOfMonth,
    required this.currentData,
    required this.completedEntries,
    required this.habit,
    required this.isSubmitting,
    this.error,
  });

  HabitTrackingState copyWith({
    int? currentMonth,
    int? currentYear,
    int? today,
    int? ddays,
    int? lastDayOfMonth,
    Map<String, dynamic>? currentData,
    List<Map<String, dynamic>>? completedEntries,
    HabitModel? habit,
    bool? isSubmitting,
    String? error,
  }) {
    return HabitTrackingState(
      currentMonth: currentMonth ?? this.currentMonth,
      currentYear: currentYear ?? this.currentYear,
      today: today ?? this.today,
      ddays: ddays ?? this.ddays,
      lastDayOfMonth: lastDayOfMonth ?? this.lastDayOfMonth,
      currentData: currentData ?? this.currentData,
      completedEntries: completedEntries ?? this.completedEntries,
      habit: habit ?? this.habit,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  factory HabitTrackingState.initial() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    final today = now.day;
    final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0).day;
    return HabitTrackingState(
      currentMonth: currentMonth,
      currentYear: currentYear,
      today: today,
      ddays: 0,
      lastDayOfMonth: lastDayOfMonth,
      currentData: null,
      completedEntries: [],
      habit: null,
      isSubmitting: false,
      error: null,
    );
  }
}

class HabitTrackingNotifier extends StateNotifier<HabitTrackingState> {
  final Ref ref;
  final String habitId;
  HabitTrackingNotifier(this.ref, this.habitId)
    : super(HabitTrackingState.initial()) {
    loadHabitData();
  }

  Future<void> loadHabitData() async {
    try {
      // ID로 단일 습관 데이터 직접 로드
      final habitData = await ref.read(singleHabitProvider(habitId).future);
      final loadedHabit = HabitModel.fromMap(habitData);

      // 트래킹 데이터
      final trackingData = await HabitSupabaseService.instance.getHabitTracking(habitId);

      // 카테고리 정보
      final categories = await ref.read(habitCategoriesProvider.future);
      final categoryInfo = categories[loadedHabit.type];
      final items = categoryInfo?['items'] as Map<String, dynamic>?;
      final itemData =
          items?[loadedHabit.selectedHabit] as Map<String, dynamic>?;

      // 디데이 계산
      final now = DateTime.now();
      final endDate = loadedHabit.endDate;
      final diffDay = now.difference(endDate);

      state = state.copyWith(
        habit: loadedHabit,
        ddays: diffDay.inDays,
        completedEntries: trackingData,
        currentData: itemData,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  int daysInCurrentMonth(int month) {
    final firstDayOfNextMonth = DateTime(state.currentYear, month + 1, 1);
    final lastDayOfCurrentMonth = firstDayOfNextMonth.subtract(
      const Duration(days: 1),
    );
    return lastDayOfCurrentMonth.day;
  }

  bool isDayCompleted(int day) {
    return state.completedEntries.any((entry) {
      final entryDate = DateTime.parse(entry['date']);
      return entryDate.day == day &&
          entryDate.month == state.currentMonth &&
          entryDate.year == state.currentYear;
    });
  }

  bool isStartOfDDay(int day) {
    // 예시: D-Day의 시작일인지 확인하는 로직
    // 실제 로직에 맞게 수정 필요
    return day == 1;
  }

  bool isEndOfDDay(int day) {
    // 예시: D-Day의 마지막날인지 확인하는 로직
    // 실제 로직에 맞게 수정 필요
    return day == state.lastDayOfMonth;
  }

  Future<void> handleCompletion(BuildContext context) async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    try {
      // 트래킹 완료 처리 로직
      final habitId = state.habit?.id;
      if (habitId == null) throw Exception('습관 ID가 존재하지 않습니다.');
      await HabitSupabaseService.instance.addHabitTracking(
        habitId: habitId,
        completionDate: DateTime.now(),
      );
      await loadHabitData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('오늘의 습관이 완료되었습니다!')));
    } catch (e) {
      state = state.copyWith(error: e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('완료 처리 중 오류: $e')));
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final habitTrackingProvider = StateNotifierProvider.autoDispose
    .family<HabitTrackingNotifier, HabitTrackingState, String>((ref, habitId) {
      return HabitTrackingNotifier(ref, habitId);
    });

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/habit_tracking_provider.dart' as tracking;

class HabitTrackinglScreen extends ConsumerWidget {
  final String habitId;

  const HabitTrackinglScreen({Key? key, required this.habitId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tracking.habitTrackingProvider(habitId));

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('에러: ${state.error}')),
      );
    }

    // 로딩 처리: habit이 null이면 로딩 중
    if (state.habit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get completed days as a Set<int>
    final completedDays =
        state.completedEntries.map<int>((e) {
          final entryDate = DateTime.parse(e['completion_date']);
          return entryDate.day;
        }).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFF181520),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFF181520),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 습관 설정 기간
            Text(
              '습관 설정 기간 | ${state.habit != null ? _formatDateRange(state.habit!.startDate, state.habit!.endDate) : '로딩 중...'}',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 8),

            // 진행 중인 운동
            const Text(
              '진행 중인 운동',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 운동 카드 (줄넘기 카드)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF242030),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.habit?.selectedHabit ?? '로딩 중...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.currentData?['description'] ?? '유산소 운동 중 가장 간단하고 효과적',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 습관 실행 현황
            const Text(
              '습관 실행 현황',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 통계 카드들
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '완료 횟수',
                    '${state.completedEntries.length}번',
                    '90번',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('D-day', '${state.ddays}일', '90일'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 완료 스탬프
            const Text(
              '완료 스탬프',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 월 선택
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              decoration: BoxDecoration(
                color: const Color(0xFF242030),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.currentMonth}월',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 달력 그리드
                  _buildCalendarGrid(state, completedDays),
                ],
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed:
              state.isSubmitting
                  ? null
                  : () => ref
                      .read(tracking.habitTrackingProvider(habitId).notifier)
                      .handleCompletion(context),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                completedDays.contains(state.today)
                    ? const Color(0xFF343142)
                    : const Color(0xFF724BFF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            completedDays.contains(state.today)
                ? '오늘은 이미 스탬프를 찍었어요'
                : '오늘의 습관을 완료하세요',
            style: TextStyle(
              color:
                  completedDays.contains(state.today)
                      ? Color(0xFF7E7893)
                      : Colors.white,
              fontSize: 16,
              fontFamily: 'Min Sans',
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242030),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' / $total',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    tracking.HabitTrackingState state,
    Set<int> completedDays,
  ) {
    final lastDay = state.lastDayOfMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: lastDay,
      itemBuilder: (context, index) {
        int day = index + 1;
        bool isCompleted = completedDays.contains(day);
        bool isToday = day == state.today;
        bool isFuture = DateTime(
          state.currentYear,
          state.currentMonth,
          day,
        ).isAfter(DateTime.now());

        return GestureDetector(
          onTap: () {
            if (!isFuture) {
              // Handle day tap if needed
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getCircleColor(isCompleted, isToday, isFuture),
              border: Border.all(
                color: _getBorderColor(isCompleted, isToday, isFuture),
                width: 2.5,
              ),
              boxShadow: [
               if(isToday) BoxShadow(
                  color: Color(isCompleted?0xFF7F4EFF:0x59FFFFFF),
                  blurRadius: 14,
                  offset: Offset(0, 0),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color: _getTextColor(isCompleted,isToday, isFuture),
                    fontSize: 20,
                    fontFamily: 'Renogare Soft',
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCircleColor(bool isCompleted, bool isToday, bool isFuture) {
    if (isCompleted) {
      return const Color(0xFF1E1436);
    }
    else if (!isCompleted&&isToday) {
      return const Color(0xFF514D60);
    } else {
      return const Color(0xA343404F);
    }
  }

  Color _getBorderColor(bool isCompleted, bool isToday, bool isFuture) {
   if (isCompleted) {
      return const Color(0xFFA892FF);
    } else if (isToday) {
      return const Color(0xFFAAA8B4);
    } else {
      return const Color(0xFF514D60);
    }
  }

  Color _getTextColor(bool isCompleted,bool isToday, bool isFuture) {
    if (isCompleted) {
      return const Color(0xFFB092FF);
    } else if (isToday) {
      return const Color(0xFFDEDDE2);
    } else {
      return const Color(0xFF7E7893);
    }
  }
  
  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return '로딩 중...';
    }
    
    // Format start date as YYYY. MM. DD
    final startFormatted = '${startDate.year}. ${startDate.month.toString().padLeft(2, '0')} ${startDate.day.toString().padLeft(2, '0')}';
    
    // Format end date, include year only if different from start date
    final endFormatted = startDate.year == endDate.year
        ? '${endDate.month.toString().padLeft(2, '0')} ${endDate.day.toString().padLeft(2, '0')}'
        : '${endDate.year}. ${endDate.month.toString().padLeft(2, '0')} ${endDate.day.toString().padLeft(2, '0')}';
    
    return '$startFormatted - $endFormatted';
  }
}

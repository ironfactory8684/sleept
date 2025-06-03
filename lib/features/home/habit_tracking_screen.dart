import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/habit/model/habit_model.dart';
import 'package:sleept/features/habit/service/habit_supabase_service.dart';
import 'package:sleept/providers/habit_provider.dart';

class HabitTrackinglScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitTrackinglScreen({Key? key, required this.habitId})
    : super(key: key);

  @override
  ConsumerState<HabitTrackinglScreen> createState() =>
      _HabitTrackinglScreenState();
}

class _HabitTrackinglScreenState extends ConsumerState<HabitTrackinglScreen> {
  late int currentMonth;
  late int currentYear;
  late int today;
  late int ddays;
  late int lastDayOfMonth;
  Map<String, dynamic>? currentData;
  List<Map<String, dynamic>> _completedEntries =
      []; // List to store completed dates
  HabitModel? habit;
  bool _isSubmitting = false; // 트래킹 완료 처리 중 상태
  // Helper function to get the icon for a stamp type
  IconData? _getStampIcon(String? type) {
    switch (type) {
      case 'moon':
        return Icons.nightlight_round;
      case 'water':
        return Icons.water_drop;
      case 'gear':
        return Icons.settings;
      default:
        return null;
    }
  }

  // Helper function to get the color for a stamp icon
  Color _getStampIconColor(String? type) {
    switch (type) {
      case 'moon':
        return Colors.blueAccent; // Example color
      case 'water':
        return Colors.lightBlueAccent; // Example color
      case 'gear':
        return Colors.grey; // Example color
      default:
        return Colors.transparent; // Should not happen if icon is null
    }
  }

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    currentMonth = now.month;
    currentYear = now.year;
    today = now.day;
    lastDayOfMonth = daysInCurrentMonth(currentMonth);

    // Supabase에서 데이터 로드는 didChangeDependencies에서 처리
    // 여기서는 초기화만 진행
    _completedEntries = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHabitData();
  }

  // Supabase에서 특정 습관 데이터 가져오기
  Future<void> _loadHabitData() async {
    try {
      // 1. 습관 상세 데이터 가져오기
      final habitAsync = ref.read(userHabitsProvider.future);
      final habits = await habitAsync;

      // 해당 ID의 습관 찾기
      final habitData = habits.firstWhere(
        (h) => h['id'] == widget.habitId,
        orElse: () => throw Exception('습관을 찾을 수 없습니다'),
      );

      // HabitModel로 변환
      final loadedHabit = HabitModel.fromMap(habitData);

      // 2. 해당 습관의 트래킹 데이터 가져오기
      final trackingData = await HabitSupabaseService.instance.getHabitTracking(
        widget.habitId,
      );

      // 3. 습관 타입에 따른 필요한 정보 가져오기
      final categoriesAsync = ref.read(habitCategoriesProvider.future);
      final categories = await categoriesAsync;

      // 습관 이름으로 카테고리 정보 찾기
      final categoryInfo = categories[loadedHabit.type];
      final items = categoryInfo?['items'] as Map<String, dynamic>?;
      final itemData =
          items?[loadedHabit.selectedHabit] as Map<String, dynamic>?;

      // 디데이 계산
      final now = DateTime.now();
      final endDate = loadedHabit.endDate;
      final diffDay = now.difference(endDate);

      setState(() {
        habit = loadedHabit;
        ddays = diffDay.inDays;
        _completedEntries = trackingData;
        currentData = itemData;
      });
    } catch (e) {
      print('Error loading habit data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다: $e')));
    }
  }

  int daysInCurrentMonth(month) {
    // 현재 날짜와 시간을 가져옵니다.

    // 현재 월의 다음 달 1일을 구합니다.
    // Dart의 DateTime 생성자는 month가 12를 넘어가면 자동으로 year를 증가시킵니다.
    DateTime firstDayOfNextMonth = DateTime(currentYear, month + 1, 1);

    // 다음 달 1일에서 하루를 뺍니다.
    // 이렇게 하면 현재 월의 마지막 날짜를 얻게 됩니다.
    DateTime lastDayOfCurrentMonth = firstDayOfNextMonth.subtract(
      const Duration(days: 1),
    );

    // 현재 월의 마지막 날짜에서 '일'을 가져옵니다. 이 값이 해당 월의 총 일수입니다.
    return lastDayOfCurrentMonth.day;
  }

  // Check if a specific day is in the completed entries list
  bool _isDayCompleted(int day) {
    // 로드되지 않은 경우 안전하게 체크
    if (_completedEntries.isEmpty) return false;

    // Get the date for the given day in the current month and year
    final dateToCheck = DateTime(currentYear, currentMonth, day);

    // Check if any completed entry matches this date (compare only year, month, day)
    return _completedEntries.any((entry) {
      try {
        // Supabase에서 가져온 데이터에서 날짜 값 추출
        final completionDateStr = entry['completion_date']?.toString();
        if (completionDateStr == null || completionDateStr.isEmpty)
          return false;

        final completionDate = DateTime.tryParse(completionDateStr);
        if (completionDate == null) return false;

        return completionDate.year == dateToCheck.year &&
            completionDate.month == dateToCheck.month &&
            completionDate.day == dateToCheck.day;
      } catch (e) {
        print('Error checking completion date: $e');
        return false;
      }
    });
  }

  // Helper function to check if a day is the start of the d-day
  bool _isStartOfDDay(int day) {
    if (habit == null || habit?.startDate == null) return false;

    final date = DateTime(currentYear, currentMonth, day);
    final startDate = habit?.startDate;
    if (startDate == null) return false;

    return date.year == startDate.year &&
        date.month == startDate.month &&
        date.day == startDate.day;
  }

  // Helper function to check if a day is the end of the d-day
  bool _isEndOfDDay(int day) {
    if (habit == null || habit?.endDate == null) return false;

    final date = DateTime(currentYear, currentMonth, day);
    final endDate = habit?.endDate;
    if (endDate == null) return false;

    return date.year == endDate.year &&
        date.month == endDate.month &&
        date.day == endDate.day;
  }

  // Handle the completion button press
  Future<void> _handleCompletion() async {
    // 현재 습관이 로드되지 않았다면 오류 처리
    if (habit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('습관 데이터가 로드되지 않았습니다. 다시 시도해주세요.'),
          backgroundColor: Color(0xFF724BFF),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 데이터 로딩중 중복 탭 방지
    if (mounted && context.mounted) {
      // 양시에 로딩 상태를 표시
      setState(() {
        _isSubmitting = true;
      });
    }

    // Get today's date without time
    final todayDate = DateTime(currentYear, currentMonth, today);
    // Check if today is already completed
    if (_isDayCompleted(today)) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오늘의 습관을 이미 완료했습니다.'),
            backgroundColor: Color(0xFF724BFF),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      // 1. Supabase에 트래킹 데이터 추가
      final habitId = habit?.id;
      if (habitId == null) {
        throw Exception('습관 ID가 없습니다');
      }

      // Supabase에 트래킹 데이터 추가
      await HabitSupabaseService.instance.addHabitTracking(
        habitId: habitId.toString(),
        completionDate: todayDate,
      );

      // 2. 습관 카운트 업데이트
      final currentHabit = habit;
      if (currentHabit == null) {
        throw Exception('습관 데이터가 없습니다');
      }

      final newCount = (currentHabit.count ?? 0) + 1;
      final isCompleted =
          currentHabit.duration != null && newCount >= currentHabit.duration!;

      // 습관 데이터 업데이트
      await HabitSupabaseService.instance.updateUserHabit(
        habitId: habitId.toString(),
        count: newCount,
        isCompleted: isCompleted,
      );

      // 3. Riverpod 캐시 새로고침 (선택사항)
      // ref.invalidate(userHabitsProvider);

      // 4. 데이터 다시 불러오기
      await _loadHabitData();

      // 5. 사용자에게 완료 메시지 표시
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오늘의 습관이 완료되었습니다!'),
            backgroundColor: Color(0xFF724BFF),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating habit: $e');
      // Show error to user
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // 어떤 경우라도 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildDaysRow(int startDay, int endDay) {
      return Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final day = startDay + index;
            if (day <= lastDayOfMonth && day > 0) {
              final DateTime dayDate = DateTime(currentYear, currentMonth, day);
              bool isPast = dayDate.isBefore(
                DateTime(currentYear, currentMonth, today + 1),
              );
              final bool isCompleted = _isDayCompleted(day);
              bool isStartDDay = _isStartOfDDay(day);
              bool isEndDDay = _isEndOfDDay(day);

              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isCompleted
                          ? Colors.green
                          : (day == today
                              ? Color(0xff724BFF)
                              : (!isPast
                                  ? Colors.grey[200]
                                  : Colors.transparent)),
                ),
                child: Stack(
                  children: [
                    if (isStartDDay || isEndDDay)
                      Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xffFFB906),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color:
                              isCompleted
                                  ? Colors.white
                                  : (day == today
                                      ? Colors.white
                                      : (!isPast
                                          ? Colors.blueGrey
                                          : Colors.black54)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isCompleted &&
                        currentData != null &&
                        currentData!.containsKey('stamp'))
                      Center(
                        child: Icon(
                          _getStampIcon(currentData!['stamp']),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return Container(
                width: 40,
                height: 40,
              ); // Empty placeholder for days outside the month
            }
          }),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: AppColors.mainBackground,
        centerTitle: true,

        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Information Section
              Text(
                '습관 설정 기간 | ${habit?.startDate} - ${habit?.endDate}',
                style: TextStyle(
                  color: const Color(0xFF8E8AA1) /* Primitive-Color-gray-500 */,
                  fontSize: 13,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              Text(
                '진행 중인 운동',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 343,
                padding: const EdgeInsets.all(18),
                decoration: ShapeDecoration(
                  color: const Color(0xFF242030) /* Primitive-Color-gray-900 */,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/images/${currentData?['image']}",
                          ),
                          fit: BoxFit.cover,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        SizedBox(
                          width: 223,
                          child: Text(
                            habit?.selectedHabit ?? '로드 중...',
                            style: TextStyle(
                              color: Colors.white /* Primitive-Color-White */,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 223,
                          height: 42,
                          child: Text(
                            currentData?['descript'] ?? '',
                            style: TextStyle(
                              color: Colors.white /* Primitive-Color-White */,
                              fontSize: 13,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Goal/Recommendation Section
              Container(
                width: 189,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(
                      '잠들기 3-4 시간 전 운동',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 189,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(
                      '주 4회 권장',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Progress Status Section
              Text(
                '습관 실행 현황',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: 165,
                      padding: const EdgeInsets.all(18),
                      decoration: ShapeDecoration(
                        color: const Color(
                          0xFF242030,
                        ) /* Primitive-Color-gray-900 */,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  '완료 횟수',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFB8B6C0,
                                    ) /* Primitive-Color-gray-300 */,
                                    fontSize: 15,
                                    fontFamily: 'Min Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 7,
                                    children: [
                                      Text(
                                        '${habit?.count ?? 0}번',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'Min Sans',
                                          fontWeight: FontWeight.w700,
                                          height: 1.45,
                                        ),
                                      ),
                                      Text(
                                        '/',
                                        style: TextStyle(
                                          color: const Color(0xFF666275),
                                          fontSize: 22,
                                          fontFamily: 'Min Sans',
                                          fontWeight: FontWeight.w400,
                                          height: 1.32,
                                        ),
                                      ),
                                      Text(
                                        '${habit?.duration}번',
                                        style: TextStyle(
                                          color: const Color(
                                            0xFFAAA8B4,
                                          ) /* Primitive-Color-gray-400 */,
                                          fontSize: 18,
                                          fontFamily: 'Min Sans',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      width: 165,
                      padding: const EdgeInsets.all(18),
                      decoration: ShapeDecoration(
                        color: const Color(
                          0xFF242030,
                        ) /* Primitive-Color-gray-900 */,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 12,
                              children: [
                                Text(
                                  'D-day',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFB8B6C0,
                                    ) /* Primitive-Color-gray-300 */,
                                    fontSize: 15,
                                    fontFamily: 'Min Sans',
                                    fontWeight: FontWeight.w400,
                                    height: 1.50,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 7,
                                    children: [
                                      Text(
                                        '${ddays}일',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'Min Sans',
                                          fontWeight: FontWeight.w700,
                                          height: 1.45,
                                        ),
                                      ),
                                      Text(
                                        '/',
                                        style: TextStyle(
                                          color: const Color(0xFF666275),
                                          fontSize: 22,
                                          fontFamily: 'Min Sans',
                                          fontWeight: FontWeight.w400,
                                          height: 1.32,
                                        ),
                                      ),
                                      Text(
                                        '${habit?.duration}일',
                                        style: TextStyle(
                                          color: const Color(
                                            0xFFAAA8B4,
                                          ) /* Primitive-Color-gray-400 */,
                                          fontSize: 18,
                                          fontFamily: 'Min Sans',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
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
              const SizedBox(height: 24),

              // Completion Stamp Calendar
              Text(
                '완료 스탬프',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF242030),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '습관명: ${habit?.selectedHabit ?? '로드 중...'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDaysRow(1, 7),
                      _buildDaysRow(8, 14),
                      _buildDaysRow(15, 21),
                      _buildDaysRow(22, 28),
                      _buildDaysRow(29, lastDayOfMonth),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 17.0,
                              mainAxisSpacing: 17.0,
                            ),
                        itemCount:
                            lastDayOfMonth, // Number of days in the month
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final isToday = day == today;
                          // Check if the day has been completed based on loaded data
                          final isCompleted = _isDayCompleted(day);

                          // Determine if the day is in the future relative to today
                          // This is a basic check; for robust implementation, consider the habit's start/end dates.
                          final isFutureDay = DateTime(
                            currentYear,
                            currentMonth,
                            day,
                          ).isAfter(
                            DateTime.now().subtract(const Duration(hours: 24)),
                          ); // Treat today as not future

                          return InkWell(
                            onTap:
                                isFutureDay
                                    ? null
                                    : () {
                                      // TODO: Optional: Handle tapping on historical completed days
                                      print(
                                        'Tapped day: $day (Completed: $isCompleted)',
                                      );
                                    },
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isToday
                                        ? const Color(
                                          0xFF514D60,
                                        ) // Today's background
                                        : isCompleted
                                        ? const Color(
                                          0xFF1E1436,
                                        ) // Completed day background
                                        : isFutureDay
                                        ? Colors.grey[800]?.withOpacity(
                                          0.5,
                                        ) // Future day background (slightly dimmed)
                                        : Colors
                                            .grey[800], // Past incomplete day background

                                border:
                                    isToday
                                        ? Border.all(
                                          // Border for today
                                          width: 2.50,
                                          strokeAlign:
                                              BorderSide.strokeAlignCenter,
                                          color: const Color(0xFFAAA8B4),
                                        )
                                        : isCompleted
                                        ? Border.all(
                                          // Border for completed days
                                          width: 2.50,
                                          strokeAlign:
                                              BorderSide.strokeAlignCenter,
                                          color: const Color(0xFFA892FF),
                                        )
                                        : null, // No border for other days
                                boxShadow:
                                    isToday
                                        ? [
                                          // Shadow for today
                                          BoxShadow(
                                            color: Color(0x59FFFFFF),
                                            blurRadius: 14,
                                            offset: Offset(0, 0),
                                            spreadRadius: 0,
                                          ),
                                        ]
                                        : null, // No shadow for other days
                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    color:
                                        isToday
                                            ? const Color(
                                              0xFFDEDDE2,
                                            ) // Text color for today
                                            : isCompleted
                                            ? const Color(
                                              0xFFB092FF,
                                            ) // Text color for completed days
                                            : isFutureDay
                                            ? Colors.white70?.withOpacity(
                                              0.5,
                                            ) // Text color for future days
                                            : Colors
                                                .white70, // Text color for past incomplete days
                                    fontSize: 20,
                                    fontFamily: 'Renogare Soft',
                                    fontWeight: FontWeight.w400,
                                    height: 1.35,
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isSubmitting
                    ? const Color(0xFF4D34B3)
                    : const Color(0xFF724BFF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: _isSubmitting ? 0 : 4,
            shadowColor:
                _isSubmitting
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isSubmitting ? null : _handleCompletion,
          child:
              _isSubmitting
                  ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '완료 처리중...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                    ],
                  )
                  : const Text(
                    '오늘도 습관 실행완료!',
                    style: TextStyle(
                      color: Colors.white,
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
}

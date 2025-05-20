import 'package:flutter/material.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/constants/habit_datas.dart';

import '../habit/service/habit_database.dart';
import '../habit/model/tracking_entry.dart';

class HabitTrackinglScreen extends StatefulWidget {
  final HabitModel habit;

  const HabitTrackinglScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitTrackinglScreenState createState() => _HabitTrackinglScreenState();
}

class _HabitTrackinglScreenState extends State<HabitTrackinglScreen> {
  late int currentMonth;
  late int currentYear;
  late int today;
  late int ddays;
  late int lastDayOfMonth;
  late Map<String, dynamic> currentData;
  List<TrackingEntry> _completedEntries = []; // List to store completed dates
  late HabitModel habit;
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
    // TODO: implement initState
    super.initState();
    habit = widget.habit;
    var now = DateTime.now();
    currentMonth = now.month;
    currentYear = now.year;
    today = now.day;
    var diffday =now.difference(widget.habit.endDate);
    ddays =diffday.inDays;
    lastDayOfMonth = daysInCurrentMonth(currentMonth);
    currentData = habitData[habit.type]['items'][habit.selectedHabit];
    _loadTrackingData();
  }

  Future<void> _loadTrackingData() async {
    if (habit.id != null) {
      final entries = await HabitDatabase.instance.readTrackingForHabit(habit.id!);
      setState(() {
        _completedEntries = entries;
      });
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
    // Get the date for the given day in the current month and year
    final dateToCheck = DateTime(currentYear, currentMonth, day);

    // Check if any completed entry matches this date (compare only year, month, day)
    return _completedEntries.any((entry) =>
    entry.completionDate.year == dateToCheck.year &&
        entry.completionDate.month == dateToCheck.month &&
        entry.completionDate.day == dateToCheck.day);
  }


  // Handle the completion button press
  Future<void> _handleCompletion() async {
    // Get today's date without time
    final todayDate = DateTime(currentYear, currentMonth, today);
    // Check if today is already completed
    if (_isDayCompleted(today)) {
      print('Habit already completed today!');
      // Optionally show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘의 습관을 이미 완료했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Ensure habit ID is not null before saving
    if (habit.id == null) {
      print('Error: Habit ID is null, cannot save tracking.');
      // Optionally show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('습관 정보를 찾을 수 없습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create a new tracking entry
    final newEntry = TrackingEntry(
      habitId: habit.id!,
      completionDate: todayDate, // Use today's date
    );

    try {
      // Save the tracking entry to the database
      await HabitDatabase.instance.createTracking(newEntry);

      // Update the habit's count (optional, but common)
      final updatedHabit = habit.copy(count: (habit.count ?? 0) + 1);
      await HabitDatabase.instance.updateHabit(updatedHabit);


      // Reload tracking data and update the UI
      await _loadTrackingData(); // Reload all entries to update the list


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘의 습관을 완료했습니다!'),
          duration: Duration(seconds: 2),
        ),
      );


    } catch (e) {
      print('Error saving tracking data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('습관 완료 처리에 실패했습니다: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {

    // final habitData = habitData;
    //
    // final completionDays = habit['completionDays'] as List<Map<String, dynamic>>; // Cast for safety
    //
    // // Find today's day in the completionDays list (for highlighting)
    // final today = DateTime.now().day;
    // final todayCompletion = completionDays.firstWhere(
    //       (dayData) => dayData['day'] == today,
    //   orElse: () => {'day': today, 'type': null}, // Default if today not found
    // );
    // final todayIsStamped = todayCompletion['type'] != null; // Check if today has a stamp


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
                '습관 설정 기간 | ${habit.startDate} - ${habit.endDate}',
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
                            "assets/images/${currentData['image']}",
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
                            habit.selectedHabit,
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
                            currentData['descript'],
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
                                        '${habit.count}번',
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
                                        '${habit.duration}번',
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
                                        '${habit.duration}일',
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
              Text('완료 스탬프', style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Min Sans',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),),
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
                            '$currentMonth월',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down,color: Colors.white,),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 17.0,
                          mainAxisSpacing: 17.0,
                        ),
                        itemCount: lastDayOfMonth, // Number of days in the month
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final isToday = day == today;
                          // Check if the day has been completed based on loaded data
                          final isCompleted = _isDayCompleted(day);

                          // Determine if the day is in the future relative to today
                          // This is a basic check; for robust implementation, consider the habit's start/end dates.
                          final isFutureDay = DateTime(currentYear, currentMonth, day).isAfter(DateTime.now().subtract(const Duration(hours: 24))); // Treat today as not future

                          return InkWell(
                            onTap: isFutureDay ? null : () {
                              // TODO: Optional: Handle tapping on historical completed days
                              print('Tapped day: $day (Completed: $isCompleted)');
                            },
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday ?
                                const Color(0xFF514D60) // Today's background
                                    : isCompleted ?
                                const Color(0xFF1E1436) // Completed day background
                                    : isFutureDay ?
                                Colors.grey[800]?.withOpacity(0.5) // Future day background (slightly dimmed)
                                    : Colors.grey[800], // Past incomplete day background

                                border: isToday ?
                                Border.all( // Border for today
                                  width: 2.50,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: const Color(0xFFAAA8B4),
                                )
                                    : isCompleted ?
                                Border.all( // Border for completed days
                                  width: 2.50,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: const Color(0xFFA892FF),
                                )
                                    : null, // No border for other days
                                boxShadow: isToday ? [ // Shadow for today
                                  BoxShadow(
                                    color: Color(0x59FFFFFF),
                                    blurRadius: 14,
                                    offset: Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ] : null, // No shadow for other days

                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    color: isToday ?
                                    const Color(0xFFDEDDE2) // Text color for today
                                        : isCompleted ?
                                    const Color(0xFFB092FF) // Text color for completed days
                                        : isFutureDay ?
                                    Colors.white70?.withOpacity(0.5) // Text color for future days
                                        : Colors.white70, // Text color for past incomplete days
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
            backgroundColor: AppColors.primary, // 버튼 배경색 (예시)
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _handleCompletion,
          child: const Text(
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

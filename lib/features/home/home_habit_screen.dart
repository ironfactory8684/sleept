import 'package:flutter/material.dart';
import 'package:sleept/features/home/components/habit_card.dart';
import 'package:sleept/features/habit/service/habit_database.dart';
import 'package:sleept/constants/colors.dart';

class HomeHabitScreen extends StatefulWidget {
  const HomeHabitScreen({super.key});

  @override
  State<HomeHabitScreen> createState() => _HomeHabitScreenState();
}

class _HomeHabitScreenState extends State<HomeHabitScreen> {
  List<HabitModel> _habits = [];
  bool _isLoading = true;

  // dateRange: 7 days before to 7 days after today
  List<DateTime> get dateRange {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    return List.generate(15, (i) => start.add(Duration(days: i)));
  }

  int selectedDateIndex = 7; // default to today at center of dateRange

  int _selectedFilter = 0;
  List<HabitModel> get _displayedHabits {
    if (_habits.isEmpty) return [];
    final selected = DateTime(
      dateRange[selectedDateIndex].year,
      dateRange[selectedDateIndex].month,
      dateRange[selectedDateIndex].day,
    );
    return _habits.where((h) {
      final start = DateTime(h.startDate.year, h.startDate.month, h.startDate.day);
      final end = DateTime(h.endDate.year, h.endDate.month, h.endDate.day);
      final matchesDate = !start.isAfter(selected) && !end.isBefore(selected);
      if (_selectedFilter == 0) {
        return matchesDate && !h.isCompleted;
      } else {
        return matchesDate && h.isCompleted;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitDatabase.instance.readAllHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dateRange.length,
            itemBuilder: (context, index) {
              final date = dateRange[index];
              final isSelected = index == selectedDateIndex;
              final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDateIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 12,
                  ),
                  margin: EdgeInsets.only(right: 15),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          isSelected
                              ? BorderSide(
                                width: 1.50,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: const Color(
                                  0xFF724BFF,
                                ) /* Primary-Color */,
                              )
                              : BorderSide(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 2,
                    children: [
                      Text(
                        '${date.day}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(
                            0xFF8E6FFF,
                          ) /* Primitive-Color-Purple-400 */,
                          fontSize: 14,
                          fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                      Text(
                        ['일','월','화','수','목','금','토'][date.weekday % 7],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(
                            0xFF8E6FFF,
                          ) /* Primitive-Color-Purple-400 */,
                          fontSize: 16,
                          fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                      if (isToday)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${_displayedHabits.length}개',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Min Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  color: const Color(0xFF242030) /* Primitive-Color-gray-900 */,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 1,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _selectedFilter = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color:
                              _selectedFilter == 0
                                  ? AppColors.primary
                                  : const Color(0xFF242030),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              '진행중',
                              style: TextStyle(
                                color: Colors.white /* Primitive-Color-White */,
                                fontSize: 13,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedFilter = 1),
                      child: Container(
                        width: 54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color:
                              _selectedFilter == 1
                                  ? AppColors.primary
                                  : const Color(0x00000000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              '완료',
                              style: TextStyle(
                                color:
                                    _selectedFilter == 1
                                        ? Colors.white
                                        : const Color(
                                          0xFF8E8AA1,
                                        ) /* Primitive-Color-gray-500 */,
                                fontSize: 13,
                                fontFamily: 'Min Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // List of saved habits
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _habits.isEmpty
                  ? const Center(child: Text('습관이 없습니다.'))
                  : ListView.builder(
                    itemCount: _displayedHabits.length,
                    itemBuilder: (context, index) {
                      final habit = _displayedHabits[index];
                      print(habit.selectedHabit);
                      return HabitCard(data:habit);

                    },
                  ),
        ),
      ],
    );
  }
}

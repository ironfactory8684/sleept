import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleept/features/home/components/habit_card.dart';
import 'package:sleept/features/habit/service/habit_database.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/providers/habit_provider.dart';

class HomeHabitScreen extends ConsumerStatefulWidget {
  const HomeHabitScreen({super.key});

  @override
  ConsumerState<HomeHabitScreen> createState() => _HomeHabitScreenState();
}

class _HomeHabitScreenState extends ConsumerState<HomeHabitScreen> {
  late final List<DateTime> dateRange;
  late int selectedDateIndex;
  final ScrollController _dateScrollController = ScrollController();
  List<HabitModel> _habits = [];
  bool _isLoading = true;

  int _selectedFilter = 0;

  List<HabitModel> get _displayedHabits {
    if (_habits.isEmpty) return [];
    
    // 선택된 날짜가 습관의 시작일과 종료일 사이에 있는지 확인
    final selected = dateRange[selectedDateIndex];
    
    return _habits.where((habit) {
      // 시작일부터 종료일까지의 기간에 선택된 날짜가 포함되는지 확인
      final start = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
      final end = DateTime(habit.endDate.year, habit.endDate.month, habit.endDate.day);
      
      final matchesDate = !start.isAfter(selected) && !end.isBefore(selected);
      
      final isCompleted = habit.isCompleted == true;
      
      if (_selectedFilter == 0) {
        return matchesDate && !isCompleted;
      } else {
        return matchesDate && isCompleted;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // dateRange를 한 번만 생성
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    dateRange = List.generate(15, (i) => start.add(Duration(days: i)));
    // 오늘 날짜 인덱스 계산
    final today = DateTime.now();
    final idx = dateRange.indexWhere((d) =>
      d.year == today.year && d.month == today.month && d.day == today.day);
    selectedDateIndex = idx != -1 ? idx : 7;
    // 빌드 후 중앙으로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDate());
  }

  void _scrollToSelectedDate() {
    // 날짜 셀의 width + margin (실제 UI에 맞게 조절)
    const itemWidth = 51.0; // 패딩+마진 합산(예시)
    final screenWidth = MediaQuery.of(context).size.width;
    final offset = (selectedDateIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    if (_dateScrollController.hasClients) {
      _dateScrollController.jumpTo(offset.clamp(0, _dateScrollController.position.maxScrollExtent));
    }
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  void _onDateTap(int index) {
    setState(() {
      selectedDateIndex = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDate());
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHabitsFromSupabase();
  }

  Future<void> _loadHabitsFromSupabase() async {
    try {
      // Riverpod으로 사용자 습관 데이터 로드
      final habitsAsync = ref.read(userHabitsProvider.future);
      final habitsData = await habitsAsync;
      
      // HabitDatabase의 HabitModel 형식으로 변환
      final habitModels = habitsData.map((data) {
        // Supabase 데이터를 HabitModel에 맞게 변환
        final habitId = data['id'] ?? '';
        final type = data['type']?.toString() ?? '';
        final selectedHabit = data['selected_habit']?.toString() ?? '';
        final startDateStr = data['start_date']?.toString();
        final endDateStr = data['end_date']?.toString();
        final count = data['count'] is int ? data['count'] : 0;
        final duration = data['duration'] is int ? data['duration'] : 0;
        final isCompleted = data['is_completed'] == true;

        print(data);
        return HabitModel(
          id: habitId,
          type: type,
          selectedHabit: selectedHabit,
          startDate: startDateStr != null ? DateTime.tryParse(startDateStr) ?? DateTime.now() : DateTime.now(),
          endDate: endDateStr != null ? DateTime.tryParse(endDateStr) ?? DateTime.now().add(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30)),
          count: count,
          duration: duration,
          isCompleted: isCompleted,
        );
      }).toList();
      
      setState(() {
        _habits = habitModels;
        _isLoading = false;
        // 오늘 날짜 인덱스를 한 번 더 동기화 (습관 데이터 로드 후)
        final now = DateTime.now();
        final idx = dateRange.indexWhere((d) =>
          d.year == now.year && d.month == now.month && d.day == now.day);
        print(idx);
        selectedDateIndex = idx != -1 ? idx : 7;
      });
    } catch (e) {
      print('Error loading habits from Supabase: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 73,
          child: ListView.builder(
            controller: _dateScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: dateRange.length,
            itemBuilder: (context, index) {
              final date = dateRange[index];
              final isSelected = index == selectedDateIndex;
              final isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              return GestureDetector(
                onTap: () => _onDateTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 12,
                  ),
                  margin: EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFF242030),
                    border: Border.all(color: Color(
                      isSelected ? 0xFF724BFF : 0xFF403C4F,
                    ) /* Primary-Color */,),
                      borderRadius: BorderRadius.circular(8),
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
                          color: Color(
                            isSelected ? 0xFF8E6FFF : 0xFFB8B6C0,
                          ) /* Primitive-Color-Purple-400 */,
                          fontSize: 14,
                          fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                      Text(
                        ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(
                            isSelected ? 0xFF8E6FFF : 0xFFB8B6C0,
                          ) /* Primitive-Color-Purple-400 */,
                          fontSize: 16,
                          fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
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
                  ? const Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff724BFF)),
                    ))
                  : _habits.isEmpty
                  ? const Center(child: Text('습관이 없습니다.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ))
                  : ListView.builder(
                    itemCount: _displayedHabits.length,
                    itemBuilder: (context, index) {
                      // 습관 데이터 사용
                      final habit = _displayedHabits[index];

                      return HabitCard(data: habit);
                    },
                  ),
        ),
      ],
    );
  }
}

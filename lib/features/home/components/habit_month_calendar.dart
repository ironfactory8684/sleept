import 'package:flutter/material.dart';

class HabitMonthCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Set<int> completedDays;
  final int? today;

  const HabitMonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.completedDays,
    this.today,
  });

  @override
  Widget build(BuildContext context) {
    final lastDay = DateUtils.getDaysInMonth(year, month);
    final rows = <Widget>[];

    for (int i = 1; i <= lastDay; i += 7) {
      final days = List.generate(
        (i + 6 <= lastDay) ? 7 : lastDay - i + 1,
        (index) => i + index,
      );
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: days.map((day) {
            final isCompleted = completedDays.contains(day);
            final isToday = day == today;
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: HabitDayCircle(
                day: day,
                isCompleted: isCompleted,
                isToday: isToday,
              ),
            );
          }).toList(),
        ),
      );
    }

    return Column(
      children: [
        ...rows,
      ],
    );
  }
}

class HabitDayCircle extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;

  const HabitDayCircle({
    super.key,
    required this.day,
    required this.isCompleted,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color textColor;
    Color bgColor;

    if (isCompleted) {
      borderColor = const Color(0xFFA892FF);
      textColor = const Color(0xFFB092FF);
      bgColor = const Color(0xFF1E1436);
    } else {
      borderColor = const Color(0xFF514D60);
      textColor = const Color(0xFF7E7893);
      bgColor = const Color(0xA343404F);
    }

    if (isToday) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: _circleContent(day, borderColor, textColor, bgColor),
      );
    }

    return _circleContent(day, borderColor, textColor, bgColor);
  }

  Widget _circleContent(int day, Color borderColor, Color textColor, Color bgColor) {
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2.5,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontFamily: 'Renogare Soft',
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

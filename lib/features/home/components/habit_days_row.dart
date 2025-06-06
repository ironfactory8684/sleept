import 'package:flutter/material.dart';
import '../../habit/model/habit_model.dart';
import '../utils/habit_icon_utils.dart';

class HabitDaysRow extends StatelessWidget {
  final int startDay;
  final int endDay;
  final int lastDayOfMonth;
  final int currentYear;
  final int currentMonth;
  final int today;
  final Map<String, dynamic>? currentData;
  final bool Function(int) isDayCompleted;
  final bool Function(int) isStartOfDDay;
  final bool Function(int) isEndOfDDay;

  const HabitDaysRow({
    Key? key,
    required this.startDay,
    required this.endDay,
    required this.lastDayOfMonth,
    required this.currentYear,
    required this.currentMonth,
    required this.today,
    required this.currentData,
    required this.isDayCompleted,
    required this.isStartOfDDay,
    required this.isEndOfDDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            final bool completed = isDayCompleted(day);
            bool isStartDDay = isStartOfDDay(day);
            bool isEndDDay = isEndOfDDay(day);

            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed
                    ? Colors.green
                    : (day == today
                        ? const Color(0xff724BFF)
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
                            color: const Color(0xffFFB906),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: completed
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
                  if (completed &&
                      currentData != null &&
                      currentData!.containsKey('stamp'))
                    Center(
                      child: Icon(
                        getStampIcon(currentData!['stamp']),
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
}

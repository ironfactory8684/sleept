import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가 (pubspec.yaml에 intl 추가 필요)

class HabitDialog extends StatefulWidget {

  const HabitDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<HabitDialog> createState() => _HabitDialogState();
}

class _HabitDialogState extends State<HabitDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now(); // 시작일을 오늘 날짜로 초기화
    _endDate = DateTime.now().add(const Duration(days: 90)); // 끝나는 날을 오늘로부터 90일 뒤로 초기화 (예시)
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate.add(const Duration(days: 1)), // 시작일 다음날부터 선택 가능
      lastDate: DateTime(2101),
      builder: (context, child) { // 테마 적용 (선택 사항)
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF724BFF), // 주요 색상
              onPrimary: Colors.white, // 주요 색상 위의 텍스트/아이콘 색상
              surface: Color(0xFF242030), // 다이얼로그 배경색
              onSurface: Colors.white, // 다이얼로그 위의 텍스트/아이콘 색상
            ),
            dialogBackgroundColor: const Color(0xFF343142),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜를 'xxxx년 xx월 xx일' 형식으로 포맷
    String formattedStartDate = DateFormat('yyyy년 M월 d일', 'ko_KR').format(_startDate);
    String formattedEndDate = DateFormat('yyyy년 M월 d일', 'ko_KR').format(_endDate);

    return Dialog( // AlertDialog 또는 Dialog 위젯 사용
      backgroundColor: Colors.transparent, // Dialog 자체 배경은 투명하게
      child: Container(
        width: 327,
        padding: const EdgeInsets.all(18),
        decoration: ShapeDecoration(
          color: const Color(0xFF242030), // Primitive-Color-gray-900
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 선택된 운동 목록 표시 (선택 사항)
            // if (widget.selectedExercises.isNotEmpty) ...[
            //   Text(
            //     '선택된 운동 습관',
            //     style: TextStyle(
            //       color: Colors.yellow[700],
            //       fontSize: 14,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            //   const SizedBox(height: 4),
            //   Wrap(
            //     spacing: 6.0,
            //     runSpacing: 4.0,
            //     children: widget.selectedExercises
            //         .map((exercise) => Chip(
            //       label: Text(exercise, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            //       backgroundColor: Colors.grey[700],
            //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //     ))
            //         .toList(),
            //   ),
            //   const SizedBox(height: 20),
            // ],

            // 시작한 날
            const Text(
              '시작한 날',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                // fontFamily: 'Min Sans', // 폰트가 프로젝트에 추가되어 있어야 함
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedStartDate, // 동적으로 현재 날짜 표시
              style: const TextStyle(
                color: Color(0xFFB8B6C0), // Primitive-Color-gray-300
                fontSize: 14,
                // fontFamily: 'Min Sans',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 20), // 간격

            // 끝나는 날
            const Text(
              '끝나는 날',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                // fontFamily: 'Min Sans',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 8),
            InkWell( // 터치 가능하게 InkWell 사용
              onTap: () => _selectEndDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: const Color(0xFF343142), // Primitive-Color-gray-800
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formattedEndDate, // 선택된 끝나는 날짜 표시
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        // fontFamily: 'Min Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today, // 달력 아이콘
                      color: Colors.white70,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32), // 간격

            // 버튼 영역
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFB8B6C0), // Primitive-Color-gray-300
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.white, // Primitive-Color-White
                          fontSize: 16,
                          // fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // 버튼 사이 간격
                // 완료 버튼
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // 완료 로직: 선택된 날짜 정보를 반환
                        final result = {
                          'startDate': _startDate,
                          'endDate': _endDate,
                        };
                        Navigator.of(context).pop(result);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF724BFF), // Primary-Color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          // fontFamily: 'Min Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
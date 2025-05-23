import 'package:flutter/material.dart';

import '../../../components/time_slot_picker.dart';
import '../../../constants/colors.dart';

class BuildTimePickerSection extends StatelessWidget {
  final int selectedHour;
  final int selectedMinute;
  final Function(int, int) onTimeChanged;
  const BuildTimePickerSection({
    super.key,
    required this.selectedHour,
    required this.selectedMinute,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child:
      // 시간 선택 위젯
      TimeSlotPicker(
        is24HourFormat: false, // 12시간 형식 유지
        initialHour: selectedHour, // 초기 시간 설정
        initialMinute: selectedMinute, // 초기 분 설정
        onTimeChanged:onTimeChanged,
        //     (hours, minutes) {
        //   // 즉시 상태 업데이트 방지 (선택 완료 시 업데이트) -> TimeSlotPicker 내부 로직에 따라 다름
        //   setState(() {
        //     _selectedHour = hours;
        //     _selectedMinute = minutes;
        //   });
        // },
      ),
      // Stack(
      //   alignment: Alignment.center,
      //   children: [
      //     // 중앙 하이라이트 영역
      //     // Positioned(
      //     //   child: Container(
      //     //     width: double.infinity,
      //     //     height: 80,
      //     //     decoration: BoxDecoration(
      //     //       gradient: LinearGradient(
      //     //         begin: Alignment.topCenter,
      //     //         end: Alignment.bottomCenter,
      //     //         colors: [
      //     //           AppColors.mainBackground.withOpacity(0.0), // 투명도 조절
      //     //           AppColors.mainBackground.withOpacity(0.4),
      //     //           AppColors.mainBackground.withOpacity(0.0),
      //     //         ],
      //     //         stops: const [0.0, 0.5, 1.0],
      //     //       ),
      //     //     ),
      //     //   ),
      //     // ),
      //
      //     // 왼쪽 그라데이션 오버레이
      //     // Positioned(
      //     //   left: 0,
      //     //   child: Container(
      //     //     width: 50,
      //     //     height: 200,
      //     //     decoration: BoxDecoration(
      //     //       gradient: LinearGradient(
      //     //         begin: Alignment.centerLeft,
      //     //         end: Alignment.centerRight,
      //     //         colors: [
      //     //           AppColors.mainBackground,
      //     //           AppColors.mainBackground.withOpacity(0.6),
      //     //           Colors.transparent,
      //     //         ],
      //     //         stops: const [0.0, 0.6, 1.0],
      //     //       ),
      //     //     ),
      //     //   ),
      //     // ),
      //
      //     // 오른쪽 그라데이션 오버레이
      //     // Positioned(
      //     //   right: 0,
      //     //   child: Container(
      //     //     width: 50,
      //     //     height: 200,
      //     //     decoration: BoxDecoration(
      //     //       gradient: LinearGradient(
      //     //         begin: Alignment.centerRight,
      //     //         end: Alignment.centerLeft,
      //     //         colors: [
      //     //           AppColors.mainBackground,
      //     //           AppColors.mainBackground.withOpacity(0.6),
      //     //           Colors.transparent,
      //     //         ],
      //     //         stops: const [0.0, 0.6, 1.0],
      //     //       ),
      //     //     ),
      //     //   ),
      //     // ),
      //
      //     // 시간 선택 위젯
      //     TimeSlotPicker(
      //       is24HourFormat: false, // 12시간 형식 유지
      //       initialHour: selectedHour, // 초기 시간 설정
      //       initialMinute: selectedMinute, // 초기 분 설정
      //       onTimeChanged:onTimeChanged,
      //       //     (hours, minutes) {
      //       //   // 즉시 상태 업데이트 방지 (선택 완료 시 업데이트) -> TimeSlotPicker 내부 로직에 따라 다름
      //       //   setState(() {
      //       //     _selectedHour = hours;
      //       //     _selectedMinute = minutes;
      //       //   });
      //       // },
      //     ),
      //   ],
      // ),
    );
  }
}

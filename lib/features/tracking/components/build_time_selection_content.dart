import 'package:flutter/material.dart';

import '../../../components/am_pm_selector.dart';
import '../../../constants/colors.dart';
import 'build_time_picker_section.dart';
import '../tracking_setting_screen.dart';

class BuildTimeSelectionContent extends StatelessWidget {
  final VoidCallback startTracking;
  final int selectedHour;
  final int selectedMinute;
  final bool isAm;
  final Function(int, int) onTimeChanged;
  final Function(bool) onChangeAmPm;
  const BuildTimeSelectionContent({
    super.key,
    required this.isAm,
    required this.startTracking,
    required this.selectedHour,
    required this.selectedMinute,
    required this.onTimeChanged,
    required this.onChangeAmPm,

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Balancing the row
              const Text(
                '몇 시에 일어날까요?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const TrackingSettingScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // 시간 선택 위젯 (기존 코드 유지)
        BuildTimePickerSection(
            selectedHour:selectedHour,
            selectedMinute: selectedMinute,
            onTimeChanged: onTimeChanged,
        ),

        const SizedBox(height: 40),

        // AM/PM 선택
        AmPmSelector(
          isAm: isAm,
          onChanged: onChangeAmPm

          //     (value) {
          //   setState(() {
          //     _isAm = value;
          //   });
          // },
        ),

        const Spacer(),

        // 트래킹 시작 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: startTracking, // _startTracking 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                '수면 트래킹 시작',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24), // 하단 여백
      ],
    );
  }
}

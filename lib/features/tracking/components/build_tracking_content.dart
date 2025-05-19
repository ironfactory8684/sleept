import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/colors.dart';
import '../../../utils/fomating/sleept_formater.dart';

class BuildTrackingContent extends StatelessWidget {
  final VoidCallback stopTracking;
  final int displayHour;
  final String displayMinute;
  final String displayAmPm;
  final bool isSnoring;
  final Duration remainingTime;
  const BuildTrackingContent({
    super.key,
    required this.stopTracking,
    required this.displayHour,
    required this.displayMinute,
    required this.displayAmPm,
    required this.isSnoring, required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isSnoring)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              '😴 코골이 감지 중',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        // 알람 설정 버튼 (기존 코드 유지)
        // Container( ... 알람음 및 진동 설정 버튼 ... )
        const Spacer(),
        // 시간 및 남은 시간 표시
        Text(
          "${SleeptFormater.formatDuration(remainingTime)} 뒤에 깨어드릴게요", // 남은 시간 표시
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'MinSans',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        // 목표 기상 시간
        Text(
          '$displayHour : $displayMinute', // AM/PM 표시 추가
          style: const TextStyle(
            color: Colors.white,
            fontSize: 74,
            fontFamily: 'MinSans',
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),

        GestureDetector(
          onTap: () {},
          child: Container(
            width: 162,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/time.svg'),
                SizedBox(width: 5),
                Text(
                  '알람음 및 진동 설정',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 51),
        // 트래킹 중단 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: stopTracking, // _stopTracking 함수 호출
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF353142), // 중단 버튼 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                '수면 트래킹 중단',
                style: TextStyle(
                  color: Color(0xFF7E7993), // 중단 버튼 텍스트 색상
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24), // 하단 여백 (네비게이션 바 제외)
        // 하단 네비게이션 바는 HomeNavigation 에서 관리하므로 여기서는 제거
      ],
    );
  }
}

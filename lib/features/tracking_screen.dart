import 'dart:async'; // Timer 추가

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleept/components/am_pm_selector.dart';
import 'package:sleept/components/time_slot_picker.dart';
import 'package:sleept/constants/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'dart:typed_data';
import 'package:sleept/services/habit_database.dart';
import 'package:sleept/models/snoring_event.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isAm = true;
  int _selectedHour = 8;
  int _selectedMinute = 0;
  bool _isTracking = false; // 트래킹 상태 추가
  Timer? _timer; // 카운트다운 타이머
  Duration _remainingTime = Duration.zero; // 남은 시간
  late final FlutterAudioCapture _audioCapture;
  bool _isSnoring = false;
  DateTime? _snoreStartTime;

  @override
  void initState() {
    super.initState();
    _audioCapture = FlutterAudioCapture();
  }

  // 알람 시간과 현재 시간 차이 계산 및 상태 업데이트
  void _updateRemainingTime() {
    // final now = TimeOfDay.now();

    // 24시간 형식으로 변환
    int targetHour = _selectedHour;
    if (!_isAm && targetHour != 12) {
      targetHour += 12;
    } else if (_isAm && targetHour == 12) {
      targetHour = 0; // 자정
    }

    final nowDateTime = DateTime.now();
    DateTime targetDateTime = DateTime(
      nowDateTime.year,
      nowDateTime.month,
      nowDateTime.day,
      targetHour,
      _selectedMinute,
    );

    // 목표 시간이 현재 시간보다 이전이면 다음 날로 설정
    if (targetDateTime.isBefore(nowDateTime)) {
      targetDateTime = targetDateTime.add(const Duration(days: 1));
    }

    setState(() {
      _remainingTime = targetDateTime.difference(nowDateTime);
    });

    // 남은 시간이 0 이하가 되면 타이머 중지 및 알람 로직 (추후 구현)
    if (_remainingTime.inSeconds <= 0) {
      _stopTracking();
      // TODO: 여기에 알람 울리는 로직 추가 (flutter_local_notifications 사용)
      print("알람 시간!");
    }
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    // return '$hours시간 $minutes분 뒤에 깨워드릴게요'; // 기존 방식
    return '${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분'; // 시:분:초 형식
  }

  // 트래킹 시작 함수
  Future<void> _startTracking() async {
    setState(() {
      _isTracking = true;
    });
    await _startAudioCapture();
    _updateRemainingTime(); // 즉시 남은 시간 계산
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  // 트래킹 중지 함수
  void _stopTracking() {
    _timer?.cancel();
    if (_isSnoring && _snoreStartTime != null) {
      final endTime = DateTime.now();
      HabitDatabase.instance.createSnoringEvent(
          SnoringEvent(startTime: _snoreStartTime!, endTime: endTime));
      _snoreStartTime = null;
    }
    _audioCapture.stop();
    setState(() {
      _isTracking = false;
      _remainingTime = Duration.zero;
      _isSnoring = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 위젯 제거 시 타이머 취소
    _audioCapture.stop();
    super.dispose();
  }

  // 오디오 캡처 및 FFT 기반 코골이 감지 시작
  Future<void> _startAudioCapture() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;
    await _audioCapture.start(
      (data) {
        final pcm = data as Float32List;
        // simple energy detection (sum of squares)
        final double energy = pcm.fold(0.0, (a, b) => a + b * b);
        final bool snoring = energy > 1000; // threshold may require tuning
        if (snoring && !_isSnoring) {
          _snoreStartTime = DateTime.now();
          setState(() => _isSnoring = true);
        } else if (!snoring && _isSnoring) {
          final endTime = DateTime.now();
          HabitDatabase.instance.createSnoringEvent(
              SnoringEvent(startTime: _snoreStartTime!, endTime: endTime));
          _snoreStartTime = null;
          setState(() => _isSnoring = false);
        }
      },
      (error) {
        debugPrint('Audio capture error: $error');
      },
      sampleRate: 44100,
      bufferSize: 1024,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 상태바 스타일 설정
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        // 트래킹 중 배경색 변경 고려
        statusBarBrightness: _isTracking ? Brightness.dark : Brightness.light,
      ),
    );

    // 시간 표시 형식 설정 (트래킹 화면용)
    final displayHour =
        _selectedHour == 0
            ? 12
            : (_selectedHour > 12 ? _selectedHour - 12 : _selectedHour);
    final displayMinute = _selectedMinute.toString().padLeft(2, '0');
    final displayAmPm = _isAm ? 'AM' : 'PM'; // AM/PM 표시 추가

    return Scaffold(
      // 배경색을 트래킹 상태에 따라 변경
      backgroundColor:
          _isTracking ? const Color(0xFF181621) : AppColors.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // 배경 (트래킹 상태에 따라 다른 배경 표시)
            _isTracking
                ? _buildTrackingBackground()
                : _buildTimeSelectionBackground(),

            // 메인 컨텐츠 (트래킹 상태에 따라 다른 UI 표시)
            _isTracking
                ? _buildTrackingContent(displayHour, displayMinute, displayAmPm)
                : _buildTimeSelectionContent(),
          ],
        ),
      ),
    );
  }

  // 시간 선택 화면 배경
  Widget _buildTimeSelectionBackground() {
    return Stack(
      children: [
        // Positioned(
        //   top: -100,
        //   left: -100,
        //   child: Container(
        //     width: 300,
        //     height: 300,
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       gradient: RadialGradient(
        //         colors: [
        //           Color(0xFF8566FF),
        //           Color(0x73623FC6),
        //           Color(0x00550F80),
        //         ],
        //         stops: [0.0, 0.53, 1.0],
        //         radius: 0.55,
        //       ),
        //     ),
        //   ),
        // ),
        // Positioned(
        //   top: -120,
        //   left: -60,
        //   child: Container(
        //     width: 300,
        //     height: 300,
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       gradient: RadialGradient(
        //         colors: [
        //           Color(0xFFA36AFF),
        //           Color(0x8A8649EB),
        //           Color(0x004113A2),
        //         ],
        //         stops: [0.0, 0.47, 1.0],
        //         radius: 0.55,
        //       ),
        //     ),
        //   ),
        // ),
        // Positioned(
        //   top: -80,
        //   right: -100,
        //   child: Container(
        //     width: 300,
        //     height: 300,
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       gradient: RadialGradient(
        //         colors: [Color(0xFF9E7CFF), Color(0x00300D45)],
        //         stops: [0.0, 1.0],
        //         radius: 0.55,
        //       ),
        //     ),
        //   ),
        // ),
        // Positioned(
        //   top: -60,
        //   right: -60,
        //   child: Container(
        //     width: 200,
        //     height: 200,
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       gradient: RadialGradient(
        //         colors: [Color(0xFF7B5DAD), Color(0x00320D49)],
        //         stops: [0.0, 1.0],
        //         radius: 0.55,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // 트래킹 화면 배경 (sleep_tracking_screen.dart 에서 가져옴)
  Widget _buildTrackingBackground() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          width: MediaQuery.of(context).size.width,
          height: 322,
          child: Stack(
            children: [
              // 구름 이미지들
              Positioned(
                top: 0,
                left: -55,
                child: SvgPicture.asset(
                  'assets/images/cloud_1.svg', // 경로 확인!
                  width: 239,
                ),
              ),
              Positioned(
                top: 139,
                right: -40,
                child: SvgPicture.asset(
                  'assets/images/cloud_2.svg', // 경로 확인!
                  width: 203,
                ),
              ),
              Positioned(
                bottom: 0,
                left: -45,
                child: SvgPicture.asset(
                  'assets/images/cloud_3.svg', // 경로 확인!
                  width: 149,
                ),
              ),
              // 달 (경로 확인 필요)
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/moon_tracking.svg', // 경로 확인!
                        width: 202,
                        height: 209,
                      ),
                    ),
                  ],
                ),
              ),

              // // 별 효과들 (위치 및 색상 조정 가능)
              Positioned(
                top: 28,
                left: 80,
                child: SvgPicture.asset(
                  'assets/images/icon_star_1.svg', // 경로 확인!
                  width: 21,
                ),
              ),
              Positioned(
                bottom: 21,
                right: 48,
                child: SvgPicture.asset(
                  'assets/images/icon_star_2.svg', // 경로 확인!
                  width: 59,
                ),
              ),
              Positioned(
                top: 103,
                right: 180,
                child: SvgPicture.asset(
                  'assets/images/icon_star_3.svg', // 경로 확인!
                  width: 26,
                ),
              ),
              Positioned(
                top: 60,
                right: 130,
                child: SvgPicture.asset(
                  'assets/images/icon_star_4.svg', // 경로 확인!
                  width: 26,
                ),
              ),
              Positioned(
                bottom: 60,
                left: 130,
                child: SvgPicture.asset(
                  'assets/images/icon_star_5.svg', // 경로 확인!
                  width: 16,
                ),
              ),
            ],
          ),
        ),

        //
        // // 선 효과 (경로 확인 필요)
        // Positioned(
        //   top: 300, // 위치 조정 가능
        //   left: 0,
        //   right: 0,
        //   child: SvgPicture.asset(
        //     'assets/images/vector_line.svg', // 경로 확인!
        //     width: MediaQuery.of(context).size.width,
        //     fit: BoxFit.cover, // 화면 너비에 맞게 조절
        //   ),
        // ),
        //
        //
        //
      ],
    );
  }

  // 시간 선택 화면 컨텐츠
  Widget _buildTimeSelectionContent() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Text(
          '몇 시에 일어날까요?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),

        // 시간 선택기
        _buildTimePickerSection(),

        const SizedBox(height: 40),

        // AM/PM 선택
        AmPmSelector(
          isAm: _isAm,
          onChanged: (value) {
            setState(() {
              _isAm = value;
            });
          },
        ),

        const Spacer(),

        // 트래킹 시작 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startTracking, // _startTracking 함수 호출
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

  // 트래킹 화면 컨텐츠
  Widget _buildTrackingContent(int hour, String minute, String ampm) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isSnoring)
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
          "${_formatDuration(_remainingTime)} 뒤에 깨어드릴게요", // 남은 시간 표시
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
          '$hour : $minute', // AM/PM 표시 추가
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
                SizedBox(width: 5,),
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
              onPressed: _stopTracking, // _stopTracking 함수 호출
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

  // 시간 선택 위젯 (기존 코드 유지)
  Widget _buildTimePickerSection() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 중앙 하이라이트 영역
          Positioned(
            child: Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.mainBackground.withOpacity(0.0), // 투명도 조절
                    AppColors.mainBackground.withOpacity(0.4),
                    AppColors.mainBackground.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 왼쪽 그라데이션 오버레이
          Positioned(
            left: 0,
            child: Container(
              width: 50,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.mainBackground,
                    AppColors.mainBackground.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 오른쪽 그라데이션 오버레이
          Positioned(
            right: 0,
            child: Container(
              width: 50,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColors.mainBackground,
                    AppColors.mainBackground.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 시간 선택 위젯
          TimeSlotPicker(
            is24HourFormat: false, // 12시간 형식 유지
            initialHour: _selectedHour, // 초기 시간 설정
            initialMinute: _selectedMinute, // 초기 분 설정
            onTimeChanged: (hours, minutes) {
              // 즉시 상태 업데이트 방지 (선택 완료 시 업데이트) -> TimeSlotPicker 내부 로직에 따라 다름
              setState(() {
                _selectedHour = hours;
                _selectedMinute = minutes;
              });
            },
          ),
        ],
      ),
    );
  }
}

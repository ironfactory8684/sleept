import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/features/tracking/sleep_results_screen.dart';
import 'package:sleept/models/sleep_session.dart';
import 'package:sleept/services/supabase_service.dart';

class SleepTrackingHome extends StatefulWidget {
  const SleepTrackingHome({super.key});

  @override
  State<SleepTrackingHome> createState() => _SleepTrackingHomeState();
}

class _SleepTrackingHomeState extends State<SleepTrackingHome> {
  List<SleepSession> _sessions = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  final Map<int, String> _weekdayNames = {
    1: '월',
    2: '화',
    3: '수',
    4: '목',
    5: '금',
    6: '토',
    7: '일',
  };

  @override
  void initState() {
    super.initState();
    _loadSleepSessions();
  }

  Future<void> _loadSleepSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessions = await SupabaseService.instance.getSleepSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수면 데이터를 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _loadSessionsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _selectedDate = date;
    });

    try {
      final sessions = await SupabaseService.instance.getSleepSessions(
        date: date,
      );
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수면 데이터를 불러오는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  // Calculate sum of durations for all sleep sessions of the selected date
  Duration get _totalSleepDuration {
    if (_sessions.isEmpty) return Duration.zero;

    return _sessions.fold(
      Duration.zero,
      (total, session) => total + session.duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = _totalSleepDuration.inHours;
    final totalMinutes = _totalSleepDuration.inMinutes % 60;

    // Calculate sleep stage durations
    int lightSleepMinutes = 0;
    int deepSleepMinutes = 0;
    int remSleepMinutes = 0;

    for (final session in _sessions) {
      if (session.sleepStages != null) {
        lightSleepMinutes +=
            ((session.sleepStages!['light'] as num? ?? 0.0) *
                    session.duration.inMinutes)
                .round();
        deepSleepMinutes +=
            ((session.sleepStages!['deep'] as num? ?? 0.0) *
                    session.duration.inMinutes)
                .round();
        remSleepMinutes +=
            ((session.sleepStages!['rem'] as num? ?? 0.0) *
                    session.duration.inMinutes)
                .round();
      }
    }

    // Calculate average sleep score
    double averageSleepScore = 0;
    if (_sessions.isNotEmpty) {
      int validScores = 0;
      double totalScore = 0;

      for (final session in _sessions) {
        if (session.sleepScore != null) {
          totalScore += session.sleepScore!;
          validScores++;
        }
      }

      if (validScores > 0) {
        averageSleepScore = totalScore / validScores;
      }
    }

    // Calculate comparison with previous days (placeholder logic)
    final int comparisonScore = (averageSleepScore - 67).round();
    final bool isImproved = comparisonScore > 0;

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildDateSelector(),
                    const SizedBox(height: 20),
                    _buildSleepDurationChart(
                      totalHours,
                      totalMinutes,
                      lightSleepMinutes,
                      deepSleepMinutes,
                      remSleepMinutes,
                    ),
                    const SizedBox(height: 20),
                    _buildSleepScoreCard(
                      averageSleepScore,
                      comparisonScore,
                      isImproved,
                    ),
                    const SizedBox(height: 20),
                    if (_sessions.isNotEmpty) ...[
                      _buildRecentSessionsList(),
                    ] else ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            '선택한 날짜에 수면 데이터가 없습니다.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildDateSelector() {
    // Get the date range for the week view
    final now = DateTime.now();
    final List<DateTime> weekDates = [];

    // Generate dates for the week view (centered on today)
    for (int i = -3; i <= 3; i++) {
      weekDates.add(DateTime(now.year, now.month, now.day + i));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '수면의 단계 분석',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () {
                  // Show info about sleep stages
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                weekDates.map((date) {
                  final isSelected =
                      date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  final isToday =
                      date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  return GestureDetector(
                    onTap: () => _loadSessionsForDate(date),
                    child: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color:
                                  isSelected || isToday
                                      ? Colors.white
                                      : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _weekdayNames[date.weekday] ?? '',
                            style: TextStyle(
                              color:
                                  isSelected || isToday
                                      ? Colors.white
                                      : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepDurationChart(
    int hours,
    int minutes,
    int lightSleepMinutes,
    int deepSleepMinutes,
    int remSleepMinutes,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.nightlight_round,
                color: Colors.amber.shade300,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '오전 12시 34분',
                style: TextStyle(color: Colors.amber.shade300, fontSize: 14),
              ),
              const Spacer(),
              Icon(
                Icons.wb_sunny_outlined,
                color: Colors.red.shade300,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '오전 7시 30분',
                style: TextStyle(color: Colors.red.shade300, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sleep duration chart
          SizedBox(
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 0.35,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade800,
                    color: Colors.deepPurple.shade300,
                  ),
                ),
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: 0.8,
                    strokeWidth: 12,
                    backgroundColor: Colors.transparent,
                    color: Colors.indigo,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '총 수면 시간',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hours}시간 ${minutes}분',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sleep stages breakdown
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '비수면',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '34분',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '깊은 수면',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${deepSleepMinutes ~/ 60}시간 ${deepSleepMinutes % 60}분',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '얕은 수면',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lightSleepMinutes ~/ 60}시간 ${lightSleepMinutes % 60}분',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '렘 수면',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${remSleepMinutes ~/ 60}시간 ${remSleepMinutes % 60}분',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepScoreCard(
    double score,
    int comparisonScore,
    bool isImproved,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '내 수면 점수',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.white70,
                ),
                onPressed: () {
                  // Show info about sleep score
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${score.round()}점',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImproved ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '어제보다 ${comparisonScore.abs()}점',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Score graph
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                // Sample data for the chart
                final heights = [0.5, 0.7, 0.6, 0.8, 0.9, 0.75, 0.6];
                final selectedIndex = 4; // Day that's highlighted

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: 80 * heights[index],
                      decoration: BoxDecoration(
                        color:
                            index == selectedIndex
                                ? Colors.deepPurple
                                : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ['월', '화', '수', '목', '금', '토', '일'][index],
                      style: TextStyle(
                        color:
                            index == selectedIndex
                                ? Colors.deepPurple
                                : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Comparison section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.deepPurple,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '75점',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 67,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade800,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '67점',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    '내 점수가\n평균 점수 보다\n매우 높아요!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '7.8-7.14 기준',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 수면 기록',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              final session = _sessions[index];
              final dateFormat = DateFormat('MM월 dd일');
              final timeFormat = DateFormat('HH:mm');

              final formattedDate = dateFormat.format(session.startTime);
              final formattedStartTime = timeFormat.format(session.startTime);
              final formattedEndTime = timeFormat.format(session.endTime);

              final hours = session.duration.inHours;
              final minutes = session.duration.inMinutes % 60;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SleepResultsScreen(session: session),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Left section with date and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$formattedStartTime - $formattedEndTime',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '총 수면시간: $hours시간 $minutes분',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right section with score
                      if (session.sleepScore != null) ...[
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade400,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${session.sleepScore!.round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

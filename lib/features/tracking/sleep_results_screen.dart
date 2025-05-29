import 'package:flutter/material.dart';
import 'package:sleept/constants/colors.dart';
import 'package:sleept/models/sleep_session.dart';
import 'package:sleept/services/supabase_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Screen to display sleep tracking results after a session is complete
class SleepResultsScreen extends StatefulWidget {
  final SleepSession? session;
  final String? sessionId;
  final DateTime? initialDate;

  const SleepResultsScreen({
    super.key,
    this.session,
    this.sessionId,
    this.initialDate,
  }) : assert(session != null || sessionId != null, 'Either session or sessionId must be provided');

  @override
  State<SleepResultsScreen> createState() => _SleepResultsScreenState();
}

class _SleepResultsScreenState extends State<SleepResultsScreen> {
  SleepSession? _session;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<SleepSession> _availableSessions = [];
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
    _session = widget.session;
    _selectedDate = widget.initialDate ?? (widget.session?.startTime ?? DateTime.now());
    
    if (widget.session == null && widget.sessionId != null) {
      _loadSessionById(widget.sessionId!);
    } else {
      _loadAvailableSessions();
    }
  }

  Future<void> _loadSessionById(String sessionId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = await SupabaseService.instance.getSleepSessionById(sessionId);
      setState(() {
        _session = session;
        if (session != null) {
          _selectedDate = session.startTime;
        }
        _isLoading = false;
      });
      _loadAvailableSessions();
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

  Future<void> _loadAvailableSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessions = await SupabaseService.instance.getSleepSessions();
      setState(() {
        _availableSessions = sessions;
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

  void _selectSession(SleepSession session) {
    setState(() {
      _session = session;
      _selectedDate = session.startTime;
    });
  }

  void _selectDate(DateTime date) {
    // Find the session closest to the selected date
    if (_availableSessions.isNotEmpty) {
      // Try to find a session that started on the selected date
      final selectedDateSessions = _availableSessions.where((s) => 
        s.startTime.year == date.year && 
        s.startTime.month == date.month && 
        s.startTime.day == date.day
      ).toList();
      
      if (selectedDateSessions.isNotEmpty) {
        // If multiple sessions found for the date, use the one with highest score
        selectedDateSessions.sort((a, b) => 
          (b.sleepScore ?? 0).compareTo(a.sleepScore ?? 0)
        );
        _selectSession(selectedDateSessions.first);
      } else {
        // If no session found for exact date, select the closest one
        _availableSessions.sort((a, b) => 
          (a.startTime.difference(date).abs()).compareTo(b.startTime.difference(date).abs())
        );
        _selectSession(_availableSessions.first);
      }
    }
    
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '수면 분석 결과',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _session == null 
            ? const Center(child: Text('수면 데이터를 찾을 수 없습니다.', style: TextStyle(color: Colors.white)))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateSelector(),
                      const SizedBox(height: 20),
                      _buildSessionOverview(),
                      const SizedBox(height: 20),
                      _buildSleepScoreCard(),
                      const SizedBox(height: 20),
                      _buildSleepEventsSection(),
                      const SizedBox(height: 20),
                      if (_session!.sleepStages != null) _buildSleepStagesChart(),
                      const SizedBox(height: 20),
                      _buildRecommendationsSection(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildDateSelector() {
    // Get the date range for the week view
    final now = DateTime.now();
    final List<DateTime> weekDates = [];
    
    // Generate dates for the week view (centered on selected date)
    final selectedDate = _selectedDate;
    for (int i = -3; i <= 3; i++) {
      weekDates.add(DateTime(selectedDate.year, selectedDate.month, selectedDate.day + i));
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDates.map((date) {
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              
              final isToday = date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              
              // Check if the date has any session
              final hasSession = _availableSessions.any((s) => 
                s.startTime.year == date.year && 
                s.startTime.month == date.month && 
                s.startTime.day == date.day
              );
              
              return GestureDetector(
                onTap: hasSession ? () => _selectDate(date) : null,
                child: Container(
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurple : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: hasSession 
                            ? (isSelected || isToday ? Colors.white : Colors.grey.shade300)
                            : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weekdayNames[date.weekday] ?? '',
                        style: TextStyle(
                          color: hasSession 
                            ? (isSelected || isToday ? Colors.white : Colors.grey.shade400)
                            : Colors.grey.shade700,
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

  /// Session date and duration information
  Widget _buildSessionOverview() {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final timeFormat = DateFormat('HH:mm');
    final formattedDate = dateFormat.format(_session!.startTime);
    final formattedStartTime = timeFormat.format(_session!.startTime);
    final formattedEndTime = timeFormat.format(_session!.endTime);
    final hours = _session!.duration.inHours;
    final minutes = _session!.duration.inMinutes % 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$formattedStartTime - $formattedEndTime ($hours시간 $minutes분)',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sleep quality score visualization
  Widget _buildSleepScoreCard() {
    final score = _session!.sleepScore ?? 0.0;
    
    String qualityText;
    Color qualityColor;
    
    if (score >= 80) {
      qualityText = '매우 좋음';
      qualityColor = Colors.green;
    } else if (score >= 60) {
      qualityText = '좋음';
      qualityColor = Colors.lightGreen;
    } else if (score >= 40) {
      qualityText = '보통';
      qualityColor = Colors.orange;
    } else {
      qualityText = '개선 필요';
      qualityColor = Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수면 점수',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          score.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: qualityColor,
                          ),
                        ),
                        Text(
                          '/ 100',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '수면 품질: $qualityText',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: qualityColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQualityInfoRow(
                      '코골이', 
                      '${_session!.snoringPercentage.toStringAsFixed(1)}%', 
                      _session!.snoringPercentage > 30 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 4),
                    _buildQualityInfoRow(
                      '잠꼬대', 
                      '${_session!.talkingPercentage.toStringAsFixed(1)}%',
                      _session!.talkingPercentage > 10 ? Colors.orange : Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Helper for quality indicator rows
  Widget _buildQualityInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Sleep events (snoring, talking) summary
  Widget _buildSleepEventsSection() {
    final snoringCount = _session!.snoringEvents.length;
    final talkingCount = _session!.sleepTalkingEvents.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수면 이벤트',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildEventRow(
              '코골이',
              snoringCount,
              Icons.bedtime_outlined,
              Colors.red.shade100,
            ),
            const SizedBox(height: 12),
            _buildEventRow(
              '잠꼬대',
              talkingCount,
              Icons.record_voice_over,
              Colors.orange.shade100,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Helper for event summary rows
  Widget _buildEventRow(String label, int count, IconData icon, Color backgroundColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          ' 회',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Sleep stages chart (if available)
  Widget _buildSleepStagesChart() {
    // In our simplified implementation, we're using placeholder values
    final stages = _session!.sleepStages;
    if (stages == null) return const SizedBox();
    
    final lightSleepPct = (((stages['light'] as num?) ?? 0.0) * 100).round();
    final deepSleepPct = (((stages['deep'] as num?) ?? 0.0) * 100).round();
    final int remSleepPct = (((stages['rem'] as num?) ?? 0.0) * 100).round();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수면 단계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: lightSleepPct.toDouble(),
                      title: '$lightSleepPct%',
                      color: Colors.blue.shade300,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: deepSleepPct.toDouble(),
                      title: '$deepSleepPct%',
                      color: Colors.indigo.shade700,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: remSleepPct.toDouble(),
                      title: '$remSleepPct%',
                      color: Colors.purple.shade300,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStageLegend('얕은 수면', Colors.blue.shade300),
                _buildStageLegend('깊은 수면', Colors.indigo.shade700),
                _buildStageLegend('렘 수면', Colors.purple.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Helper for stage legend items
  Widget _buildStageLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Sleep improvement recommendations
  Widget _buildRecommendationsSection() {
    List<String> recommendations = [];
    
    // Add recommendations based on sleep data
    if (_session!.snoringPercentage > 30) {
      recommendations.add('코골이가 많이 감지되었습니다. 옆으로 누워서 자는 자세를 취해보세요.');
      recommendations.add('취침 전 알코올 섭취를 피하고 체중 관리가 도움이 될 수 있습니다.');
    }
    
    if (_session!.talkingPercentage > 10) {
      recommendations.add('잠꼬대가 많이 발생했습니다. 스트레스 감소 및 취침 전 이완 활동이 도움이 될 수 있습니다.');
    }
    
    if (_session!.duration.inHours < 6) {
      recommendations.add('수면 시간이 6시간 미만입니다. 7-8시간의 수면을 목표로 하세요.');
    }
    
    // If no specific recommendations, add general tips
    if (recommendations.isEmpty) {
      recommendations = [
        '수면 환경의 온도는 18-21°C로 유지하는 것이 좋습니다.',
        '취침 전 블루라이트 노출을 줄이기 위해 전자기기 사용을 제한하세요.',
        '일정한 취침/기상 시간을 유지하세요.',
      ];
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '수면 개선 팁',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...recommendations.map((tip) => _buildTipItem(tip)).toList(),
          ],
        ),
      ),
    );
  }
  
  /// Helper for tip items
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

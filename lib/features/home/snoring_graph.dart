import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sleept/models/snoring_event.dart';
import 'package:sleept/features/habit/service/habit_database.dart';

class SnoringGraph extends StatefulWidget {
  const SnoringGraph({Key? key}) : super(key: key);

  @override
  _SnoringGraphState createState() => _SnoringGraphState();
}

class _SnoringGraphState extends State<SnoringGraph> {
  Map<String, double> dailyData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final events = await HabitDatabase.instance.readSnoringEvents();
    final now = DateTime.now();
    // Last 7 days labels
    final last7Days = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i)),
    );
    Map<String, double> data = {
      for (var d in last7Days) DateFormat('MM/dd').format(d): 0.0
    };
    for (var e in events) {
      final label = DateFormat('MM/dd').format(e.startTime);
      if (data.containsKey(label)) {
        data[label] = data[label]! + e.duration.inMinutes;
      }
    }
    setState(() {
      dailyData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final labels = dailyData.keys.toList();
    final values = dailyData.values.toList();
    final spots = List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  return idx >= 0 && idx < labels.length
                      ? Text(labels[idx], style: const TextStyle(fontSize: 10))
                      : const Text('');
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Theme.of(context).primaryColor,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

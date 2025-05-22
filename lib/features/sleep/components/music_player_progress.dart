import 'package:flutter/material.dart';
import 'dart:math';

class CircularMusicPlayer extends StatelessWidget {
  final double progress; // 0.0 ~ 1.0
  final Duration current;
  final Duration total;
  final String imageUrl;

  const CircularMusicPlayer({
    super.key,
    required this.progress,
    required this.current,
    required this.total,
    required this.imageUrl
  });

  @override
  Widget build(BuildContext context) {
    final double size = 220.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 프로그레스 바
            CustomPaint(
              size: Size(size, size),
              painter: _CircularProgressPainter(progress),
            ),
            // 앨범 이미지
            ClipOval(
              child: Image.asset(
                imageUrl, // 실제 경로로 교체
                width: size - 24,
                height: size - 24,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  width: size - 24,
                  height: size - 24,
                  child: Icon(Icons.music_note, size: 40, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 시간 표시
        Text(
          "${_formatDuration(current)}   |   ${_formatDuration(total)}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  _CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.0;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    // 배경 원
    final bgPaint = Paint()
      ..color = Color(0XFF666375)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // 진행 원border: 4px solid;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [Color(0xFF804FFF), Color(0xFFC2ABFF),Color(0xFFFFFFFF)  ],
        startAngle: 0.0,
        endAngle: 1 * pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // 핸들 점
    final angle = startAngle + sweepAngle;
    final handleOffset = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    final handlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(handleOffset, 6.5, handlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}



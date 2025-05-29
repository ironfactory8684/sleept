import 'package:flutter/material.dart';

class StepProgressButton extends StatefulWidget {
  final int totalSteps;
  final int currentStep;
  final VoidCallback? onPressed;
  final String text;
  final double size;

  const StepProgressButton({
    Key? key,
    required this.totalSteps,
    required this.currentStep,
    this.onPressed,
    this.text = '다음',
    this.size = 120.0,
  }) : super(key: key);

  @override
  State<StepProgressButton> createState() => _StepProgressButtonState();
}

class _StepProgressButtonState extends State<StepProgressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(StepProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: StepProgressPainter(
                progress: widget.currentStep / widget.totalSteps,
                animationValue: _animation.value,
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StepProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;

  StepProgressPainter({required this.progress, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 4.0;
    final gap = 6.0; // 가운데 버튼과 테두리 사이의 간격

    // 배경 원 (어두운 회색)
    final backgroundPaint =
    Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 내부 보라색 원 (gap만큼 더 작게)
    final innerPaint =
    Paint()
      ..color = const Color(0xFF7C4DFF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - strokeWidth - gap, innerPaint);

    // 외곽 테두리 (회색 배경)
    final borderBackgroundPaint =
    Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, borderBackgroundPaint);

    // 진행도에 따른 보라색 테두리
    if (progress > 0) {
      final progressPaint =
      Paint()
        ..color = const Color(0xFF7C4DFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * 3.141592653589793 * progress * animationValue;
      final startAngle = -3.141592653589793 / 2; // 12시 방향부터 시작

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is StepProgressPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.animationValue != animationValue);
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CoatOfArmsBadge extends StatefulWidget {
  const CoatOfArmsBadge({super.key});

  @override
  State<CoatOfArmsBadge> createState() => _CoatOfArmsBadgeState();
}

class _CoatOfArmsBadgeState extends State<CoatOfArmsBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Uganda coat of arms',
      image: true,
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: 58,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _CoatOfArmsSpinnerPainter(
                  progress: _controller.value,
                  color: AppTheme.isDark(context)
                      ? AppColors.flagYellow
                      : AppColors.forest,
                ),
                child: child,
              );
            },
            child: Center(
              child: SizedBox.square(
                dimension: 42,
                child: Image.asset(
                  'assets/images/coat-of-arms.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoatOfArmsSpinnerPainter extends CustomPainter {
  const _CoatOfArmsSpinnerPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 2.5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.18);
    final spinnerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, trackPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((progress * math.pi * 2) - (math.pi / 2));
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, 0, math.pi * 0.86, false, spinnerPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CoatOfArmsSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

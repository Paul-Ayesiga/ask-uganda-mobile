import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class LockLoaderMark extends StatefulWidget {
  const LockLoaderMark({super.key});

  @override
  State<LockLoaderMark> createState() => _LockLoaderMarkState();
}

class _LockLoaderMarkState extends State<LockLoaderMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading secure GUVA app',
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: 142,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _LockLoaderPainter(progress: _controller.value),
                child: child,
              );
            },
            child: const Center(child: _PadlockBadge()),
          ),
        ),
      ),
    );
  }
}

class _PadlockBadge extends StatelessWidget {
  const _PadlockBadge();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 86,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Image(
          image: AssetImage('assets/brand/ask-uganda-mark-256.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _LockLoaderPainter extends CustomPainter {
  const _LockLoaderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 9;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = AppColors.flagBlack.withValues(alpha: 0.18);
    final loaderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0x00B8860B),
          AppColors.flagBlack,
          AppColors.flagRed,
          AppColors.flagBlack,
        ],
        stops: [0, 0.42, 0.72, 1],
      ).createShader(rect);

    canvas.drawCircle(center, radius, trackPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((progress * math.pi * 2) - math.pi / 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, 0, math.pi * 1.35, false, loaderPaint);
    canvas.restore();

    final dotOffset = Offset(
      center.dx + math.cos((progress * math.pi * 2) - math.pi / 2) * radius,
      center.dy + math.sin((progress * math.pi * 2) - math.pi / 2) * radius,
    );
    canvas.drawCircle(dotOffset, 4.5, Paint()..color = AppColors.flagBlack);
  }

  @override
  bool shouldRepaint(covariant _LockLoaderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

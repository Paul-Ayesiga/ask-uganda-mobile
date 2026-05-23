import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/assistant_controller.dart';

class VoiceInputScreen extends ConsumerStatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  ConsumerState<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends ConsumerState<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  bool _isListening = true;
  String _transcript = '';

  static const _placeholderTranscript =
      'I want to renew my driving permit. It expired earlier this year.';

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _simulateRecognition();
  }

  Future<void> _simulateRecognition() async {
    for (var i = 1; i <= _placeholderTranscript.length; i++) {
      if (!mounted || !_isListening) return;
      await Future<void>.delayed(const Duration(milliseconds: 22));
      setState(() => _transcript = _placeholderTranscript.substring(0, i));
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _send() {
    if (_transcript.trim().isEmpty) return;
    setState(() => _isListening = false);
    final id =
        ref.read(assistantControllerProvider.notifier).startNewThread();
    ref
        .read(assistantControllerProvider.notifier)
        .sendCitizenMessage(_transcript);
    if (!mounted) return;
    context.pop();
    context.push('/assistant/conversation/$id');
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesControllerProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.forest,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.translate_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          preferences.language.englishName,
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(220, 80),
                    painter: _WavePainter(
                      progress: _waveController.value,
                      color: AppColors.flagYellow,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _transcript.isEmpty
                      ? 'Listening… speak naturally in ${preferences.language.englishName}.'
                      : _transcript,
                  key: ValueKey(_transcript),
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.keyboard_alt_outlined),
                      label: const Text('Type instead'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.flagYellow,
                        foregroundColor: AppColors.flagBlack,
                      ),
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Send'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Audio stays on device until you press send.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            // Hidden ref to scheme to avoid analyzer warning if removed later.
            SizedBox(height: 0, child: ColoredBox(color: scheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const barCount = 18;
    final spacing = size.width / barCount;
    final base = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final phase = (progress * 2 * math.pi) + (i * 0.4);
      final amplitude = (math.sin(phase).abs()) * 0.6 + 0.18;
      final height = size.height * amplitude;
      final x = i * spacing + spacing / 2;
      canvas.drawLine(
        Offset(x, base - height / 2),
        Offset(x, base + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/voice/voice_service.dart';
import '../controllers/assistant_controller.dart';

class VoiceInputScreen extends ConsumerStatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  ConsumerState<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends ConsumerState<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  StreamSubscription<VoiceTranscript>? _subscription;

  String _transcript = '';
  bool _isListening = false;
  bool _isInitialising = true;
  String? _availabilityNote;
  bool _languageSupported = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Defer until the first frame so the language preference is read
    // from the providers in a context where Riverpod is fully wired.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final language = ref.read(preferencesControllerProvider).language.code;
    final availability = await ref
        .read(voiceServiceProvider)
        .initialiseForLanguage(language);

    if (!mounted) return;
    setState(() {
      _isInitialising = false;
      _languageSupported = availability.languageSupported;
      _availabilityNote = availability.notes;
    });

    if (availability.sttReady && availability.languageSupported) {
      _listen(language);
    }
  }

  void _listen(String language) {
    setState(() {
      _isListening = true;
      _transcript = '';
    });
    _subscription = ref
        .read(voiceServiceProvider)
        .startListening(languageCode: language)
        .listen(
          (t) {
            if (!mounted) return;
            setState(() => _transcript = t.text);
            if (t.isFinal) {
              setState(() => _isListening = false);
            }
          },
          onError: (e) {
            if (!mounted) return;
            setState(() {
              _isListening = false;
              _availabilityNote = 'Voice recognition stopped: $e';
            });
          },
        );
  }

  Future<void> _stop() async {
    await ref.read(voiceServiceProvider).stopListening();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  void _send() {
    final text = _transcript.trim();
    if (text.isEmpty) return;
    final id =
        ref.read(assistantControllerProvider.notifier).startNewThread();
    ref.read(assistantControllerProvider.notifier).sendCitizenMessage(text);
    if (!mounted) return;
    context.pop();
    context.push('/assistant/conversation/$id');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _waveController.dispose();
    unawaited(ref.read(voiceServiceProvider).stopListening());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesControllerProvider);
    final textTheme = Theme.of(context).textTheme;

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
                      activeBars: _isListening ? 18 : 6,
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
                  _displayedText(preferences.language.englishName),
                  key: ValueKey(_transcript),
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            if (_availabilityNote != null) ...[
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  _availabilityNote!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
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
                      onPressed: () {
                        unawaited(_stop());
                        context.pop();
                      },
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
                      onPressed: _transcript.trim().isEmpty ? null : _send,
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
          ],
        ),
      ),
    );
  }

  String _displayedText(String langLabel) {
    if (_isInitialising) return 'Getting ready…';
    if (_transcript.isNotEmpty) return _transcript;
    if (!_languageSupported) {
      return 'Voice is not yet available for $langLabel.';
    }
    if (_isListening) return 'Listening… speak naturally in $langLabel.';
    return 'Tap Type instead, or close to go back.';
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.progress,
    required this.color,
    required this.activeBars,
  });

  final double progress;
  final Color color;
  final int activeBars;

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
      if (i >= activeBars) continue;
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
    return oldDelegate.progress != progress ||
        oldDelegate.activeBars != activeBars;
  }
}

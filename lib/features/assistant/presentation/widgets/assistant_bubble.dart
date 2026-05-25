import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/preferences_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/voice/voice_service.dart';
import '../../../../core/widgets/ask_uganda_brand_mark.dart';
import '../../domain/models/chat_message.dart';

class AssistantBubble extends ConsumerWidget {
  const AssistantBubble({
    super.key,
    required this.text,
    this.actions = const [],
    this.onAction,
    this.isStreaming = false,
  });

  final String text;
  final List<ChatAction> actions;
  final ValueChanged<ChatAction>? onAction;
  final bool isStreaming;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCursor = isStreaming;
    final showPreambleDots = isStreaming && text.isEmpty;
    final canSpeak = !isStreaming && text.trim().isNotEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            border: Border.all(color: AppTheme.line(context)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(child: _AssistantAttribution()),
                  if (canSpeak) _SpeakButton(text: text),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (showPreambleDots)
                const _PreambleDots()
              else
                _StreamingText(text: text, showCursor: showCursor),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final action in actions)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => onAction?.call(action),
                        child: Text(action.label),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact play/stop button that triggers TTS for the bubble's text.
/// Stateful so we can toggle its icon between speaking and idle without
/// pushing speech state into the global controller (TTS is fire-and-
/// forget; one bubble plays at a time, the service stops any previous
/// playback on a fresh speak call).
class _SpeakButton extends ConsumerStatefulWidget {
  const _SpeakButton({required this.text});

  final String text;

  @override
  ConsumerState<_SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends ConsumerState<_SpeakButton> {
  bool _speaking = false;

  Future<void> _toggle() async {
    final voice = ref.read(voiceServiceProvider);
    if (_speaking) {
      await voice.stopSpeaking();
      if (!mounted) return;
      setState(() => _speaking = false);
      return;
    }
    final language = ref.read(preferencesControllerProvider).language.code;
    setState(() => _speaking = true);
    await voice.speak(widget.text, languageCode: language);
    // FlutterTts.speak's Future resolves when playback starts (not when
    // it ends) on iOS. We optimistically flip the icon back after a
    // short window so a long reply doesn't leave the button stuck;
    // tapping it again always stops cleanly.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _speaking ? 'Stop' : 'Read aloud',
      visualDensity: VisualDensity.compact,
      onPressed: _toggle,
      icon: Icon(
        _speaking ? Icons.stop_rounded : Icons.volume_up_outlined,
        size: 18,
      ),
    );
  }
}

class _AssistantAttribution extends StatelessWidget {
  const _AssistantAttribution();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        const AskUgandaBrandMark(size: 22),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Ask Uganda',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// The streamed text + a blinking caret to signal that more is on the way.
/// The caret renders inline at the end so the layout doesn't reflow when
/// streaming completes.
class _StreamingText extends StatelessWidget {
  const _StreamingText({required this.text, required this.showCursor});

  final String text;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.42);
    if (!showCursor) {
      return Text(text, style: style);
    }
    final cursorStyle = style?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w800,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text, style: style),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _BlinkingCaret(style: cursorStyle),
          ),
        ],
      ),
    );
  }
}

/// Three animated dots shown before the first token arrives. Distinct from
/// the global TypingIndicator so it lives inside the bubble rather than
/// above it — the bubble has already appeared by the time these render.
class _PreambleDots extends StatefulWidget {
  const _PreambleDots();

  @override
  State<_PreambleDots> createState() => _PreambleDotsState();
}

class _PreambleDotsState extends State<_PreambleDots>
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
    final color = Theme.of(context).colorScheme.primary;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final offset = (i * 0.25) % 1;
              final t = ((_controller.value + offset) % 1.0);
              final opacity = 0.3 + 0.7 * (1 - (2 * t - 1).abs());
              return Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 6),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  const _BlinkingCaret({this.style});
  final TextStyle? style;

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Sharp blink: full opacity for the first half of the cycle,
          // hidden for the second. Avoids the muddy fade of opacity tweens.
          final visible = _controller.value < 0.5;
          return Opacity(
            opacity: visible ? 1.0 : 0.0,
            child: Text('▍', style: widget.style),
          );
        },
      ),
    );
  }
}

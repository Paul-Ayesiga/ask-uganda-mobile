import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class ComposerBar extends StatefulWidget {
  const ComposerBar({
    super.key,
    required this.onSend,
    required this.onVoice,
    required this.onAttachDocument,
    required this.languageLabel,
    required this.onChangeLanguage,
    this.enabled = true,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onVoice;
  final VoidCallback onAttachDocument;
  final String languageLabel;
  final VoidCallback onChangeLanguage;
  final bool enabled;

  @override
  State<ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<ComposerBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleChange)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  void _submit() {
    if (!_canSend || !widget.enabled) return;
    widget.onSend(_controller.text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          border: Border(top: BorderSide(color: AppTheme.line(context))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _CapsuleAction(
                  icon: Icons.translate_rounded,
                  label: widget.languageLabel,
                  onTap: widget.onChangeLanguage,
                ),
                const Spacer(),
                _CapsuleAction(
                  icon: Icons.lock_outline_rounded,
                  label: 'Private',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CircleAction(
                  icon: Icons.attach_file_rounded,
                  onTap: widget.onAttachDocument,
                  tooltip: 'Attach document',
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      maxHeight: 160,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      minLines: 1,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2000),
                      ],
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Ask in your language…',
                        filled: true,
                        fillColor: AppTheme.page(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _CircleAction(
                  icon: _canSend ? Icons.send_rounded : Icons.mic_rounded,
                  filled: true,
                  onTap: _canSend ? _submit : widget.onVoice,
                  tooltip: _canSend ? 'Send message' : 'Speak instead',
                  background: scheme.primary,
                  foreground: scheme.onPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.filled = false,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool filled;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? AppTheme.page(context);
    final fg = foreground ?? scheme.primary;

    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: fg, size: 22),
          ),
        ),
      ),
    );
  }
}

class _CapsuleAction extends StatelessWidget {
  const _CapsuleAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: AppTheme.page(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: AppTheme.line(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: scheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

enum SignInMethod { nationalId, phoneOtp }

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> with TickerProviderStateMixin {
  SignInMethod _method = SignInMethod.nationalId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border.all(color: AppTheme.line(context)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14123B2A),
            offset: Offset(0, 18),
            blurRadius: 36,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Citizen access', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose how you want to verify this session.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          _MethodSelector(
            selected: _method,
            onChanged: (method) => setState(() => _method = method),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [...previousChildren, ?currentChild],
                );
              },
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: _method == SignInMethod.nationalId
                  ? const _NationalIdPinFields(key: ValueKey('national-id-pin'))
                  : _PhoneOtpFields(
                      key: const ValueKey('phone-otp'),
                      onUseNationalId: () {
                        setState(() => _method = SignInMethod.nationalId);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodSelector extends StatelessWidget {
  const _MethodSelector({required this.selected, required this.onChanged});

  final SignInMethod selected;
  final ValueChanged<SignInMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppTheme.page(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.line(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MethodTab(
              icon: Icons.badge_outlined,
              label: 'National ID',
              selected: selected == SignInMethod.nationalId,
              onTap: () => onChanged(SignInMethod.nationalId),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _MethodTab(
              icon: Icons.sms_outlined,
              label: 'Phone OTP',
              selected: selected == SignInMethod.phoneOtp,
              onTap: () => onChanged(SignInMethod.phoneOtp),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.forest : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1F123B2A),
                      offset: Offset(0, 6),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NationalIdPinFields extends StatelessWidget {
  const _NationalIdPinFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _LabeledTextField(
          label: 'National ID',
          hintText: 'CM12345678901234',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.text,
          autofillHints: [AutofillHints.username],
        ),
        const SizedBox(height: AppSpacing.md),
        const SegmentedCodeField(
          label: 'Secret PIN',
          length: 4,
          obscureInitially: true,
          canToggleVisibility: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () => _openHome(context),
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Continue'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.fingerprint_rounded),
          label: const Text('Use biometrics'),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text('Forgot Secret PIN?'),
          ),
        ),
      ],
    );
  }
}

class _PhoneOtpFields extends StatelessWidget {
  const _PhoneOtpFields({super.key, required this.onUseNationalId});

  final VoidCallback onUseNationalId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _LabeledTextField(
          label: 'Phone number',
          hintText: '256700000000',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          autofillHints: [AutofillHints.telephoneNumber],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const SegmentedCodeField(
          label: 'OTP code',
          length: 6,
          obscureInitially: false,
          canToggleVisibility: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sms_rounded),
          label: const Text('Request OTP'),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => _openHome(context),
          icon: const Icon(Icons.lock_open_rounded),
          label: const Text('Verify OTP'),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: onUseNationalId,
            child: const Text('Use National ID instead'),
          ),
        ),
      ],
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    required this.autofillHints,
    this.inputFormatters = const [],
  });

  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final Iterable<String> autofillHints;
  final List<TextInputFormatter> inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

class SegmentedCodeField extends StatefulWidget {
  const SegmentedCodeField({
    super.key,
    required this.label,
    required this.length,
    required this.obscureInitially,
    required this.canToggleVisibility,
  });

  final String label;
  final int length;
  final bool obscureInitially;
  final bool canToggleVisibility;

  @override
  State<SegmentedCodeField> createState() => _SegmentedCodeFieldState();
}

class _SegmentedCodeFieldState extends State<SegmentedCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_handleTextChanged);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    _obscured = widget.obscureInitially;
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleTextChanged)
      ..dispose();
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleTextChanged() => setState(() {});

  void _handleFocusChanged() => setState(() {});

  void _toggleVisibility() {
    setState(() => _obscured = !_obscured);
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.text;
    final isFocused = _focusNode.hasFocus;

    return Semantics(
      label: widget.label,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (widget.canToggleVisibility)
                IconButton(
                  onPressed: _toggleVisibility,
                  tooltip: _obscured ? 'Show secret PIN' : 'Hide secret PIN',
                  icon: Icon(
                    _obscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: Stack(
              children: [
                Row(
                  children: List.generate(widget.length, (index) {
                    final hasValue = index < value.length;
                    final character = hasValue ? value[index] : '';
                    final displayValue = _obscured && hasValue
                        ? '•'
                        : character;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == widget.length - 1 ? 0 : AppSpacing.sm,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOutCubic,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.page(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isFocused && index == value.length
                                  ? Theme.of(context).colorScheme.primary
                                  : AppTheme.line(context),
                              width: isFocused && index == value.length
                                  ? 1.6
                                  : 1,
                            ),
                          ),
                          child: Text(
                            displayValue,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned.fill(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: widget.length,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 1,
                      height: 1,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    decoration: const InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _openHome(BuildContext context) {
  context.go('/');
}

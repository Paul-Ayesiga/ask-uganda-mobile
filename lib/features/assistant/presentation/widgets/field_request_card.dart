import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/field_request.dart';

/// Renders an in-conversation prompt that asks the citizen for one
/// structured value (TIN, business registration number, parcel id, …).
///
/// Two render modes:
///   • [submission] == null → input + Submit button (live).
///   • [submission] != null → read-only "✓ Submitted" pill showing what
///     the citizen sent. Kept visible so the conversation history
///     remains auditable.
class FieldRequestCard extends StatefulWidget {
  const FieldRequestCard({
    super.key,
    required this.request,
    required this.onSubmit,
    this.submission,
  });

  final FieldRequest request;
  final ValueChanged<String> onSubmit;
  final Map<String, String>? submission;

  @override
  State<FieldRequestCard> createState() => _FieldRequestCardState();
}

class _FieldRequestCardState extends State<FieldRequestCard> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.submission?[widget.request.id] ?? '',
  );
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return 'Please enter ${widget.request.label.toLowerCase()}.';
    }
    final max = widget.request.maxLength;
    if (max != null && value.length > max) {
      return 'Must be $max characters or fewer.';
    }
    final pattern = widget.request.pattern;
    if (pattern != null && !RegExp(pattern).hasMatch(value)) {
      return _patternHint(widget.request.kind);
    }
    return null;
  }

  void _attemptSubmit() {
    final raw = _controller.text;
    final err = _validate(raw);
    if (err != null) {
      setState(() => _validationError = err);
      return;
    }
    widget.onSubmit(raw.trim());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final decided = widget.submission != null;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.flagYellow.withValues(alpha: 0.10),
            border: Border.all(
              color: AppColors.flagYellow.withValues(alpha: 0.55),
              width: 1.6,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'One more detail',
                    style: textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(widget.request.label, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(widget.request.purpose, style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              if (decided)
                _SubmittedPill(value: widget.submission![widget.request.id] ?? '')
              else
                _InputArea(
                  request: widget.request,
                  controller: _controller,
                  errorText: _validationError,
                  onChanged: (_) {
                    if (_validationError != null) {
                      setState(() => _validationError = null);
                    }
                  },
                  onSubmit: _attemptSubmit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  const _InputArea({
    required this.request,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    required this.onSubmit,
  });

  final FieldRequest request;
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (request.kind == FieldKind.choice && request.choices.isNotEmpty) {
      return _ChoicePicker(
        request: request,
        selected: controller.text,
        onChanged: (v) {
          controller.text = v;
          onChanged(v);
        },
        onSubmit: onSubmit,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: _keyboardFor(request.kind),
          inputFormatters: _formattersFor(request.kind, request.maxLength),
          decoration: InputDecoration(
            hintText: request.placeholder,
            errorText: errorText,
            filled: true,
            fillColor: AppTheme.card(context),
          ),
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Submit'),
        ),
      ],
    );
  }
}

class _ChoicePicker extends StatelessWidget {
  const _ChoicePicker({
    required this.request,
    required this.selected,
    required this.onChanged,
    required this.onSubmit,
  });

  final FieldRequest request;
  final String selected;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RadioGroup<String>(
          groupValue: selected.isEmpty ? null : selected,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: Column(
            children: [
              for (final choice in request.choices)
                RadioListTile<String>(
                  value: choice,
                  title: Text(choice),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: selected.isEmpty ? null : onSubmit,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Submit'),
        ),
      ],
    );
  }
}

class _SubmittedPill extends StatelessWidget {
  const _SubmittedPill({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, color: scheme.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            'Submitted · $value',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

TextInputType _keyboardFor(FieldKind k) {
  switch (k) {
    case FieldKind.number:
    case FieldKind.tin:
      return TextInputType.number;
    case FieldKind.businessReg:
    case FieldKind.parcelId:
      return TextInputType.text;
    case FieldKind.nationalId:
      return TextInputType.visiblePassword;
    case FieldKind.date:
      return TextInputType.datetime;
    case FieldKind.choice:
    case FieldKind.text:
      return TextInputType.text;
  }
}

List<TextInputFormatter> _formattersFor(FieldKind k, int? maxLength) {
  final formatters = <TextInputFormatter>[];
  switch (k) {
    case FieldKind.tin:
    case FieldKind.number:
      formatters.add(FilteringTextInputFormatter.digitsOnly);
      break;
    case FieldKind.nationalId:
    case FieldKind.businessReg:
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')));
      break;
    case FieldKind.parcelId:
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9/\-]')));
      break;
    case FieldKind.date:
    case FieldKind.text:
    case FieldKind.choice:
      break;
  }
  if (maxLength != null) {
    formatters.add(LengthLimitingTextInputFormatter(maxLength));
  }
  return formatters;
}

String _patternHint(FieldKind k) {
  switch (k) {
    case FieldKind.tin:
      return 'TIN should be 10 digits.';
    case FieldKind.nationalId:
      return 'National ID format looks wrong — check it and try again.';
    case FieldKind.parcelId:
      return 'Parcel id should look like KCCA/BLOCK-203/PLOT-114.';
    case FieldKind.businessReg:
      return 'Business registration number looks wrong — check it and try again.';
    default:
      return 'That doesn\'t look quite right — please check the format.';
  }
}

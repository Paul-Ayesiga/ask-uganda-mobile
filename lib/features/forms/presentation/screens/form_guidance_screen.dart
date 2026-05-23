import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/assisted_form.dart';

class FormGuidanceScreen extends StatefulWidget {
  const FormGuidanceScreen({super.key, AssistedForm? form})
    : form = form ?? AssistedFormsCatalogue.birthCertificate;

  final AssistedForm form;

  @override
  State<FormGuidanceScreen> createState() => _FormGuidanceScreenState();
}

class _FormGuidanceScreenState extends State<FormGuidanceScreen> {
  int _currentIndex = 0;
  final Map<String, String> _values = {};
  final TextEditingController _controller = TextEditingController();
  String? _choice;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AssistedFormField get _field => widget.form.fields[_currentIndex];

  bool get _isLast => _currentIndex == widget.form.fields.length - 1;

  void _next() {
    final value = _choice ?? _controller.text.trim();
    if (value.isEmpty && _field.required) return;
    _values[_field.id] = value;
    if (_isLast) {
      context.push('/forms/review', extra: {
        'form': widget.form,
        'values': _values,
      });
      return;
    }
    setState(() {
      _currentIndex += 1;
      _controller.clear();
      _choice = null;
    });
  }

  void _back() {
    if (_currentIndex == 0) {
      context.pop();
      return;
    }
    setState(() {
      _currentIndex -= 1;
      _controller.text = _values[_field.id] ?? '';
      _choice = _field.kind == FormFieldKind.choice ? _values[_field.id] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final field = _field;
    final progress = (_currentIndex + 1) / widget.form.fields.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.form.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.line(context),
            valueColor: AlwaysStoppedAnimation(scheme.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    'Step ${_currentIndex + 1} of ${widget.form.fields.length}',
                    style: textTheme.bodyMedium?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(field.label, style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(field.explanation, style: textTheme.bodyLarge),
                  if (field.example != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        border: Border.all(color: AppTheme.line(context)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Example: ${field.example}',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _FieldInput(
                    field: field,
                    controller: _controller,
                    selectedChoice: _choice,
                    onChoiceChanged: (value) =>
                        setState(() => _choice = value),
                  ),
                  if (field.canPrefillViaGuva) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.flagYellow.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.flagYellow.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Ask Uganda can verify this against GUVA before '
                              'you submit. You will be asked for consent.',
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _back,
                        child: Text(_currentIndex == 0 ? 'Cancel' : 'Back'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(_isLast ? 'Review' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldInput extends StatelessWidget {
  const _FieldInput({
    required this.field,
    required this.controller,
    required this.selectedChoice,
    required this.onChoiceChanged,
  });

  final AssistedFormField field;
  final TextEditingController controller;
  final String? selectedChoice;
  final ValueChanged<String> onChoiceChanged;

  @override
  Widget build(BuildContext context) {
    switch (field.kind) {
      case FormFieldKind.choice:
        return RadioGroup<String>(
          groupValue: selectedChoice,
          onChanged: (value) {
            if (value != null) onChoiceChanged(value);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final choice in field.choices)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: RadioListTile<String>(
                    value: choice,
                    title: Text(choice),
                  ),
                ),
            ],
          ),
        );
      case FormFieldKind.multiline:
        return TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(hintText: 'Type your notes…'),
        );
      case FormFieldKind.date:
        return TextField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          decoration: const InputDecoration(hintText: 'YYYY-MM-DD'),
        );
      case FormFieldKind.number:
        return TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '0'),
        );
      case FormFieldKind.identityLinked:
      case FormFieldKind.text:
        return TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Type your answer…'),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class DocumentGuidanceScreen extends StatelessWidget {
  const DocumentGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Document guidance'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Get your documents ready', style: textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Most rejected applications fail because of a missing or unclear '
              'document. Ask Uganda can help you check what you have before '
              'you submit.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            _DocumentTile(
              icon: Icons.badge_outlined,
              title: 'National ID',
              subtitle: 'Photograph the front and back. Both sides legible.',
              onCapture: () => context.push('/documents/capture', extra: {
                'documentType': 'National ID',
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            _DocumentTile(
              icon: Icons.assignment_outlined,
              title: 'Notification of Birth',
              subtitle:
                  'Capture the original. Edges must be visible and text sharp.',
              onCapture: () => context.push('/documents/capture', extra: {
                'documentType': 'Notification of Birth',
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            _DocumentTile(
              icon: Icons.receipt_long_outlined,
              title: 'Proof of payment',
              subtitle: 'Receipt or PRN reference.',
              onCapture: () => context.push('/documents/capture', extra: {
                'documentType': 'Proof of payment',
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Ask Uganda checks whether a document looks like the '
                      'right type and is legible. The agency makes the final '
                      'decision on validity.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onCapture,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.line(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onCapture,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.page(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.camera_alt_outlined),
            ],
          ),
        ),
      ),
    );
  }
}

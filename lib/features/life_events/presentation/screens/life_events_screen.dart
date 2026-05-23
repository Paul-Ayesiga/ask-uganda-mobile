import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/life_event.dart';

class LifeEventsScreen extends StatelessWidget {
  const LifeEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Life events'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'A life event often triggers several government interactions. '
              'Pick what fits your situation and Ask Uganda will guide you '
              'through the whole sequence.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final event in LifeEventsCatalogue.all) ...[
              _LifeEventTile(
                event: event,
                onTap: () =>
                    context.push('/life-events/${event.id}', extra: event),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _LifeEventTile extends StatelessWidget {
  const _LifeEventTile({required this.event, required this.onTap});

  final LifeEvent event;
  final VoidCallback onTap;

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.page(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(event.icon, color: scheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.label, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      event.summary,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.alt_route_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${event.steps.length} steps',
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

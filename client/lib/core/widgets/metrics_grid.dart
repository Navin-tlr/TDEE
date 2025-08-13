import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetricsGrid extends StatelessWidget {
  final Map<String, String> metrics; // title -> value

  const MetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final entries = metrics.entries.toList();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _cell(context, entries[0].key, entries[0].value)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _cell(context, entries[1].key, entries[1].value)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(child: _cell(context, entries[2].key, entries[2].value)),
              const SizedBox(width: Spacing.md),
              Expanded(child: _cell(context, entries[3].key, entries[3].value)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}



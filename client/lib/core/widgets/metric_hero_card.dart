import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetricHeroCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? background;

  const MetricHeroCard({
    super.key,
    required this.title,
    required this.value,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background ?? Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20), // 20 pt radius per spec
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(20), // 20 pt padding per spec
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
          ),
        ],
      ),
    );
  }
}



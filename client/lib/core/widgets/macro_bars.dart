import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MacroBarsCard extends StatelessWidget {
  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int targetProteinG;
  final int targetCarbsG;
  final int targetFatG;

  const MacroBarsCard({
    super.key,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatG,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Macro-nutrients', style: AppTheme.caption13.copyWith(color: AppTheme.secondaryLabelColor(context))),
              const Spacer(),
              Text('$kcal kcal', style: AppTheme.hero24.copyWith(color: AppTheme.labelColor(context))),
            ],
          ),
          const SizedBox(height: 12),
          _bar(context, 'Protein', proteinG, targetProteinG, Colors.red),
          const SizedBox(height: 12),
          _bar(context, 'Carbs', carbsG, targetCarbsG, Colors.blue),
          const SizedBox(height: 12),
          _bar(context, 'Fat', fatG, targetFatG, Colors.green),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, String label, int value, int target, Color color) {
    final double pct = target == 0 ? 0 : (value / target).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTheme.body17.copyWith(color: AppTheme.labelColor(context))),
            const Spacer(),
            Text('$value g / $target g', style: AppTheme.caption13.copyWith(color: AppTheme.secondaryLabelColor(context))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                Container(color: Theme.of(context).colorScheme.surfaceVariant),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(color: color.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

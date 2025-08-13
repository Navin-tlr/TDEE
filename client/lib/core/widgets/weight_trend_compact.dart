import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../theme/app_theme.dart';
import '../../features/dashboard/chart_data_provider.dart';

class WeightTrendCompact extends StatelessWidget {
  final List<WeightDataPoint> data;
  final String title;
  final String heroValue;
  final String deltaLabel;
  final Color deltaColor;

  const WeightTrendCompact({
    super.key,
    required this.data,
    required this.title,
    required this.heroValue,
    required this.deltaLabel,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120, // was 104; give chart + text more room
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64, // give chart a bit more width
            child: _buildMiniChart(context),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.2)),
                const SizedBox(height: 2),
                Text(
                  heroValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium // slightly smaller than before
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      deltaColor == Colors.green
                          ? Icons.trending_down
                          : Icons.trending_up,
                      size: 14,
                      color: deltaColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        deltaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: deltaColor, height: 1.2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          '—',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: const DateTimeAxis(isVisible: false),
      primaryYAxis: const NumericAxis(isVisible: false),
      series: <CartesianSeries>[
        LineSeries<WeightDataPoint, DateTime>(
          dataSource: data,
          xValueMapper: (WeightDataPoint d, _) => d.date,
          yValueMapper: (WeightDataPoint d, _) => d.weightKg,
          color: Theme.of(context).colorScheme.primary,
          width: 2,
          markerSettings: const MarkerSettings(isVisible: false),
        ),
      ],
    );
  }
}

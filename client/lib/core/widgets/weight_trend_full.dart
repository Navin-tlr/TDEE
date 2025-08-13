import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../theme/app_theme.dart';
import '../../features/dashboard/chart_data_provider.dart';
import 'dart:math' as math;

class WeightTrendFullCard extends StatelessWidget {
  final List<WeightDataPoint> data;
  const WeightTrendFullCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<_Point> points = data.isNotEmpty ? _fromData(data) : _placeholder();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      height: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Weight Trend', style: AppTheme.caption13.copyWith(color: AppTheme.secondaryLabelColor(context))),
              const Spacer(),
              Text(
                data.isNotEmpty ? '${data.last.weightKg.toStringAsFixed(1)} kg' : '—',
                style: AppTheme.hero24.copyWith(color: AppTheme.labelColor(context)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: const DateTimeAxis(isVisible: false),
              primaryYAxis: const NumericAxis(isVisible: false),
              series: <CartesianSeries>[
                AreaSeries<_Point, DateTime>(
                  dataSource: points,
                  xValueMapper: (p, _) => p.x,
                  yValueMapper: (p, _) => p.y,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderColor: Theme.of(context).colorScheme.primary,
                  borderWidth: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_Point> _fromData(List<WeightDataPoint> src) => src
      .map((d) => _Point(d.date, d.weightKg))
      .toList();

  List<_Point> _placeholder() {
    final now = DateTime.now();
    final List<_Point> pts = [];
    for (int i = 27; i >= 0; i--) {
      final dt = now.subtract(Duration(days: i));
      final base = 75.0 + math.sin(i / 3.0) * 0.3;
      pts.add(_Point(dt, base + math.Random(i).nextDouble() * 0.2));
    }
    return pts;
  }
}

class _Point {
  final DateTime x;
  final double y;
  _Point(this.x, this.y);
}

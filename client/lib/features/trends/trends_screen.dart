import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/chart_data_provider.dart';

class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});
  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _segmentIndex = 0; // 0: Weight, 1: Expenditure

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_segmentIndex != _tabController.index) {
          setState(() => _segmentIndex = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trends'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _CupertinoSegmentedBar(
            labels: const ['Weight', 'Expenditure'],
            index: _segmentIndex,
            onChanged: (i) {
              setState(() => _segmentIndex = i);
              _tabController.animateTo(i);
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          WeightTrendTab(),
          ExpenditureTrendTab(),
        ],
      ),
    );
  }
}

class _CupertinoSegmentedBar extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const _CupertinoSegmentedBar({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 8),
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Animated underline/selection capsule
          AnimatedPositioned(
            duration: AppTheme.shortAnimation,
            curve: Curves.easeInOut,
            left: (MediaQuery.of(context).size.width - (Spacing.sm * 2)) /
                    labels.length *
                index,
            width: (MediaQuery.of(context).size.width - (Spacing.sm * 2)) /
                labels.length,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < labels.length; i++)
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onChanged(i),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: i == index
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeightTrendTab extends ConsumerWidget {
  const WeightTrendTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightDataAsync = ref.watch(weightDataStreamProvider);
    return weightDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (weightData) {
        if (weightData.isEmpty) {
          return _empty(context);
        }
        return Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Column(
            children: [
              _ChartHeader(title: 'Weight', value: '${weightData.last.weightKg.toStringAsFixed(1)} kg'),
              const SizedBox(height: Spacing.md),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat('MMM d'),
                    intervalType: DateTimeIntervalType.days,
                    interval: 7,
                    majorGridLines: const MajorGridLines(width: 0),
                    minorGridLines: const MinorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
                    labelFormat: '{value} kg',
                  ),
                  series: <CartesianSeries>[
                    LineSeries<WeightDataPoint, DateTime>(
                      dataSource: weightData,
                      xValueMapper: (d, _) => d.date,
                      yValueMapper: (d, _) => d.weightKg,
                      width: 3,
                      color: Theme.of(context).colorScheme.primary,
                      markerSettings: const MarkerSettings(isVisible: false),
                      animationDuration: 800,
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true, canShowMarker: true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up_outlined, size: 48, color: AppTheme.secondaryLabelColor(context)),
              const SizedBox(height: Spacing.sm),
              Text('No weight yet', style: AppTheme.body17),
              const SizedBox(height: 4),
              Text('Log weight to start trends', style: AppTheme.caption13.copyWith(color: AppTheme.secondaryLabelColor(context))),
            ],
          ),
        ),
      );
}

class ExpenditureTrendTab extends StatelessWidget {
  const ExpenditureTrendTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.sm),
      child: Column(
        children: [
          const _ChartHeader(title: 'Expenditure', value: '—'),
          const SizedBox(height: Spacing.md),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: const Center(child: Text('Expenditure trends coming soon...')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  final String title;
  final String value;
  const _ChartHeader({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.caption13.copyWith(color: AppTheme.secondaryLabelColor(context))),
        const Spacer(),
        Text(value, style: AppTheme.hero24.copyWith(color: AppTheme.labelColor(context))),
      ],
    );
  }
}

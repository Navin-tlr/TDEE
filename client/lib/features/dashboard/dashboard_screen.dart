import 'package:client/features/dashboard/chart_data_provider.dart';
import 'package:client/features/food_log/food_log_screen.dart';
import 'package:client/features/weight_log/weight_log_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:client/features/auth/auth_provider.dart';
import '../../core/widgets/metric_hero_card.dart';
import '../../core/widgets/metrics_grid.dart';
import '../../core/widgets/dashboard_card.dart';
import '../../core/widgets/next_target_card.dart';
import '../../core/widgets/macro_ring.dart';
import '../../core/widgets/weight_trend_compact.dart';
import '../../core/widgets/insight_pill.dart';
import '../../core/theme/app_theme.dart';
import 'dashboard_provider.dart';
import 'daily_stats.dart';
import '../../core/widgets/weight_trend_full.dart';
import '../../core/widgets/macro_bars.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedPillIndex = 0;

  // Method to handle the approval transaction.
  void _approveNewTarget(WidgetRef ref, BuildContext context) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw Exception("User document does not exist!");
        }

        final bool isAlreadyApproved = snapshot.data()?['approved'] ?? true;
        if (!isAlreadyApproved) {
          final nextTarget = snapshot.data()?['next_target_kcal'];
          transaction.update(userRef, {
            'approved': true,
            'last_approved_kcal': nextTarget,
          });
        }
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text("New target approved successfully.")),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("Failed to approve new target: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyStatsAsync = ref.watch(dailyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Today',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: Spacing.xs),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.person, size: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, size: 18),
            tooltip: 'Sync Status',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: dailyStatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (stats) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Spacing.sm),
                  // Full weight trend with placeholder when empty
                  ref.watch(weightDataStreamProvider).when(
                    loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => const WeightTrendFullCard(data: []),
                    data: (d) => WeightTrendFullCard(data: d),
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Macro-nutrients bars (consumed vs targets)
                  MacroBarsCard(
                    kcal: stats.currentCalories,
                    proteinG: stats.proteinGrams,
                    carbsG: stats.carbsGrams,
                    fatG: stats.fatGrams,
                    // Placeholder targets; later wire from user settings/targets
                    targetProteinG: 150,
                    targetCarbsG: 250,
                    targetFatG: 60,
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Micro-nutrients analytics placeholder (future charts)
                  Container(
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
                        Text('Micro-nutrients', style: AppTheme.caption13.copyWith(color: AppTheme.secondaryLabelColor(context))),
                        const SizedBox(height: 12),
                        Text('Coming soon: fiber, sodium, sugar, micronutrient charts', style: AppTheme.body17.copyWith(color: AppTheme.secondaryLabelColor(context))),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  if (!stats.isApproved && stats.nextTargetKcal != null)
                    NextTargetCard(
                      kcal: stats.nextTargetKcal!,
                      deltaWeight: -0.5,
                      daysToReview: 3,
                      goal: 'cut',
                      onAccept: () => _approveNewTarget(ref, context),
                    ),
                  if (!stats.isApproved && stats.nextTargetKcal != null)
                    const SizedBox(height: Spacing.sm),
                  _buildEnergyInsightStrip(context, stats),
                  const SizedBox(height: Spacing.sm),
                  _buildMacroRingSection(context, stats),
                  const SizedBox(height: Spacing.sm),
                  _buildStreaks(context),
                  const SizedBox(height: Spacing.sm),
                  // Current calorie target hero
                  MetricHeroCard(
                    title: 'Current Calorie Target',
                    value: (stats.lastApprovedKcal ?? 0).toString(),
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Unified metrics grid
                  MetricsGrid(
                    metrics: {
                      'Calories Logged': stats.currentCalories.toString(),
                      'Protein (g)': stats.proteinGrams.toString(),
                      'Carbs (g)': stats.carbsGrams.toString(),
                      'Fat (g)': stats.fatGrams.toString(),
                    },
                  ),
                  const SizedBox(height: Spacing.lg),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FoodLogScreen()),
          );
        },
        tooltip: 'Log Food',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeightTrendCard(BuildContext context, WidgetRef ref) {
    return ref.watch(weightDataStreamProvider).when(
      loading: () => const SizedBox(height: 104, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => WeightTrendCompact(
        data: const [],
        title: 'Weight Trend',
        heroValue: '—',
        deltaLabel: 'Log weight to see trends',
        deltaColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      data: (weightData) => WeightTrendCompact(
        data: weightData,
        title: 'Weight Trend',
        heroValue: weightData.isNotEmpty ? '${weightData.last.weightKg.toStringAsFixed(1)} kg' : '—',
        deltaLabel: weightData.length > 1 ? '-0.3 kg vs last week' : ' ',
        deltaColor: Colors.green,
      ),
    );
  }

  Widget _buildEnergyInsightStrip(BuildContext context, DailyStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 700;
        final gap = isWide ? Spacing.md : Spacing.sm;
        final tints = [
          Theme.of(context).colorScheme.primary.withOpacity(0.06),
          Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.35),
          Theme.of(context).colorScheme.tertiaryContainer?.withOpacity(0.35) ??
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.25),
        ];

        Widget pill(String label, String value, {String? sub, IconData? icon, Color? color, bool selected = false, VoidCallback? onTap, Color? tint}) {
          return InsightPill(
            label: label,
            value: value,
            sublabel: sub,
            trendIcon: icon,
            trendColor: color,
            selected: selected,
            onTap: onTap,
            tint: tint,
          );
        }

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: pill(
                  'TDEE',
                  '${stats.lastApprovedKcal ?? 0} kcal',
                  sub: '+25 kcal',
                  icon: Icons.north_east,
                  color: Colors.green,
                  selected: _selectedPillIndex == 0,
                  onTap: () => setState(() => _selectedPillIndex = 0),
                  tint: tints[0],
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: pill(
                  'Avg. Intake',
                  '2,180 kcal',
                  selected: _selectedPillIndex == 1,
                  onTap: () => setState(() => _selectedPillIndex = 1),
                  tint: tints[1],
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: pill(
                  'Projected',
                  '-0.42 kg',
                  sub: 'vs goal -0.35 kg',
                  selected: _selectedPillIndex == 2,
                  onTap: () => setState(() => _selectedPillIndex = 2),
                  tint: tints[2],
                ),
              ),
            ],
          );
        }

        // Narrow: use fixed-width tiles inside horizontal scroll (no Expanded)
        final tileWidth = (constraints.maxWidth * 0.72).clamp(220.0, 320.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: tileWidth,
                child: pill(
                  'TDEE',
                  '${stats.lastApprovedKcal ?? 0} kcal',
                  sub: '+25 kcal',
                  icon: Icons.north_east,
                  color: Colors.green,
                  selected: _selectedPillIndex == 0,
                  onTap: () => setState(() => _selectedPillIndex = 0),
                  tint: tints[0],
                ),
              ),
              SizedBox(width: gap),
              SizedBox(
                width: tileWidth,
                child: pill(
                  'Avg. Intake',
                  '2,180 kcal',
                  selected: _selectedPillIndex == 1,
                  onTap: () => setState(() => _selectedPillIndex = 1),
                  tint: tints[1],
                ),
              ),
              SizedBox(width: gap),
              SizedBox(
                width: tileWidth,
                child: pill(
                  'Projected',
                  '-0.42 kg',
                  sub: 'vs goal -0.35 kg',
                  selected: _selectedPillIndex == 2,
                  onTap: () => setState(() => _selectedPillIndex = 2),
                  tint: tints[2],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroRingSection(BuildContext context, DailyStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            Text(
              'Macro Ring',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: Spacing.md),
            MacroRing(
              protein: stats.proteinGrams.toDouble(),
              carbs: stats.carbsGrams.toDouble(),
              fats: stats.fatGrams.toDouble(),
              totalKcal: stats.currentCalories.toDouble(),
              size: 140,
              onTap: () {
                // TODO: Show macro detail
              },
            ),
            const SizedBox(height: Spacing.md),
            // Quick log buttons
            Row(
              children: [
                Expanded(
                  child: _buildQuickLogChip(context, 'Breakfast', Icons.wb_sunny),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _buildQuickLogChip(context, 'Lunch', Icons.restaurant),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _buildQuickLogChip(context, 'Dinner', Icons.nights_stay),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: _buildQuickLogChip(context, 'Snack', Icons.coffee),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLogChip(BuildContext context, String label, IconData icon) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Quick log
          },
          borderRadius: BorderRadius.circular(AppTheme.chipRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreaks(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStreakCard(
            context,
            Icons.local_fire_department,
            '14 days',
            'Logging streak',
            Colors.orange,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _buildStreakCard(
            context,
            Icons.monitor_weight,
            '9 days',
            'Weigh-in streak',
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: Spacing.xs),
            Text(
              count,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
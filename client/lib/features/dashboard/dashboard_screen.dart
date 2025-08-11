import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/metric_card.dart';
import 'dashboard_provider.dart';

// Convert from StatelessWidget to ConsumerWidget
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  // Add the WidgetRef parameter
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider. Riverpod will automatically handle loading/error states.
    final dailyStatsAsync = ref.watch(dailyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Use the 'when' method to handle the different states of our data stream
        child: dailyStatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (snapshot) {
            // Check if today's document exists and has data
            final data = snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
            final calories = data?['kcal']?.toString() ?? '0';
            final protein = data?['p_g']?.toString() ?? '0';
            final carbs = data?['c_g']?.toString() ?? '0';
            final fat = data?['f_g']?.toString() ?? '0';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main hero card remains the same
                Card(
                  elevation: 4,
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Weight Trend & Macro Chart Area',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Metrics are now powered by live data
                Row(
                  children: [
                    MetricCard(title: 'Calories', value: calories),
                    const SizedBox(width: 16),
                    MetricCard(title: 'Protein (g)', value: protein),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    MetricCard(title: 'Carbs (g)', value: carbs),
                    const SizedBox(width: 16),
                    MetricCard(title: 'Fat (g)', value: fat),
                  ],
                ),
              ],
            );
          },
        ),
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Food Logging screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
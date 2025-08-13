import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class StrategyScreen extends ConsumerStatefulWidget {
  const StrategyScreen({super.key});

  @override
  ConsumerState<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends ConsumerState<StrategyScreen> {
  String _currentGoal = 'Cut';
  double _targetAdjustment = 0.0;
  bool _isAdjusting = false;
  final TextEditingController _targetController = TextEditingController(text: '2285');

  @override
  void initState() {
    super.initState();
    _targetController.addListener(_onTargetChanged);
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _onTargetChanged() {
    // TODO: Update projected weight calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Goal card
              _buildGoalCard(),
              const SizedBox(height: Spacing.sm),

              // Proposed plan card
              _buildProposedPlanCard(),
              const SizedBox(height: Spacing.sm),

              // Audit table
              _buildAuditTable(),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard() {
    final goalColor = GoalColors.getColorForGoal(_currentGoal);
    final goalIcon = _getGoalIcon(_currentGoal);
    final goalDescription = _getGoalDescription(_currentGoal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(goalIcon, color: goalColor, size: 32),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Goal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        goalDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showGoalEditor(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposedPlanCard() {
    final goalColor = GoalColors.getColorForGoal(_currentGoal);
    final adjustedTarget = 2285 + _targetAdjustment.round();

    return Card(
      color: goalColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proposed Plan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.md),
            
            // Target display
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New daily target:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        '${adjustedTarget} kcal',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: goalColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showTargetEditor(context),
                ),
              ],
            ),
            
            const SizedBox(height: Spacing.md),
            
            // Adjustment slider
            Text(
              'Adjustment:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.xs),
            Slider(
              value: _targetAdjustment,
              min: -100.0,
              max: 100.0,
              divisions: 8,
              label: '${_targetAdjustment.round()} kcal',
              onChanged: (value) {
                setState(() {
                  _targetAdjustment = value;
                });
              },
            ),
            
            const SizedBox(height: Spacing.md),
            
            // Projected weight info
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: goalColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.chipRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentGoal == 'Cut' ? Icons.trending_down : Icons.trending_up,
                    color: goalColor,
                    size: 20,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Projected: ${_currentGoal == 'Cut' ? '-' : '+'}0.5% BW/week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: goalColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: Spacing.md),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showConfirmationModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goalColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Accept & Start Monday'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isAdjusting = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: goalColor),
                      foregroundColor: goalColor,
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Adjust & Save Draft'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.md),
            const _AuditTable(),
          ],
        ),
      ),
    );
  }

  void _showGoalEditor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildGoalEditor(context),
    );
  }

  Widget _buildGoalEditor(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Change Goal',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Spacing.md),
          
          // Goal options
          _buildGoalOption(context, 'Cut', Icons.trending_down, 'Lose weight steadily'),
          _buildGoalOption(context, 'Bulk', Icons.trending_up, 'Gain weight steadily'),
          _buildGoalOption(context, 'Recomp', Icons.trending_flat, 'Maintain weight, improve composition'),
          
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }

  Widget _buildGoalOption(BuildContext context, String goal, IconData icon, String description) {
    final isSelected = _currentGoal == goal;
    final goalColor = GoalColors.getColorForGoal(goal);
    
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: ListTile(
        leading: Icon(icon, color: goalColor),
        title: Text(goal),
        subtitle: Text(description),
        trailing: isSelected ? Icon(Icons.check, color: goalColor) : null,
        selected: isSelected,
        onTap: () {
          setState(() {
            _currentGoal = goal;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showTargetEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Target'),
        content: TextField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily Target (kcal)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update target
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationModal(BuildContext context) {
    final goalColor = GoalColors.getColorForGoal(_currentGoal);
    final adjustedTarget = 2285 + _targetAdjustment.round();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Target'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New daily target: $adjustedTarget kcal'),
            const SizedBox(height: Spacing.sm),
            Text('Goal: $_currentGoal'),
            const SizedBox(height: Spacing.sm),
            const Text('This target will start on Monday. Are you sure?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _acceptTarget(context);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: goalColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _acceptTarget(BuildContext context) {
    // Haptic feedback
    HapticFeedback.heavyImpact();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Target accepted! Starts Monday.'),
        backgroundColor: GoalColors.getColorForGoal(_currentGoal),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // TODO: Update target status in database
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Cut':
        return Icons.trending_down;
      case 'Bulk':
        return Icons.trending_up;
      case 'Recomp':
        return Icons.trending_flat;
      default:
        return Icons.trending_flat;
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'Cut':
        return 'Cut –0.5 % BW/wk';
      case 'Bulk':
        return 'Bulk +0.5 % BW/wk';
      case 'Recomp':
        return 'Recomp ±0.0 % BW/wk';
      default:
        return 'Recomp ±0.0 % BW/wk';
    }
  }
}

class _AuditTable extends StatelessWidget {
  const _AuditTable();

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Theme.of(context).dividerColor),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Week', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Target', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Actual', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Δ Weight', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('TDEE Δ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        TableRow(
          children: const [
            Padding(padding: EdgeInsets.all(8.0), child: Text('Week 12')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('2,200')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('2,180')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('-0.4 kg')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('+56 kcal')),
          ],
        ),
        TableRow(
          children: const [
            Padding(padding: EdgeInsets.all(8.0), child: Text('Week 11')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('2,200')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('2,150')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('-0.5 kg')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('+23 kcal')),
          ],
        ),
        TableRow(
          children: const [
            Padding(padding: EdgeInsets.all(8.0), child: Text('Week 10')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('2,200')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('2,220')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('-0.3 kg')),
            Padding(padding: EdgeInsets.all(8.0), child: Text('-12 kcal')),
          ],
        ),
      ],
    );
  }
}

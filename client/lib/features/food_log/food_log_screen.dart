import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'food_log_provider.dart';

class FoodLogScreen extends ConsumerStatefulWidget {
  const FoodLogScreen({super.key});

  @override
  ConsumerState<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends ConsumerState<FoodLogScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // Swipeable week date picker
              _buildWeekDatePicker(),
              const SizedBox(height: Spacing.sm),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Inline search
          Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),
          
          // Food entries list
          Expanded(
            child: _buildFoodEntriesList(),
          ),
          
          // Footer macro tally
          _buildMacroTallyFooter(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFoodEntrySheet();
        },
        tooltip: 'Add Food',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeekDatePicker() {
    final weekDates = _getWeekDates(_selectedDate);
    
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: Spacing.xs),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : isToday 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.chipRadius),
                border: isSelected 
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodEntriesList() {
    // TODO: Replace with actual food entries from provider
    final mockEntries = [
      {'name': 'Oatmeal', 'kcal': 150, 'protein': 6, 'carbs': 27, 'fat': 3, 'serving': '1 cup'},
      {'name': 'Banana', 'kcal': 105, 'protein': 1, 'carbs': 27, 'fat': 0, 'serving': '1 medium'},
      {'name': 'Greek Yogurt', 'kcal': 130, 'protein': 23, 'carbs': 9, 'fat': 0, 'serving': '1 cup'},
    ];

    if (mockEntries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      itemCount: mockEntries.length,
      itemBuilder: (context, index) {
        final entry = mockEntries[index];
        return _buildFoodEntryCard(entry, index);
      },
    );
  }

  Widget _buildFoodEntryCard(Map<String, dynamic> entry, int index) {
    return Dismissible(
      key: Key('food_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Spacing.md),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // TODO: Delete food entry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${entry['name']} removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // TODO: Undo delete
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: Spacing.xs),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.chipRadius),
            ),
            child: Icon(
              Icons.restaurant,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            entry['name'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${entry['serving']} • ${entry['kcal']} kcal',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMacroChip('P', entry['protein'], Colors.red),
              const SizedBox(width: 4),
              _buildMacroChip('C', entry['carbs'], Colors.blue),
              const SizedBox(width: 4),
              _buildMacroChip('F', entry['fat'], Colors.green),
            ],
          ),
          onLongPress: () {
            // TODO: Show copy/delete options
          },
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'No food logged today',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Tap ➕ to log your first meal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTallyFooter() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  '1,245 kcal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildMacroTally('P', 45, Colors.red),
              const SizedBox(width: Spacing.md),
              _buildMacroTally('C', 180, Colors.blue),
              const SizedBox(width: Spacing.md),
              _buildMacroTally('F', 35, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTally(String label, int value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$value g',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showFoodEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFoodEntrySheet(),
    );
  }

  Widget _buildFoodEntrySheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: Spacing.sm),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Tabs
              Container(
                margin: const EdgeInsets.only(top: Spacing.md),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Scan'),
                    Tab(text: 'Quick Add'),
                    Tab(text: 'Frequent'),
                    Tab(text: 'Meals'),
                    Tab(text: 'Recipe'),
                  ],
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScanTab(),
                    _buildQuickAddTab(),
                    _buildFrequentTab(),
                    _buildMealsTab(),
                    _buildRecipeTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanTab() {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 48, color: Colors.grey),
                  SizedBox(height: Spacing.sm),
                  Text('Camera preview placeholder'),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Point camera at barcode',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Position the barcode within the frame to scan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddTab() {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        children: [
          Text(
            'Quick Add',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Calories',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Add quick entry
                Navigator.of(context).pop();
              },
              child: const Text('Add Entry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequentTab() {
    return const Center(child: Text('Frequent foods coming soon...'));
  }

  Widget _buildMealsTab() {
    return const Center(child: Text('Saved meals coming soon...'));
  }

  Widget _buildRecipeTab() {
    return const Center(child: Text('Recipe builder coming soon...'));
  }

  List<DateTime> _getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
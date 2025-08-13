import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../theme/app_theme.dart';

class MacroRing extends StatefulWidget {
  final double protein;
  final double carbs;
  final double fats;
  final double totalKcal;
  final double size;
  final double thickness;
  final VoidCallback? onTap;

  const MacroRing({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.totalKcal,
    this.size = 120.0,
    this.thickness = 8.0,
    this.onTap,
  });

  @override
  State<MacroRing> createState() => _MacroRingState();
}

class _MacroRingState extends State<MacroRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.longAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.protein + widget.carbs + widget.fats;
    final macroData = [
      MacroData('Protein', widget.protein, Colors.red),
      MacroData('Carbs', widget.carbs, Colors.blue),
      MacroData('Fat', widget.fats, Colors.green),
    ];

    return GestureDetector(
      onTap: () {
        _triggerPulse();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Macro ring chart
                  SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<MacroData, String>(
                        dataSource: macroData,
                        xValueMapper: (MacroData data, _) => data.name,
                        yValueMapper: (MacroData data, _) => data.value,
                        pointColorMapper: (MacroData data, _) => data.color,
                        innerRadius: '60%',
                        radius: '100%',
                        dataLabelSettings: const DataLabelSettings(isVisible: false),
                      ),
                    ],
                  ),
                  
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${widget.totalKcal.toInt()}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'kcal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MacroData {
  final String name;
  final double value;
  final Color color;

  MacroData(this.name, this.value, this.color);
}

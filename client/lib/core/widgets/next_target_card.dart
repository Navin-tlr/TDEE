import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class NextTargetCard extends StatefulWidget {
  final int kcal;
  final double deltaWeight;
  final int daysToReview;
  final VoidCallback? onAccept;
  final VoidCallback? onPause;
  final VoidCallback? onAdjust;
  final String goal;

  const NextTargetCard({
    super.key,
    required this.kcal,
    required this.deltaWeight,
    required this.daysToReview,
    required this.goal,
    this.onAccept,
    this.onPause,
    this.onAdjust,
  });

  @override
  State<NextTargetCard> createState() => _NextTargetCardState();
}

class _NextTargetCardState extends State<NextTargetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.shortAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAccept() async {
    if (_isAccepted || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Animate button press
    await _animationController.forward();
    await _animationController.reverse();

    // Call the accept callback
    widget.onAccept?.call();

    // Show success state
    setState(() {
      _isAccepted = true;
      _isLoading = false;
    });

    // Show success toast
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Target accepted — starts Monday'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.chipRadius),
          ),
        ),
      );
    }

    // Haptic success feedback
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final goalColor = GoalColors.getColorForGoal(widget.goal);
    final backgroundColor = goalColor.withOpacity(0.1);

    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero text
            Text(
              'Next week target',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: goalColor,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            
            // Large numeric target
            Text(
              '${widget.kcal} kcal',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: goalColor,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            
            // Microcopy
            Text(
              '${widget.deltaWeight > 0 ? '+' : ''}${widget.deltaWeight.toStringAsFixed(1)}% BW / wk • ${widget.daysToReview} days to review',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            
            // Buttons row
            Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ElevatedButton(
                          onPressed: _isAccepted ? null : _handleAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goalColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : _isAccepted
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check, size: 20),
                                        SizedBox(width: Spacing.xs),
                                        Text('Accepted'),
                                      ],
                                    )
                                  : const Text('Accept'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onPause,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: goalColor),
                      foregroundColor: goalColor,
                    ),
                    child: const Text('Pause'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onAdjust,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: goalColor),
                      foregroundColor: goalColor,
                    ),
                    child: const Text('Adjust'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

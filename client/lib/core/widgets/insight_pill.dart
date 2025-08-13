import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InsightPill extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final IconData? trendIcon;
  final Color? trendColor;
  final VoidCallback? onTap;
  final bool selected;
  final Color? tint;

  const InsightPill({
    super.key,
    required this.label,
    required this.value,
    this.sublabel,
    this.trendIcon,
    this.trendColor,
    this.onTap,
    this.selected = false,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tint ?? Theme.of(context).cardColor;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 96),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.caption13.copyWith(
                        color: AppTheme.secondaryLabelColor(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body17.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.labelColor(context),
                      ),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (trendIcon != null && trendColor != null)
                            Icon(trendIcon, size: 14, color: trendColor),
                          if (trendIcon != null) const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              sublabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.caption13.copyWith(
                                color: trendColor ??
                                    AppTheme.secondaryLabelColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: AppTheme.shortAnimation,
                curve: Curves.easeInOut,
                height: selected ? 3 : 0,
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppTheme.chipRadius),
                    bottomRight: Radius.circular(AppTheme.chipRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

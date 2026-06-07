import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A compact pill segmented control (e.g. Weekly / Monthly / Yearly). The
/// selected segment slides behind the active label.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.compact = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          final child = AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 8,
              vertical: 10,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? theme.colorScheme.surface : Colors.transparent,
              borderRadius: AppRadius.chip,
              boxShadow: selected ? AppShadows.soft : null,
            ),
            child: Text(
              labels[i],
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? AppColors.primary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          );
          final tappable = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(i),
            child: child,
          );
          return compact ? tappable : Expanded(child: tappable);
        }),
      ),
    );
  }
}

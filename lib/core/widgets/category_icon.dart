import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A rounded, tinted square holding a category's icon — used in lists, chips
/// and the add sheet. The fill is a soft tint of [color].
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 46,
    this.iconSize = 22,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  /// When true the icon sits on a solid [color] fill (white glyph).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: filled ? Colors.white : color,
      ),
    );
  }
}

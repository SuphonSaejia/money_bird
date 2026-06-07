import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// A circular, softly-shadowed icon button — the floating round controls in the
/// reference top bars (grid / notifications / back).
class SoftIconButton extends StatelessWidget {
  const SoftIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 46,
    this.iconSize = 22,
    this.background,
    this.foreground,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? foreground;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = background ?? theme.colorScheme.surface;
    final fg = foreground ?? theme.colorScheme.onSurface;
    return Material(
      color: bg,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: iconSize, color: fg),
              if (showDot)
                Positioned(
                  top: size * 0.26,
                  right: size * 0.28,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: bg, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

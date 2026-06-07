import 'package:flutter/material.dart';

/// The Money Bird logo mark, rendered from the bundled brand asset. Use this
/// wherever the brand appears in the UI.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}

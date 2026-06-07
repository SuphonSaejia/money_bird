import 'package:flutter/widgets.dart';

/// Spacing, radii and elevation tokens. Keeping these centralised makes the
/// whole UI breathe consistently — the reference design relies on generous
/// padding and large corner radii.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Standard horizontal page gutter.
  static const double page = 20;
}

class AppRadius {
  AppRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24; // default card radius
  static const double xxl = 32;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius cardLarge = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius input = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(pill));
}

/// Soft, diffuse shadows that give the cards their floating quality.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F1A2B5C), blurRadius: 24, offset: Offset(0, 10), spreadRadius: -6),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0A1A2B5C), blurRadius: 16, offset: Offset(0, 6), spreadRadius: -8),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1A2F6BFF), blurRadius: 28, offset: Offset(0, 14), spreadRadius: -6),
  ];
}

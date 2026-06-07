import 'package:flutter/material.dart';

/// Centralised colour palette for Money Bird.
///
/// The visual language is a soft, minimal, "neumorphic-light" style: a faint
/// blue-grey canvas, pure white cards with very soft shadows, a confident
/// royal-blue accent and a trio of pastel ring colours (blue / coral / amber)
/// used for the financial-health diagrams.
class AppColors {
  AppColors._();

  // ---- Brand -------------------------------------------------------------
  static const Color primary = Color(0xFF2F6BFF); // royal blue CTA
  static const Color primaryDark = Color(0xFF1E4FD0);
  static const Color primarySoft = Color(0xFFE7EEFF); // tinted fill / chips
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---- Financial semantics ----------------------------------------------
  static const Color income = Color(0xFF22C55E); // positive / saved
  static const Color incomeSoft = Color(0xFFE3F7EC);
  static const Color expense = Color(0xFFFB7185); // spent / over budget
  static const Color expenseSoft = Color(0xFFFFE9ED);
  static const Color savings = Color(0xFF2F6BFF);

  // ---- Health ring palette (3 composite metrics) -------------------------
  static const Color ringBlue = Color(0xFF6FA8F5); // savings rate
  static const Color ringCoral = Color(0xFFFB7185); // budget adherence
  static const Color ringAmber = Color(0xFFFBBF50); // emergency / debt
  static const Color ringTrack = Color(0xFFEDF1F7); // unfilled track

  // ---- Status ------------------------------------------------------------
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444);

  // ---- Light surfaces ----------------------------------------------------
  static const Color bg = Color(0xFFEFF3FA); // app canvas
  static const Color bgTop = Color(0xFFF6F8FC); // gradient highlight
  static const Color surface = Color(0xFFFFFFFF); // cards
  static const Color surfaceAlt = Color(0xFFF3F5FA); // muted fill / inputs
  static const Color surfaceTint = Color(0xFFEDEBFB); // soft lavender card
  static const Color textPrimary = Color(0xFF10182C); // near-black navy
  static const Color textSecondary = Color(0xFF8A93A8); // muted grey
  static const Color textTertiary = Color(0xFFB4BCCB);
  static const Color border = Color(0xFFE8ECF3);
  static const Color navActive = Color(0xFF141B2E); // bottom-nav pill

  // ---- Dark surfaces -----------------------------------------------------
  static const Color bgDark = Color(0xFF0E1320);
  static const Color bgTopDark = Color(0xFF151C2E);
  static const Color surfaceDark = Color(0xFF1A2236);
  static const Color surfaceAltDark = Color(0xFF222C44);
  static const Color textPrimaryDark = Color(0xFFF4F6FB);
  static const Color textSecondaryDark = Color(0xFF98A2B8);
  static const Color textTertiaryDark = Color(0xFF5C6680);
  static const Color borderDark = Color(0xFF2A3450);

  /// Ordered ring palette used by the health diagram (outer → inner).
  static const List<Color> healthRings = [ringBlue, ringCoral, ringAmber];

  /// A pleasing gradient used behind hero numbers / share cards.
  static const List<Color> brandGradient = [Color(0xFF3D7BFF), Color(0xFF6FA8F5)];
}

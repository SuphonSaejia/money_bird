import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/health_display.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/health_ring_chart.dart';
import '../../domain/financial_health.dart';
import '../../l10n/app_localizations.dart';

/// A polished, self-contained card summarising the user's financial health,
/// designed to be rasterised and shared to Instagram / Facebook / etc.
///
/// It is intentionally styled independent of the app theme (always light +
/// branded) so it always looks vivid on social feeds.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.health, this.width = 340});

  final FinancialHealth health;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final band = health.band;
    final dark = AppColors.textPrimary;
    final muted = AppColors.textSecondary;

    TextStyle prompt(double s, FontWeight w, Color c) =>
        GoogleFonts.prompt(fontSize: s, fontWeight: w, color: c, height: 1.1);

    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF7FAFF), Colors.white],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const BrandLogo(size: 24),
                  const SizedBox(width: 8),
                  Text('Money Bird', style: prompt(17, FontWeight.w700, dark)),
                ],
              ),
              Text(DateFormat.yMMM(locale).format(DateTime.now()),
                  style: prompt(13, FontWeight.w500, muted)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.shareCardTitle, style: prompt(15, FontWeight.w500, muted)),
          const SizedBox(height: AppSpacing.lg),
          HealthRingChart(
            size: 184,
            strokeWidth: 15,
            gap: 7,
            rings: [
              for (final m in health.rings)
                RingData(value: m.value, color: m.key.color),
            ],
            center: Text('${health.score}%',
                style: prompt(44, FontWeight.w700, dark)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: band.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(band.label(l10n),
                style: prompt(15, FontWeight.w600, band.color)),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final m in health.rings) ...[
            _LegendRow(
              color: m.key.color,
              label: m.key.label(l10n),
              detail: m.detail,
              styleBuilder: prompt,
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: AppSpacing.sm),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.shareCardMadeWith,
              style: prompt(13, FontWeight.w500, muted)),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.detail,
    required this.styleBuilder,
  });

  final Color color;
  final String label;
  final String detail;
  final TextStyle Function(double, FontWeight, Color) styleBuilder;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: styleBuilder(14, FontWeight.w500, AppColors.textSecondary)),
        ),
        Text(detail, style: styleBuilder(15, FontWeight.w600, AppColors.textPrimary)),
      ],
    );
  }
}

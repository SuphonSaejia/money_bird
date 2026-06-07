import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/health_display.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/health_ring_chart.dart';
import '../../../domain/financial_health.dart';
import '../../../l10n/app_localizations.dart';

/// The hero financial-health card: the multi-ring diagram with the composite
/// score at its centre, a colour-coded legend, a band pill and a coaching tip.
class HealthCard extends StatelessWidget {
  const HealthCard({super.key, required this.health});

  final FinancialHealth health;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final rings = health.rings
        .map((m) => RingData(value: m.value, color: m.key.color))
        .toList();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.healthTitle, style: theme.textTheme.titleLarge),
              ),
              _BandPill(band: health.band),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              HealthRingChart(
                size: 168,
                strokeWidth: 13,
                gap: 6,
                rings: rings,
                center: Text(
                  '${health.score}%',
                  style: AppTextStyles.money(30, color: onSurface),
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.healthScore,
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    for (final metric in health.rings) ...[
                      _LegendRow(
                        color: metric.key.color,
                        label: metric.key.label(l10n),
                        detail: metric.detail,
                      ),
                      if (metric != health.rings.last)
                        const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: health.band.color.withValues(alpha: 0.08),
              borderRadius: AppRadius.input,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.tips_and_updates_rounded,
                  size: 18,
                  color: health.band.color,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    health.band.tip(l10n),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BandPill extends StatelessWidget {
  const _BandPill({required this.band});

  final HealthBand band;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: band.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: band.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            band.label(l10n),
            style: theme.textTheme.labelMedium?.copyWith(
              color: band.color,
              fontWeight: FontWeight.w600,
            ),
          ),
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
  });

  final Color color;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          detail,
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}

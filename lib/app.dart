import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/currency_formatter.dart';
import 'core/utils/health_display.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/root_scaffold.dart';
import 'l10n/app_localizations.dart';
import 'providers/providers.dart';
import 'services/home_widget_service.dart';
import 'services/notification_service.dart';

class MoneyBirdApp extends ConsumerWidget {
  const MoneyBirdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Money Bird',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _RootGate(),
    );
  }
}

/// Decides between onboarding and the main shell, and keeps the native
/// home-screen widget + the daily reminder in sync with app state.
class _RootGate extends ConsumerStatefulWidget {
  const _RootGate();

  @override
  ConsumerState<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<_RootGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = ref.read(settingsProvider);
      if (settings.reminderEnabled) {
        await NotificationService.instance.requestPermissions();
      }
      if (!mounted) return;
      await _syncReminder();
      await _syncWidget();
    });
  }

  Future<void> _syncWidget() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final health = ref.read(financialHealthProvider);
    final summary = ref.read(monthSummaryProvider);
    try {
      await HomeWidgetService.instance.update(
        score: health.score,
        bandLabel: health.band.label(l10n),
        spentTodayText: CurrencyFormatter.format(summary.spentToday, locale: locale),
        title: l10n.widgetTitle,
        spentLabel: l10n.widgetSpentToday,
        tapHint: l10n.widgetTapToAdd,
      );
    } catch (_) {
      // Widget sync is best-effort; ignore platform failures.
    }
  }

  Future<void> _syncReminder() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final settings = ref.read(settingsProvider);
    try {
      if (settings.reminderEnabled) {
        await NotificationService.instance.scheduleDailyReminder(
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
          title: l10n.notifReminderTitle,
          body: l10n.notifReminderBody,
          channelName: l10n.notifChannelName,
          channelDesc: l10n.notifChannelDesc,
        );
      } else {
        await NotificationService.instance.cancelReminder();
      }
    } catch (_) {
      // Best-effort; ignore platform failures.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the widget fresh whenever health / spending changes.
    ref.listen(financialHealthProvider, (_, __) => _syncWidget());
    ref.listen(monthSummaryProvider, (_, __) => _syncWidget());
    // Reschedule the reminder when its settings change.
    ref.listen(
      settingsProvider.select((s) => (s.reminderEnabled, s.reminderHour, s.reminderMinute, s.localeCode)),
      (_, __) => _syncReminder(),
    );

    final onboarded = ref.watch(settingsProvider.select((s) => s.onboardingComplete));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: onboarded
          ? const RootScaffold(key: ValueKey('root'))
          : const OnboardingScreen(key: ValueKey('onboarding')),
    );
  }
}

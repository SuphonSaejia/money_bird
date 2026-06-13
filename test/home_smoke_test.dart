import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_bird/data/db/database.dart';
import 'package:money_bird/domain/budget.dart';
import 'package:money_bird/features/home/home_screen.dart';
import 'package:money_bird/features/onboarding/onboarding_screen.dart';
import 'package:money_bird/features/profile/profile_screen.dart';
import 'package:money_bird/features/statistics/statistics_screen.dart';
import 'package:money_bird/l10n/app_localizations.dart';
import 'package:money_bird/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke tests: every primary screen must lay out without throwing, in both
/// languages, with empty data (the cold-start state). These would have caught
/// the infinite-height `Row(crossAxisAlignment: stretch)` regression.
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen,
      {String locale = 'en'}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          recentTransactionsProvider
              .overrideWith((ref) => Stream.value(<Transaction>[])),
          allTransactionsProvider
              .overrideWith((ref) => Stream.value(<Transaction>[])),
          currentMonthTransactionsProvider
              .overrideWith((ref) => Stream.value(<Transaction>[])),
          budgetsProvider
              .overrideWith((ref) => Stream.value(MonthlyBudgets.empty)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(locale),
          home: screen,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  }

  testWidgets('HomeScreen lays out (en)', (t) async {
    await pumpScreen(t, const HomeScreen());
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('HomeScreen lays out (th)', (t) async {
    await pumpScreen(t, const HomeScreen(), locale: 'th');
  });

  testWidgets('StatisticsScreen lays out', (t) async {
    await pumpScreen(t, const StatisticsScreen());
    expect(find.byType(StatisticsScreen), findsOneWidget);
  });

  testWidgets('ProfileScreen lays out', (t) async {
    await pumpScreen(t, const ProfileScreen());
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('OnboardingScreen lays out', (t) async {
    await pumpScreen(t, const OnboardingScreen());
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}

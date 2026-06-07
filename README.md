# Money Bird 🐦

A calm, minimal personal **income & expense tracker** that scores your *financial
health*, helps you reach a **savings goal**, and keeps you on track — in Thai and
English, with a home-screen widget, daily reminders, and one-tap sharing.

## Features

- **Onboarding** — a few quick questions about your finances (income, fixed
  expenses, savings, debt, monthly savings goal, age) that end by revealing your
  health score.
- **Financial-health score (0–100, shown as %)** — a composite of savings rate,
  emergency-fund cover, spending discipline and debt ratio, with bands and a
  coaching tip. See the model below.
- **Savings goal** — one switchable goal:
  - **Retirement** — target auto-computed with the 4% rule (25× annual
    expenses), horizon from your age → retirement age.
  - **Buy a house / car / Travel / Education / Custom** — you set the target
    amount and target year.
  - The card shows progress, time remaining, and exactly how much to save each
    month to get there.
- **Home dashboard** — health rings, monthly overview (spent today / this month
  / saved / streak), the goal card, and recent activity.
- **Quick add** transactions (expense / income) with categories & notes.
- **Statistics** — spending trend (gradient line), spending by category (donut),
  income vs expense, across weekly / monthly / yearly.
- **Daily reminder** local notification to log today's spending.
- **Home-screen widget** (Android + iOS) showing score + today's spending.
- **Share card** — a beautiful image of your financial health for IG / FB.
- **Thai + English**, light & dark themes, Google Font **Prompt**.

## Tech stack

| Concern | Choice |
| --- | --- |
| State management | `flutter_riverpod` 2.x |
| Local database | `drift` (SQLite) — transactions |
| Preferences / profile | `shared_preferences` |
| Charts | `fl_chart` |
| i18n | `flutter_localizations` + `gen-l10n` (ARB) |
| Notifications | `flutter_local_notifications` + `timezone` |
| Home widget | `home_widget` (Android RemoteViews + iOS WidgetKit) |
| Sharing | `share_plus` (renders the share card to PNG) |
| Icon / splash | `flutter_launcher_icons` + `flutter_native_splash` |
| Font | `google_fonts` (Prompt) |

## Project structure

```text
lib/
  main.dart                 # bootstrap: prefs, services, ProviderScope
  app.dart                  # MaterialApp, theme/locale, onboarding gate, widget+notif sync
  core/
    theme/                  # colors, spacing/radius/shadows, text styles, ThemeData
    widgets/                # shared UI (AppCard, HealthRingChart, GoalCard, StatTile, …)
    utils/                  # currency, dates, input formatters, health/goal display maps
    constants/              # native identifiers (app group, widget provider, keys)
  data/
    db/                     # Drift database + tables (+ generated .g.dart)
    models/                 # FinancialProfile, AppSettings, TransactionType
    repositories/           # transaction / profile / settings repositories
  domain/
    financial_health.dart   # composite 0–100 score
    goal_plan.dart          # savings-goal planning (4% rule + future-value math)
    goal_type.dart          # retirement / house / car / travel / education / custom
    month_summary.dart      # current-month aggregates
    categories.dart         # category catalogue
  providers/providers.dart  # the Riverpod graph (single source of truth)
  features/
    onboarding/ home/ statistics/ transactions/ profile/ share/ shell/
  l10n/                     # app_en.arb, app_th.arb (+ generated AppLocalizations)
```

## The financial-health model

`FinancialHealth.compute(profile, spentThisMonth, now)` returns a 0–100 score as a
weighted blend (a profile with no income scores 0):

| Component | Weight | Full marks when |
| --- | --- | --- |
| Savings rate | 0.35 | monthly surplus ≥ 20% of income |
| Emergency fund | 0.30 | savings ≥ 6 months of committed expenses |
| Spending discipline | 0.20 | spending tracks at/under the prorated monthly budget |
| Debt ratio | 0.15 | debt payments are 0% of income (zero at ≥ 36%) |

Bands: **Excellent** ≥ 80 · **Good** ≥ 60 · **Fair** ≥ 40 · **Needs work** < 40.

## Savings-goal math

`GoalPlan.from(profile, nowYear)` computes, for the chosen goal:

- **Years to goal** — retirement: `retirementAge − age`; others: `targetYear − now`.
- **Target** — retirement: `annualExpenses × 25` (4% rule); others: user's amount.
- **Required monthly** — solved from the future-value-of-annuity formula with a
  modest assumed return (5%/yr), so "save ฿X/mo and you'll get there".

## Running

```bash
flutter pub get
dart run build_runner build       # generate Drift code (after schema changes)
flutter gen-l10n                  # generate localizations (after editing ARB files)
flutter run
```

`flutter analyze` is clean and `flutter test` covers the scoring & goal math
plus per-screen smoke tests.

## Native widget setup

- **Android** — wired via `AndroidManifest.xml`; appears in the launcher widget
  picker after install.
- **iOS** — the WidgetKit extension (`MoneyBirdWidgetExtension`) lives in
  `ios/MoneyBirdWidget/`. App Group `group.com.example.moneyBird` is enabled on
  both the Runner and the widget target so data is shared. Works on the simulator
  with no signing; on a real device, App Groups requires an Apple Developer team.

Identifiers (change for production): Android `com.example.money_bird`,
iOS `com.example.moneyBird`, App Group `group.com.example.moneyBird`.

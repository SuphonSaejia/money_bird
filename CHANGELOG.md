# Changelog

All notable changes to **Money Bird** are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/),
and the project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.0] — 2026-06-13

Keep your data safe, and take real control of your spending.

### Added

- **Backup & restore** — export everything (transactions, budgets, profile and
  preferences) to a single JSON file via the share sheet, and restore it on a
  new device or after a reinstall. No account needed; your data stays yours.
  The backup format is versioned so it can grow with the app.
- **Monthly budgets** — set an overall monthly spending limit plus optional
  per-category caps, and watch this month's spending against each with a clear
  progress bar. A compact budget card appears on Home once a limit is set.
- **Smarter health score** — when you set your own monthly budget it now drives
  the *spending-discipline* component of your financial-health score (it falls
  back to the previous implied figure when no budget is set, so existing scores
  are unchanged).
- **Searchable transactions** — a new full transaction list, reachable from
  *Recent activity → See all*, with free-text note search and filters by type
  (income / expense) and category.

### Changed

- Database upgraded to schema v2 with a safe migration — existing transactions
  are preserved on update.

## [1.0.0] — 2026-06-07

First release. 🐦

### Added

- **Onboarding** — a friendly multi-step intake that captures the user's
  financial picture (income, fixed expenses, savings, debt, monthly savings
  goal, age) and reveals their financial-health score at the end.
- **Composite financial-health score (0–100, shown as a %)** blended from four
  components: savings rate (35%), emergency fund (30%), spending discipline
  (20%) and debt ratio (15%), with Excellent / Good / Fair / Needs-work bands
  and a contextual coaching tip.
- **Home dashboard** — greeting, a multi-ring health diagram with the score,
  monthly overview tiles (spent today / this month / saved / streak), the
  active savings-goal card, and recent activity.
- **Savings goals** — a single, switchable goal: **Retirement** (target
  auto-computed with the 4% rule from expenses + age) or **Buy a house / Buy a
  car / Travel / Education / Custom** (user-set target amount + target year).
  Required monthly contribution is solved with future-value-of-annuity math and
  the card shows progress, time remaining and coaching ("Save ฿X/mo to reach
  your goal" / "Keep saving ฿X/mo — you'll make it").
- **Transactions** — quick add / edit of expenses and income with categories,
  notes and dates; auto-focusing amount field.
- **Statistics** — spending trend (gradient line chart), spending by category
  (donut), and income-vs-expense, across weekly / monthly / yearly ranges.
- **Daily reminder** — a local notification nudging the user to log today's
  spending, at a configurable time.
- **Home-screen widget** — native Android (RemoteViews) and iOS (WidgetKit)
  widgets showing the health score and today's spending, kept in sync via an
  App Group / shared prefs.
- **Share card** — a polished, rasterised image of the user's financial health
  for Instagram / Facebook / anywhere.
- **Profile** — edit financial numbers and goal, switch language & theme,
  toggle the daily reminder and pick its time.
- **Localization** — full Thai + English.
- **Theming** — light & dark, Google Font **Prompt**, minimal "soft card"
  visual language, app icon & splash screen.

### Notes

- All data is stored **on-device** (Drift/SQLite for transactions,
  SharedPreferences for the profile & settings) — no account required.
- `flutter analyze` is clean; unit tests cover the financial-health and
  savings-goal math, and smoke tests cover every screen.

[1.1.0]: https://github.com/SuphonSaejia/money_bird/releases/tag/v1.1.0
[1.0.0]: https://github.com/SuphonSaejia/money_bird/releases/tag/v1.0.0

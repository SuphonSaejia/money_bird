import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/transaction_type.dart';
import '../l10n/app_localizations.dart';

/// A spending / income category. Categories are a fixed, code-defined catalogue
/// (no DB table) — each carries a stable [id], an l10n key for its label, an
/// icon and a tint used throughout the charts and lists.
class AppCategory {
  const AppCategory({
    required this.id,
    required this.type,
    required this.icon,
    required this.color,
    required this.label,
  });

  final String id;
  final TransactionType type;
  final IconData icon;
  final Color color;

  /// Resolves the localized display name.
  final String Function(AppLocalizations l10n) label;
}

/// Central catalogue + lookup for categories.
class Categories {
  Categories._();

  static final List<AppCategory> expense = [
    AppCategory(
      id: 'food',
      type: TransactionType.expense,
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFFB7185),
      label: (l) => l.catFood,
    ),
    AppCategory(
      id: 'groceries',
      type: TransactionType.expense,
      icon: Icons.shopping_basket_rounded,
      color: const Color(0xFF34D399),
      label: (l) => l.catGroceries,
    ),
    AppCategory(
      id: 'transport',
      type: TransactionType.expense,
      icon: Icons.directions_bus_rounded,
      color: const Color(0xFF60A5FA),
      label: (l) => l.catTransport,
    ),
    AppCategory(
      id: 'shopping',
      type: TransactionType.expense,
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFFA78BFA),
      label: (l) => l.catShopping,
    ),
    AppCategory(
      id: 'bills',
      type: TransactionType.expense,
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFFFBBF50),
      label: (l) => l.catBills,
    ),
    AppCategory(
      id: 'fun',
      type: TransactionType.expense,
      icon: Icons.sports_esports_rounded,
      color: const Color(0xFFF472B6),
      label: (l) => l.catEntertainment,
    ),
    AppCategory(
      id: 'health',
      type: TransactionType.expense,
      icon: Icons.favorite_rounded,
      color: const Color(0xFFFF8A8A),
      label: (l) => l.catHealth,
    ),
    AppCategory(
      id: 'education',
      type: TransactionType.expense,
      icon: Icons.school_rounded,
      color: const Color(0xFF38BDF8),
      label: (l) => l.catEducation,
    ),
    AppCategory(
      id: 'travel',
      type: TransactionType.expense,
      icon: Icons.flight_rounded,
      color: const Color(0xFF22D3EE),
      label: (l) => l.catTravel,
    ),
    AppCategory(
      id: 'other_expense',
      type: TransactionType.expense,
      icon: Icons.more_horiz_rounded,
      color: AppColors.textSecondary,
      label: (l) => l.catOtherExpense,
    ),
  ];

  static final List<AppCategory> income = [
    AppCategory(
      id: 'salary',
      type: TransactionType.income,
      icon: Icons.payments_rounded,
      color: const Color(0xFF22C55E),
      label: (l) => l.catSalary,
    ),
    AppCategory(
      id: 'bonus',
      type: TransactionType.income,
      icon: Icons.card_giftcard_rounded,
      color: const Color(0xFF10B981),
      label: (l) => l.catBonus,
    ),
    AppCategory(
      id: 'gift',
      type: TransactionType.income,
      icon: Icons.redeem_rounded,
      color: const Color(0xFF34D399),
      label: (l) => l.catGift,
    ),
    AppCategory(
      id: 'investment',
      type: TransactionType.income,
      icon: Icons.trending_up_rounded,
      color: const Color(0xFF059669),
      label: (l) => l.catInvestment,
    ),
    AppCategory(
      id: 'other_income',
      type: TransactionType.income,
      icon: Icons.add_circle_outline_rounded,
      color: AppColors.income,
      label: (l) => l.catOtherIncome,
    ),
  ];

  static List<AppCategory> forType(TransactionType type) =>
      type.isExpense ? expense : income;

  static final Map<String, AppCategory> _byId = {
    for (final c in [...expense, ...income]) c.id: c,
  };

  /// Looks up a category by id, falling back to a sensible "other" bucket.
  static AppCategory byId(String id) =>
      _byId[id] ??
      (id.contains('income') ? income.last : expense.last);
}

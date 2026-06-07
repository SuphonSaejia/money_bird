import 'package:flutter/material.dart';

/// The kind of savings goal the user is working toward. "retirement" is special
/// — its target is auto-computed from expenses (4% rule); the others use a
/// user-entered target amount + target year.
enum GoalType {
  retirement,
  house,
  car,
  travel,
  education,
  custom;

  bool get isRetirement => this == GoalType.retirement;

  IconData get icon {
    switch (this) {
      case GoalType.retirement:
        return Icons.beach_access_rounded;
      case GoalType.house:
        return Icons.home_rounded;
      case GoalType.car:
        return Icons.directions_car_rounded;
      case GoalType.travel:
        return Icons.flight_takeoff_rounded;
      case GoalType.education:
        return Icons.school_rounded;
      case GoalType.custom:
        return Icons.flag_rounded;
    }
  }

  static GoalType fromName(String? name) {
    return GoalType.values.firstWhere(
      (g) => g.name == name,
      orElse: () => GoalType.retirement,
    );
  }
}

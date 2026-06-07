import '../../domain/goal_plan.dart';
import '../../domain/goal_type.dart';
import '../../l10n/app_localizations.dart';

/// Presentation helpers for savings-goal types → localized labels.
extension GoalTypeDisplay on GoalType {
  String label(AppLocalizations l) {
    switch (this) {
      case GoalType.retirement:
        return l.goalRetirement;
      case GoalType.house:
        return l.goalHouse;
      case GoalType.car:
        return l.goalCar;
      case GoalType.travel:
        return l.goalTravel;
      case GoalType.education:
        return l.goalEducation;
      case GoalType.custom:
        return l.goalCustom;
    }
  }
}

extension GoalPlanDisplay on GoalPlan {
  /// The title to show for this goal — the custom name if set, else the type.
  String title(AppLocalizations l) {
    if (goalType == GoalType.custom && goalName.trim().isNotEmpty) {
      return goalName.trim();
    }
    return goalType.label(l);
  }
}

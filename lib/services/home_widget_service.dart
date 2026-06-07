import 'package:home_widget/home_widget.dart';

import '../core/constants/app_constants.dart';

/// Pushes the latest financial-health snapshot to the native home-screen
/// widgets (Android AppWidget + iOS WidgetKit) via the `home_widget` bridge.
class HomeWidgetService {
  HomeWidgetService._();
  static final HomeWidgetService instance = HomeWidgetService._();

  Future<void> init() async {
    await HomeWidget.setAppGroupId(AppConstants.iosAppGroupId);
  }

  /// Writes the current values and asks the OS to refresh the widgets.
  Future<void> update({
    required int score,
    required String bandLabel,
    required String spentTodayText,
    required String title,
    required String spentLabel,
    required String tapHint,
  }) async {
    await init();
    await HomeWidget.saveWidgetData<int>(AppConstants.wkScore, score);
    await HomeWidget.saveWidgetData<String>(AppConstants.wkBand, bandLabel);
    await HomeWidget.saveWidgetData<String>(
        AppConstants.wkSpentToday, spentTodayText);
    await HomeWidget.saveWidgetData<String>(AppConstants.wkTitle, title);
    await HomeWidget.saveWidgetData<String>(
        AppConstants.wkSpentLabel, spentLabel);
    await HomeWidget.saveWidgetData<String>(AppConstants.wkTapHint, tapHint);
    await HomeWidget.updateWidget(
      androidName: AppConstants.androidWidgetProvider,
      qualifiedAndroidName: AppConstants.androidWidgetProvider,
      iOSName: AppConstants.iosWidgetKind,
    );
  }
}

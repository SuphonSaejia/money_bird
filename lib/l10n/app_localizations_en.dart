// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Money Bird';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonThisMonth => 'This month';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Stats';

  @override
  String get navAdd => 'Add';

  @override
  String get navProfile => 'Profile';

  @override
  String get onbWelcomeTitle => 'Take charge of your money';

  @override
  String get onbWelcomeBody =>
      'Answer a few quick questions and Money Bird will score your financial health and help you keep it strong.';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String onbStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onbIncomeTitle => 'What\'s your monthly income?';

  @override
  String get onbIncomeBody =>
      'Your take-home pay after tax — salary, freelance, everything.';

  @override
  String get onbExpensesTitle => 'What are your fixed monthly expenses?';

  @override
  String get onbExpensesBody =>
      'Rent, bills, subscriptions and other regular costs.';

  @override
  String get onbSavingsTitle => 'How much have you saved so far?';

  @override
  String get onbSavingsBody => 'Total cash, savings and easy-to-reach funds.';

  @override
  String get onbDebtTitle => 'How much do you pay toward debt monthly?';

  @override
  String get onbDebtBody =>
      'Loans, credit cards and instalments. Enter 0 if none.';

  @override
  String get onbGoalTitle => 'How much do you want to save each month?';

  @override
  String get onbGoalBody => 'We\'ll use this as your monthly savings goal.';

  @override
  String get onbResultTitle => 'Your financial health';

  @override
  String get onbResultBody =>
      'Here\'s where you stand today. Track your spending and watch this grow.';

  @override
  String get onbResultCta => 'Enter Money Bird';

  @override
  String get healthTitle => 'Financial health';

  @override
  String get healthScore => 'Health score';

  @override
  String get healthExcellent => 'Excellent';

  @override
  String get healthGood => 'Good';

  @override
  String get healthFair => 'Fair';

  @override
  String get healthNeedsWork => 'Needs work';

  @override
  String get healthExcellentTip =>
      'Outstanding! Your money habits are working beautifully.';

  @override
  String get healthGoodTip =>
      'You\'re on a solid path. A little more saving goes a long way.';

  @override
  String get healthFairTip =>
      'Decent footing. Trimming a few expenses will lift your score.';

  @override
  String get healthNeedsWorkTip =>
      'Let\'s build momentum — small daily wins add up fast.';

  @override
  String get metricSavingsRate => 'Savings rate';

  @override
  String get metricBudget => 'Spending discipline';

  @override
  String get metricEmergency => 'Emergency fund';

  @override
  String get metricDebtRatio => 'Debt ratio';

  @override
  String get retirementTitle => 'Retirement goal';

  @override
  String get retirementTarget => 'Target';

  @override
  String get retirementSaved => 'Saved';

  @override
  String get retirementProjected => 'Projected';

  @override
  String retirementYearsToGo(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years to retire',
      one: '1 year to retire',
      zero: 'Retiring now',
    );
    return '$_temp0';
  }

  @override
  String get retirementOnTrack => 'On track 🎯';

  @override
  String retirementNeedMonthly(String amount) {
    return 'Save $amount/mo to reach your goal';
  }

  @override
  String retirementKeepSaving(String amount) {
    return 'Keep saving $amount/mo — you\'ll make it';
  }

  @override
  String get retirementSetupHint =>
      'Add your age and monthly expenses to plan your retirement.';

  @override
  String retirementProgressOf(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get goalRetirement => 'Retirement';

  @override
  String get goalHouse => 'Buy a house';

  @override
  String get goalCar => 'Buy a car';

  @override
  String get goalTravel => 'Travel';

  @override
  String get goalEducation => 'Education';

  @override
  String get goalCustom => 'My goal';

  @override
  String get goalSettingsTitle => 'Savings goal';

  @override
  String get goalChooseType => 'What are you saving for?';

  @override
  String get goalNameLabel => 'Goal name';

  @override
  String get goalNameHint => 'e.g. New laptop';

  @override
  String get goalTargetAmount => 'Target amount';

  @override
  String get goalTargetYear => 'Target year';

  @override
  String get goalMonthlySaving => 'Save per month';

  @override
  String goalYearsToGo(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years to go',
      one: '1 year to go',
      zero: 'Due this year',
    );
    return '$_temp0';
  }

  @override
  String get goalSetupHint =>
      'Set a target amount and year to start tracking this goal.';

  @override
  String goalSavingFor(String name) {
    return 'Saving for $name';
  }

  @override
  String get profileAge => 'Age';

  @override
  String get profileRetirementAge => 'Retirement age';

  @override
  String ageYears(int age) {
    return '$age yrs';
  }

  @override
  String get onbAgeTitle => 'How old are you?';

  @override
  String get onbAgeBody =>
      'We\'ll use this to plan your retirement savings and guide you there.';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeOverview => 'Overview';

  @override
  String get homeSpentToday => 'Spent today';

  @override
  String get homeBalance => 'Balance';

  @override
  String get homeIncome => 'Income';

  @override
  String get homeExpense => 'Expense';

  @override
  String get homeSaved => 'Saved';

  @override
  String get homeMonthFlow => 'This month';

  @override
  String get homeRecent => 'Recent activity';

  @override
  String get homeNoTransactions => 'No transactions yet';

  @override
  String get homeNoTransactionsBody =>
      'Tap the + button to log your first one.';

  @override
  String get homeStreak => 'Day streak';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsRangeWeek => 'Weekly';

  @override
  String get statsRangeMonth => 'Monthly';

  @override
  String get statsRangeYear => 'Yearly';

  @override
  String get statsSpendingByCategory => 'Spending by category';

  @override
  String get statsIncomeVsExpense => 'Income vs expense';

  @override
  String get statsTrend => 'Spending trend';

  @override
  String get statsTopCategory => 'Top category';

  @override
  String get statsAvgPerDay => 'Avg / day';

  @override
  String get statsNoData => 'Not enough data yet';

  @override
  String get statsTotalSpent => 'Total spent';

  @override
  String get statsTotalIncome => 'Total income';

  @override
  String get txnNewTitle => 'Add transaction';

  @override
  String get txnEditTitle => 'Edit transaction';

  @override
  String get txnExpense => 'Expense';

  @override
  String get txnIncome => 'Income';

  @override
  String get txnAmount => 'Amount';

  @override
  String get txnCategory => 'Category';

  @override
  String get txnNote => 'Note';

  @override
  String get txnNoteHint => 'What was it for? (optional)';

  @override
  String get txnDate => 'Date';

  @override
  String get txnSave => 'Save transaction';

  @override
  String get txnSelectCategory => 'Select a category';

  @override
  String get txnDeleteConfirm => 'Delete this transaction?';

  @override
  String get txnAmountError => 'Enter an amount';

  @override
  String get catFood => 'Food & drink';

  @override
  String get catGroceries => 'Groceries';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catBills => 'Bills & utilities';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catHealth => 'Health';

  @override
  String get catEducation => 'Education';

  @override
  String get catTravel => 'Travel';

  @override
  String get catOtherExpense => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catBonus => 'Bonus';

  @override
  String get catGift => 'Gift';

  @override
  String get catInvestment => 'Investment';

  @override
  String get catOtherIncome => 'Other income';

  @override
  String get settingsTitle => 'Profile';

  @override
  String get settingsZoneMoney => 'My money';

  @override
  String get settingsZoneApp => 'App settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageTh => 'ไทย';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDailyReminder => 'Daily spending reminder';

  @override
  String get settingsDailyReminderBody =>
      'We\'ll nudge you to log today\'s spending.';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsTestNotification => 'Send a test notification';

  @override
  String get settingsTestNotificationSent => 'Test notification sent';

  @override
  String get settingsNotificationsBlocked =>
      'Notifications are turned off in system settings';

  @override
  String get settingsFinancialProfile => 'Financial profile';

  @override
  String get settingsEditProfile => 'Edit my numbers';

  @override
  String get settingsBudget => 'Budget';

  @override
  String get settingsShare => 'Share my health';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsData => 'Data & backup';

  @override
  String get settingsBackup => 'Back up my data';

  @override
  String get settingsBackupBody => 'Save everything to a file you can keep.';

  @override
  String get settingsRestore => 'Restore from a backup';

  @override
  String get settingsRestoreBody =>
      'Import a backup file — replaces current data.';

  @override
  String get backupShareSubject => 'Money Bird backup';

  @override
  String get backupExportError =>
      'Couldn\'t create the backup. Please try again.';

  @override
  String get restoreConfirmTitle => 'Restore this backup?';

  @override
  String get restoreConfirmBody =>
      'This replaces all your current transactions, budgets and profile with the backup\'s data. This can\'t be undone.';

  @override
  String restoreSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restored $count transactions',
      one: 'Restored 1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get restoreErrorCorrupt =>
      'That file isn\'t a valid Money Bird backup.';

  @override
  String get restoreErrorNotMoneyBird =>
      'That file isn\'t a Money Bird backup.';

  @override
  String get restoreErrorVersion =>
      'This backup was made by a newer version of Money Bird. Update the app and try again.';

  @override
  String get commonRestore => 'Restore';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetOverall => 'Monthly budget';

  @override
  String get budgetOverallBody => 'Your total spending limit for the month.';

  @override
  String get budgetByCategory => 'By category';

  @override
  String get budgetAddCategory => 'Add category budget';

  @override
  String budgetSpentOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String budgetOver(String amount) {
    return '$amount over';
  }

  @override
  String get budgetEmptyTitle => 'No budget yet';

  @override
  String get budgetEmptyBody =>
      'Set a monthly budget to track spending and lift your health score.';

  @override
  String get budgetSetCta => 'Set a budget';

  @override
  String get budgetSetLimit => 'Set limit';

  @override
  String get budgetRemoveCategory => 'Remove';

  @override
  String get budgetNoCategoryBudgets => 'No category budgets yet.';

  @override
  String get homeBudget => 'This month\'s budget';

  @override
  String get txnAllTitle => 'All transactions';

  @override
  String get txnSearchHint => 'Search notes…';

  @override
  String get txnFilterAll => 'All';

  @override
  String get txnFilterClear => 'Clear filters';

  @override
  String get txnNoResults => 'No matching transactions';

  @override
  String txnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get settingsSavings => 'Savings';

  @override
  String get savingsTitle => 'Savings';

  @override
  String get savingsBalance => 'Savings balance';

  @override
  String get savingsDeposit => 'Add to savings';

  @override
  String get savingsWithdraw => 'Withdraw';

  @override
  String get savingsDepositTitle => 'Add to savings';

  @override
  String get savingsWithdrawTitle => 'Withdraw from savings';

  @override
  String get savingsHistory => 'Savings activity';

  @override
  String get savingsInThisMonth => 'In this month';

  @override
  String get savingsOutThisMonth => 'Out this month';

  @override
  String get savingsDeleteConfirm => 'Remove this savings entry?';

  @override
  String get savingsEmptyTitle => 'Start saving';

  @override
  String get savingsEmptyBody =>
      'Log money you set aside and watch your goal, safety net and score grow.';

  @override
  String get shareCardTitle => 'My financial health';

  @override
  String get shareCardScore => 'Health score';

  @override
  String get shareCardMadeWith => 'Made with Money Bird';

  @override
  String get shareSheetTitle => 'Share your progress';

  @override
  String get shareToStory => 'Instagram Story';

  @override
  String get shareToFeed => 'Share to…';

  @override
  String get shareSaveImage => 'Save image';

  @override
  String shareCaption(int score) {
    return 'My financial health is $score/100 — tracking with Money Bird 💰';
  }

  @override
  String get notifChannelName => 'Daily reminders';

  @override
  String get notifChannelDesc => 'Reminders to log your daily spending';

  @override
  String get notifReminderTitle => 'Track today\'s spending';

  @override
  String get notifReminderBody =>
      'How much did you spend today? Tap to log it before you forget.';

  @override
  String get notifSummaryTitle => 'Today\'s wrap-up';

  @override
  String notifSummaryBody(String amount) {
    return 'You spent $amount today. Nice tracking!';
  }

  @override
  String get widgetTitle => 'Financial health';

  @override
  String get widgetSpentToday => 'Spent today';

  @override
  String get widgetTapToAdd => 'Tap to add';
}

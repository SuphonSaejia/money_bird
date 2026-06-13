import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Money Bird'**
  String get appName;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get commonThisMonth;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Take charge of your money'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Answer a few quick questions and Money Bird will score your financial health and help you keep it strong.'**
  String get onbWelcomeBody;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbGetStarted;

  /// No description provided for @onbStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onbStepOf(int current, int total);

  /// No description provided for @onbIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your monthly income?'**
  String get onbIncomeTitle;

  /// No description provided for @onbIncomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your take-home pay after tax — salary, freelance, everything.'**
  String get onbIncomeBody;

  /// No description provided for @onbExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'What are your fixed monthly expenses?'**
  String get onbExpensesTitle;

  /// No description provided for @onbExpensesBody.
  ///
  /// In en, this message translates to:
  /// **'Rent, bills, subscriptions and other regular costs.'**
  String get onbExpensesBody;

  /// No description provided for @onbSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'How much have you saved so far?'**
  String get onbSavingsTitle;

  /// No description provided for @onbSavingsBody.
  ///
  /// In en, this message translates to:
  /// **'Total cash, savings and easy-to-reach funds.'**
  String get onbSavingsBody;

  /// No description provided for @onbDebtTitle.
  ///
  /// In en, this message translates to:
  /// **'How much do you pay toward debt monthly?'**
  String get onbDebtTitle;

  /// No description provided for @onbDebtBody.
  ///
  /// In en, this message translates to:
  /// **'Loans, credit cards and instalments. Enter 0 if none.'**
  String get onbDebtBody;

  /// No description provided for @onbGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to save each month?'**
  String get onbGoalTitle;

  /// No description provided for @onbGoalBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this as your monthly savings goal.'**
  String get onbGoalBody;

  /// No description provided for @onbResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your financial health'**
  String get onbResultTitle;

  /// No description provided for @onbResultBody.
  ///
  /// In en, this message translates to:
  /// **'Here\'s where you stand today. Track your spending and watch this grow.'**
  String get onbResultBody;

  /// No description provided for @onbResultCta.
  ///
  /// In en, this message translates to:
  /// **'Enter Money Bird'**
  String get onbResultCta;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial health'**
  String get healthTitle;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get healthScore;

  /// No description provided for @healthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get healthExcellent;

  /// No description provided for @healthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthGood;

  /// No description provided for @healthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get healthFair;

  /// No description provided for @healthNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get healthNeedsWork;

  /// No description provided for @healthExcellentTip.
  ///
  /// In en, this message translates to:
  /// **'Outstanding! Your money habits are working beautifully.'**
  String get healthExcellentTip;

  /// No description provided for @healthGoodTip.
  ///
  /// In en, this message translates to:
  /// **'You\'re on a solid path. A little more saving goes a long way.'**
  String get healthGoodTip;

  /// No description provided for @healthFairTip.
  ///
  /// In en, this message translates to:
  /// **'Decent footing. Trimming a few expenses will lift your score.'**
  String get healthFairTip;

  /// No description provided for @healthNeedsWorkTip.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build momentum — small daily wins add up fast.'**
  String get healthNeedsWorkTip;

  /// No description provided for @metricSavingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings rate'**
  String get metricSavingsRate;

  /// No description provided for @metricBudget.
  ///
  /// In en, this message translates to:
  /// **'Spending discipline'**
  String get metricBudget;

  /// No description provided for @metricEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund'**
  String get metricEmergency;

  /// No description provided for @metricDebtRatio.
  ///
  /// In en, this message translates to:
  /// **'Debt ratio'**
  String get metricDebtRatio;

  /// No description provided for @retirementTitle.
  ///
  /// In en, this message translates to:
  /// **'Retirement goal'**
  String get retirementTitle;

  /// No description provided for @retirementTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get retirementTarget;

  /// No description provided for @retirementSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get retirementSaved;

  /// No description provided for @retirementProjected.
  ///
  /// In en, this message translates to:
  /// **'Projected'**
  String get retirementProjected;

  /// No description provided for @retirementYearsToGo.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, =0{Retiring now} =1{1 year to retire} other{{years} years to retire}}'**
  String retirementYearsToGo(int years);

  /// No description provided for @retirementOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track 🎯'**
  String get retirementOnTrack;

  /// No description provided for @retirementNeedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Save {amount}/mo to reach your goal'**
  String retirementNeedMonthly(String amount);

  /// No description provided for @retirementKeepSaving.
  ///
  /// In en, this message translates to:
  /// **'Keep saving {amount}/mo — you\'ll make it'**
  String retirementKeepSaving(String amount);

  /// No description provided for @retirementSetupHint.
  ///
  /// In en, this message translates to:
  /// **'Add your age and monthly expenses to plan your retirement.'**
  String get retirementSetupHint;

  /// No description provided for @retirementProgressOf.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String retirementProgressOf(String saved, String target);

  /// No description provided for @goalRetirement.
  ///
  /// In en, this message translates to:
  /// **'Retirement'**
  String get goalRetirement;

  /// No description provided for @goalHouse.
  ///
  /// In en, this message translates to:
  /// **'Buy a house'**
  String get goalHouse;

  /// No description provided for @goalCar.
  ///
  /// In en, this message translates to:
  /// **'Buy a car'**
  String get goalCar;

  /// No description provided for @goalTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get goalTravel;

  /// No description provided for @goalEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get goalEducation;

  /// No description provided for @goalCustom.
  ///
  /// In en, this message translates to:
  /// **'My goal'**
  String get goalCustom;

  /// No description provided for @goalSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get goalSettingsTitle;

  /// No description provided for @goalChooseType.
  ///
  /// In en, this message translates to:
  /// **'What are you saving for?'**
  String get goalChooseType;

  /// No description provided for @goalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalNameLabel;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New laptop'**
  String get goalNameHint;

  /// No description provided for @goalTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTargetAmount;

  /// No description provided for @goalTargetYear.
  ///
  /// In en, this message translates to:
  /// **'Target year'**
  String get goalTargetYear;

  /// No description provided for @goalMonthlySaving.
  ///
  /// In en, this message translates to:
  /// **'Save per month'**
  String get goalMonthlySaving;

  /// No description provided for @goalYearsToGo.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, =0{Due this year} =1{1 year to go} other{{years} years to go}}'**
  String goalYearsToGo(int years);

  /// No description provided for @goalSetupHint.
  ///
  /// In en, this message translates to:
  /// **'Set a target amount and year to start tracking this goal.'**
  String get goalSetupHint;

  /// No description provided for @goalSavingFor.
  ///
  /// In en, this message translates to:
  /// **'Saving for {name}'**
  String goalSavingFor(String name);

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileRetirementAge.
  ///
  /// In en, this message translates to:
  /// **'Retirement age'**
  String get profileRetirementAge;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'{age} yrs'**
  String ageYears(int age);

  /// No description provided for @onbAgeTitle.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get onbAgeTitle;

  /// No description provided for @onbAgeBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this to plan your retirement savings and guide you there.'**
  String get onbAgeBody;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get homeOverview;

  /// No description provided for @homeSpentToday.
  ///
  /// In en, this message translates to:
  /// **'Spent today'**
  String get homeSpentToday;

  /// No description provided for @homeBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get homeBalance;

  /// No description provided for @homeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get homeIncome;

  /// No description provided for @homeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get homeExpense;

  /// No description provided for @homeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get homeSaved;

  /// No description provided for @homeMonthFlow.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get homeMonthFlow;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get homeRecent;

  /// No description provided for @homeNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get homeNoTransactions;

  /// No description provided for @homeNoTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to log your first one.'**
  String get homeNoTransactionsBody;

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get homeStreak;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get statsRangeWeek;

  /// No description provided for @statsRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get statsRangeMonth;

  /// No description provided for @statsRangeYear.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get statsRangeYear;

  /// No description provided for @statsSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get statsSpendingByCategory;

  /// No description provided for @statsIncomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs expense'**
  String get statsIncomeVsExpense;

  /// No description provided for @statsTrend.
  ///
  /// In en, this message translates to:
  /// **'Spending trend'**
  String get statsTrend;

  /// No description provided for @statsTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get statsTopCategory;

  /// No description provided for @statsAvgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg / day'**
  String get statsAvgPerDay;

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get statsNoData;

  /// No description provided for @statsTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get statsTotalSpent;

  /// No description provided for @statsTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get statsTotalIncome;

  /// No description provided for @txnNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get txnNewTitle;

  /// No description provided for @txnEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get txnEditTitle;

  /// No description provided for @txnExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get txnExpense;

  /// No description provided for @txnIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get txnIncome;

  /// No description provided for @txnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txnAmount;

  /// No description provided for @txnCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txnCategory;

  /// No description provided for @txnNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get txnNote;

  /// No description provided for @txnNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What was it for? (optional)'**
  String get txnNoteHint;

  /// No description provided for @txnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txnDate;

  /// No description provided for @txnSave.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get txnSave;

  /// No description provided for @txnSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get txnSelectCategory;

  /// No description provided for @txnDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get txnDeleteConfirm;

  /// No description provided for @txnAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get txnAmountError;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get catFood;

  /// No description provided for @catGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills & utilities'**
  String get catBills;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOtherExpense;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get catBonus;

  /// No description provided for @catGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get catGift;

  /// No description provided for @catInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catInvestment;

  /// No description provided for @catOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get catOtherIncome;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageTh.
  ///
  /// In en, this message translates to:
  /// **'ไทย'**
  String get settingsLanguageTh;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily spending reminder'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll nudge you to log today\'s spending.'**
  String get settingsDailyReminderBody;

  /// No description provided for @settingsReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsReminderTime;

  /// No description provided for @settingsTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get settingsTestNotification;

  /// No description provided for @settingsTestNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get settingsTestNotificationSent;

  /// No description provided for @settingsNotificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off in system settings'**
  String get settingsNotificationsBlocked;

  /// No description provided for @settingsFinancialProfile.
  ///
  /// In en, this message translates to:
  /// **'Financial profile'**
  String get settingsFinancialProfile;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit my numbers'**
  String get settingsEditProfile;

  /// No description provided for @settingsBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get settingsBudget;

  /// No description provided for @settingsShare.
  ///
  /// In en, this message translates to:
  /// **'Share my health'**
  String get settingsShare;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data & backup'**
  String get settingsData;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Back up my data'**
  String get settingsBackup;

  /// No description provided for @settingsBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Save everything to a file you can keep.'**
  String get settingsBackupBody;

  /// No description provided for @settingsRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get settingsRestore;

  /// No description provided for @settingsRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Import a backup file — replaces current data.'**
  String get settingsRestoreBody;

  /// No description provided for @backupShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Money Bird backup'**
  String get backupShareSubject;

  /// No description provided for @backupExportError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the backup. Please try again.'**
  String get backupExportError;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces all your current transactions, budgets and profile with the backup\'s data. This can\'t be undone.'**
  String get restoreConfirmBody;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Restored 1 transaction} other{Restored {count} transactions}}'**
  String restoreSuccess(int count);

  /// No description provided for @restoreErrorCorrupt.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a valid Money Bird backup.'**
  String get restoreErrorCorrupt;

  /// No description provided for @restoreErrorNotMoneyBird.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a Money Bird backup.'**
  String get restoreErrorNotMoneyBird;

  /// No description provided for @restoreErrorVersion.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of Money Bird. Update the app and try again.'**
  String get restoreErrorVersion;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @budgetOverall.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get budgetOverall;

  /// No description provided for @budgetOverallBody.
  ///
  /// In en, this message translates to:
  /// **'Your total spending limit for the month.'**
  String get budgetOverallBody;

  /// No description provided for @budgetByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get budgetByCategory;

  /// No description provided for @budgetAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category budget'**
  String get budgetAddCategory;

  /// No description provided for @budgetSpentOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String budgetSpentOf(String spent, String limit);

  /// No description provided for @budgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String budgetLeft(String amount);

  /// No description provided for @budgetOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String budgetOver(String amount);

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No budget yet'**
  String get budgetEmptyTitle;

  /// No description provided for @budgetEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget to track spending and lift your health score.'**
  String get budgetEmptyBody;

  /// No description provided for @budgetSetCta.
  ///
  /// In en, this message translates to:
  /// **'Set a budget'**
  String get budgetSetCta;

  /// No description provided for @budgetSetLimit.
  ///
  /// In en, this message translates to:
  /// **'Set limit'**
  String get budgetSetLimit;

  /// No description provided for @budgetRemoveCategory.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get budgetRemoveCategory;

  /// No description provided for @budgetNoCategoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'No category budgets yet.'**
  String get budgetNoCategoryBudgets;

  /// No description provided for @homeBudget.
  ///
  /// In en, this message translates to:
  /// **'This month\'s budget'**
  String get homeBudget;

  /// No description provided for @txnAllTitle.
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get txnAllTitle;

  /// No description provided for @txnSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes…'**
  String get txnSearchHint;

  /// No description provided for @txnFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get txnFilterAll;

  /// No description provided for @txnFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get txnFilterClear;

  /// No description provided for @txnNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get txnNoResults;

  /// No description provided for @txnCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String txnCount(int count);

  /// No description provided for @shareCardTitle.
  ///
  /// In en, this message translates to:
  /// **'My financial health'**
  String get shareCardTitle;

  /// No description provided for @shareCardScore.
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get shareCardScore;

  /// No description provided for @shareCardMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with Money Bird'**
  String get shareCardMadeWith;

  /// No description provided for @shareSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your progress'**
  String get shareSheetTitle;

  /// No description provided for @shareToStory.
  ///
  /// In en, this message translates to:
  /// **'Instagram Story'**
  String get shareToStory;

  /// No description provided for @shareToFeed.
  ///
  /// In en, this message translates to:
  /// **'Share to…'**
  String get shareToFeed;

  /// No description provided for @shareSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get shareSaveImage;

  /// No description provided for @shareCaption.
  ///
  /// In en, this message translates to:
  /// **'My financial health is {score}/100 — tracking with Money Bird 💰'**
  String shareCaption(int score);

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders to log your daily spending'**
  String get notifChannelDesc;

  /// No description provided for @notifReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Track today\'s spending'**
  String get notifReminderTitle;

  /// No description provided for @notifReminderBody.
  ///
  /// In en, this message translates to:
  /// **'How much did you spend today? Tap to log it before you forget.'**
  String get notifReminderBody;

  /// No description provided for @notifSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s wrap-up'**
  String get notifSummaryTitle;

  /// No description provided for @notifSummaryBody.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} today. Nice tracking!'**
  String notifSummaryBody(String amount);

  /// No description provided for @widgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial health'**
  String get widgetTitle;

  /// No description provided for @widgetSpentToday.
  ///
  /// In en, this message translates to:
  /// **'Spent today'**
  String get widgetSpentToday;

  /// No description provided for @widgetTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get widgetTapToAdd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

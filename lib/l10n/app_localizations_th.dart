// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'Money Bird';

  @override
  String get commonNext => 'ถัดไป';

  @override
  String get commonBack => 'ย้อนกลับ';

  @override
  String get commonDone => 'เสร็จสิ้น';

  @override
  String get commonSkip => 'ข้าม';

  @override
  String get commonSave => 'บันทึก';

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get commonEdit => 'แก้ไข';

  @override
  String get commonContinue => 'ต่อไป';

  @override
  String get commonSeeAll => 'ดูทั้งหมด';

  @override
  String get commonToday => 'วันนี้';

  @override
  String get commonYesterday => 'เมื่อวาน';

  @override
  String get commonThisMonth => 'เดือนนี้';

  @override
  String get commonClose => 'ปิด';

  @override
  String get commonRetry => 'ลองใหม่';

  @override
  String get navHome => 'หน้าหลัก';

  @override
  String get navStats => 'สถิติ';

  @override
  String get navAdd => 'เพิ่ม';

  @override
  String get navProfile => 'โปรไฟล์';

  @override
  String get onbWelcomeTitle => 'ดูแลเงินของคุณให้อยู่หมัด';

  @override
  String get onbWelcomeBody =>
      'ตอบคำถามสั้น ๆ ไม่กี่ข้อ แล้ว Money Bird จะประเมินสุขภาพการเงินของคุณ พร้อมช่วยให้คุณรักษาให้แข็งแรงอยู่เสมอ';

  @override
  String get onbGetStarted => 'เริ่มกันเลย';

  @override
  String onbStepOf(int current, int total) {
    return 'ขั้นตอนที่ $current จาก $total';
  }

  @override
  String get onbIncomeTitle => 'รายได้ต่อเดือนของคุณเท่าไหร่?';

  @override
  String get onbIncomeBody =>
      'เงินที่ได้รับจริงหลังหักภาษี ทั้งเงินเดือน งานฟรีแลนซ์ และอื่น ๆ';

  @override
  String get onbExpensesTitle => 'ค่าใช้จ่ายประจำต่อเดือนเท่าไหร่?';

  @override
  String get onbExpensesBody =>
      'ค่าเช่า ค่าน้ำค่าไฟ ค่าสมาชิก และค่าใช้จ่ายประจำอื่น ๆ';

  @override
  String get onbSavingsTitle => 'ตอนนี้คุณมีเงินเก็บเท่าไหร่?';

  @override
  String get onbSavingsBody => 'เงินสด เงินออม และเงินที่ถอนใช้ได้ง่ายทั้งหมด';

  @override
  String get onbDebtTitle => 'แต่ละเดือนคุณผ่อนหนี้เท่าไหร่?';

  @override
  String get onbDebtBody =>
      'เงินกู้ บัตรเครดิต และค่างวดต่าง ๆ ถ้าไม่มีให้ใส่ 0';

  @override
  String get onbGoalTitle => 'อยากเก็บเงินเดือนละเท่าไหร่?';

  @override
  String get onbGoalBody => 'เราจะใช้ตัวเลขนี้เป็นเป้าหมายการออมต่อเดือนของคุณ';

  @override
  String get onbResultTitle => 'สุขภาพการเงินของคุณ';

  @override
  String get onbResultBody =>
      'นี่คือสถานะของคุณวันนี้ บันทึกการใช้จ่ายไปเรื่อย ๆ แล้วดูคะแนนเติบโตขึ้น';

  @override
  String get onbResultCta => 'เข้าสู่ Money Bird';

  @override
  String get healthTitle => 'สุขภาพการเงิน';

  @override
  String get healthScore => 'คะแนนสุขภาพ';

  @override
  String get healthExcellent => 'ยอดเยี่ยม';

  @override
  String get healthGood => 'ดี';

  @override
  String get healthFair => 'พอใช้';

  @override
  String get healthNeedsWork => 'ต้องปรับปรุง';

  @override
  String get healthExcellentTip =>
      'เยี่ยมมาก! นิสัยการเงินของคุณทำงานได้ดีสุด ๆ';

  @override
  String get healthGoodTip => 'คุณมาถูกทางแล้ว ออมเพิ่มอีกนิดก็ไปได้ไกล';

  @override
  String get healthFairTip =>
      'พื้นฐานใช้ได้ ลดค่าใช้จ่ายบางอย่างจะช่วยดันคะแนนขึ้น';

  @override
  String get healthNeedsWorkTip =>
      'มาสร้างแรงส่งกัน ชัยชนะเล็ก ๆ ในแต่ละวันรวมกันได้เร็วกว่าที่คิด';

  @override
  String get metricSavingsRate => 'อัตราการออม';

  @override
  String get metricBudget => 'วินัยการใช้จ่าย';

  @override
  String get metricEmergency => 'เงินสำรองฉุกเฉิน';

  @override
  String get metricDebtRatio => 'สัดส่วนหนี้';

  @override
  String get retirementTitle => 'เป้าหมายเกษียณ';

  @override
  String get retirementTarget => 'เป้าหมาย';

  @override
  String get retirementSaved => 'ออมแล้ว';

  @override
  String get retirementProjected => 'คาดการณ์';

  @override
  String retirementYearsToGo(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'อีก $years ปีเกษียณ',
      zero: 'ถึงวัยเกษียณแล้ว',
    );
    return '$_temp0';
  }

  @override
  String get retirementOnTrack => 'มาถูกทางแล้ว 🎯';

  @override
  String retirementNeedMonthly(String amount) {
    return 'ออม $amount/เดือน เพื่อให้ถึงเป้า';
  }

  @override
  String retirementKeepSaving(String amount) {
    return 'ออมต่อ $amount/เดือน เดี๋ยวก็ถึงเป้า';
  }

  @override
  String get retirementSetupHint =>
      'ระบุอายุและค่าใช้จ่ายต่อเดือน เพื่อวางแผนเกษียณ';

  @override
  String retirementProgressOf(String saved, String target) {
    return '$saved จาก $target';
  }

  @override
  String get goalRetirement => 'เกษียณ';

  @override
  String get goalHouse => 'ซื้อบ้าน';

  @override
  String get goalCar => 'ซื้อรถ';

  @override
  String get goalTravel => 'ท่องเที่ยว';

  @override
  String get goalEducation => 'การศึกษา';

  @override
  String get goalCustom => 'เป้าหมายของฉัน';

  @override
  String get goalSettingsTitle => 'เป้าหมายการออม';

  @override
  String get goalChooseType => 'ออมเพื่ออะไร?';

  @override
  String get goalNameLabel => 'ชื่อเป้าหมาย';

  @override
  String get goalNameHint => 'เช่น โน้ตบุ๊กใหม่';

  @override
  String get goalTargetAmount => 'ยอดเป้าหมาย';

  @override
  String get goalTargetYear => 'ปีที่ต้องการ';

  @override
  String get goalMonthlySaving => 'ออมต่อเดือน';

  @override
  String goalYearsToGo(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'อีก $years ปี',
      zero: 'ภายในปีนี้',
    );
    return '$_temp0';
  }

  @override
  String get goalSetupHint =>
      'ตั้งยอดเป้าหมายและปีที่ต้องการ เพื่อเริ่มติดตามเป้านี้';

  @override
  String goalSavingFor(String name) {
    return 'ออมเพื่อ$name';
  }

  @override
  String get profileAge => 'อายุ';

  @override
  String get profileRetirementAge => 'อายุเกษียณ';

  @override
  String ageYears(int age) {
    return '$age ปี';
  }

  @override
  String get onbAgeTitle => 'คุณอายุเท่าไหร่?';

  @override
  String get onbAgeBody =>
      'เราจะใช้ตัวเลขนี้วางแผนเงินออมเกษียณ และพาคุณไปให้ถึง';

  @override
  String get homeGreetingMorning => 'สวัสดีตอนเช้า';

  @override
  String get homeGreetingAfternoon => 'สวัสดีตอนบ่าย';

  @override
  String get homeGreetingEvening => 'สวัสดีตอนเย็น';

  @override
  String get homeOverview => 'ภาพรวม';

  @override
  String get homeSpentToday => 'ใช้ไปวันนี้';

  @override
  String get homeBalance => 'ยอดคงเหลือ';

  @override
  String get homeIncome => 'รายรับ';

  @override
  String get homeExpense => 'รายจ่าย';

  @override
  String get homeSaved => 'เก็บได้';

  @override
  String get homeMonthFlow => 'เดือนนี้';

  @override
  String get homeRecent => 'รายการล่าสุด';

  @override
  String get homeNoTransactions => 'ยังไม่มีรายการ';

  @override
  String get homeNoTransactionsBody => 'แตะปุ่ม + เพื่อบันทึกรายการแรกของคุณ';

  @override
  String get homeStreak => 'บันทึกต่อเนื่อง';

  @override
  String get statsTitle => 'สถิติ';

  @override
  String get statsRangeWeek => 'รายสัปดาห์';

  @override
  String get statsRangeMonth => 'รายเดือน';

  @override
  String get statsRangeYear => 'รายปี';

  @override
  String get statsSpendingByCategory => 'รายจ่ายตามหมวดหมู่';

  @override
  String get statsIncomeVsExpense => 'รายรับ vs รายจ่าย';

  @override
  String get statsTrend => 'แนวโน้มการใช้จ่าย';

  @override
  String get statsTopCategory => 'หมวดที่ใช้มากสุด';

  @override
  String get statsAvgPerDay => 'เฉลี่ย / วัน';

  @override
  String get statsNoData => 'ข้อมูลยังไม่เพียงพอ';

  @override
  String get statsTotalSpent => 'ใช้จ่ายทั้งหมด';

  @override
  String get statsTotalIncome => 'รายรับทั้งหมด';

  @override
  String get txnNewTitle => 'เพิ่มรายการ';

  @override
  String get txnEditTitle => 'แก้ไขรายการ';

  @override
  String get txnExpense => 'รายจ่าย';

  @override
  String get txnIncome => 'รายรับ';

  @override
  String get txnAmount => 'จำนวนเงิน';

  @override
  String get txnCategory => 'หมวดหมู่';

  @override
  String get txnNote => 'บันทึกย่อ';

  @override
  String get txnNoteHint => 'ใช้กับอะไร? (ไม่บังคับ)';

  @override
  String get txnDate => 'วันที่';

  @override
  String get txnSave => 'บันทึกรายการ';

  @override
  String get txnSelectCategory => 'เลือกหมวดหมู่';

  @override
  String get txnDeleteConfirm => 'ลบรายการนี้?';

  @override
  String get txnAmountError => 'กรุณาใส่จำนวนเงิน';

  @override
  String get catFood => 'อาหารและเครื่องดื่ม';

  @override
  String get catGroceries => 'ของใช้ในบ้าน';

  @override
  String get catTransport => 'เดินทาง';

  @override
  String get catShopping => 'ช้อปปิ้ง';

  @override
  String get catBills => 'บิลและสาธารณูปโภค';

  @override
  String get catEntertainment => 'บันเทิง';

  @override
  String get catHealth => 'สุขภาพ';

  @override
  String get catEducation => 'การศึกษา';

  @override
  String get catTravel => 'ท่องเที่ยว';

  @override
  String get catOtherExpense => 'อื่น ๆ';

  @override
  String get catSalary => 'เงินเดือน';

  @override
  String get catBonus => 'โบนัส';

  @override
  String get catGift => 'ของขวัญ';

  @override
  String get catInvestment => 'การลงทุน';

  @override
  String get catOtherIncome => 'รายรับอื่น ๆ';

  @override
  String get settingsTitle => 'โปรไฟล์';

  @override
  String get settingsPreferences => 'การตั้งค่า';

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get settingsLanguageSystem => 'ตามระบบ';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageTh => 'ไทย';

  @override
  String get settingsAppearance => 'ธีม';

  @override
  String get settingsThemeSystem => 'ตามระบบ';

  @override
  String get settingsThemeLight => 'สว่าง';

  @override
  String get settingsThemeDark => 'มืด';

  @override
  String get settingsNotifications => 'การแจ้งเตือน';

  @override
  String get settingsDailyReminder => 'เตือนบันทึกรายจ่ายประจำวัน';

  @override
  String get settingsDailyReminderBody =>
      'เราจะเตือนให้คุณบันทึกการใช้จ่ายของวันนี้';

  @override
  String get settingsReminderTime => 'เวลาแจ้งเตือน';

  @override
  String get settingsTestNotification => 'ส่งการแจ้งเตือนทดสอบ';

  @override
  String get settingsTestNotificationSent => 'ส่งการแจ้งเตือนทดสอบแล้ว';

  @override
  String get settingsNotificationsBlocked => 'การแจ้งเตือนถูกปิดในตั้งค่าระบบ';

  @override
  String get settingsFinancialProfile => 'ข้อมูลการเงิน';

  @override
  String get settingsEditProfile => 'แก้ไขตัวเลขของฉัน';

  @override
  String get settingsBudget => 'งบประมาณ';

  @override
  String get settingsShare => 'แชร์สุขภาพการเงิน';

  @override
  String get settingsAbout => 'เกี่ยวกับ';

  @override
  String get settingsVersion => 'เวอร์ชัน';

  @override
  String get settingsData => 'ข้อมูลและการสำรอง';

  @override
  String get settingsBackup => 'สำรองข้อมูล';

  @override
  String get settingsBackupBody => 'บันทึกข้อมูลทั้งหมดเป็นไฟล์ที่เก็บไว้ได้';

  @override
  String get settingsRestore => 'กู้คืนจากไฟล์สำรอง';

  @override
  String get settingsRestoreBody => 'นำเข้าไฟล์สำรอง — จะแทนที่ข้อมูลปัจจุบัน';

  @override
  String get backupShareSubject => 'ไฟล์สำรอง Money Bird';

  @override
  String get backupExportError => 'สร้างไฟล์สำรองไม่สำเร็จ ลองอีกครั้ง';

  @override
  String get restoreConfirmTitle => 'กู้คืนไฟล์สำรองนี้?';

  @override
  String get restoreConfirmBody =>
      'จะแทนที่รายการ งบประมาณ และข้อมูลการเงินปัจจุบันทั้งหมดด้วยข้อมูลในไฟล์สำรอง ย้อนกลับไม่ได้';

  @override
  String restoreSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'กู้คืน $count รายการแล้ว',
    );
    return '$_temp0';
  }

  @override
  String get restoreErrorCorrupt =>
      'ไฟล์นี้ไม่ใช่ไฟล์สำรอง Money Bird ที่ถูกต้อง';

  @override
  String get restoreErrorNotMoneyBird => 'ไฟล์นี้ไม่ใช่ไฟล์สำรองของ Money Bird';

  @override
  String get restoreErrorVersion =>
      'ไฟล์สำรองนี้สร้างจาก Money Bird เวอร์ชันใหม่กว่า กรุณาอัปเดตแอปแล้วลองใหม่';

  @override
  String get commonRestore => 'กู้คืน';

  @override
  String get budgetTitle => 'งบประมาณ';

  @override
  String get budgetOverall => 'งบรายเดือน';

  @override
  String get budgetOverallBody => 'วงเงินใช้จ่ายรวมต่อเดือน';

  @override
  String get budgetByCategory => 'แยกตามหมวด';

  @override
  String get budgetAddCategory => 'เพิ่มงบรายหมวด';

  @override
  String budgetSpentOf(String spent, String limit) {
    return '$spent จาก $limit';
  }

  @override
  String budgetLeft(String amount) {
    return 'เหลือ $amount';
  }

  @override
  String budgetOver(String amount) {
    return 'เกิน $amount';
  }

  @override
  String get budgetEmptyTitle => 'ยังไม่มีงบประมาณ';

  @override
  String get budgetEmptyBody =>
      'ตั้งงบรายเดือนเพื่อติดตามการใช้จ่ายและเพิ่มคะแนนสุขภาพการเงิน';

  @override
  String get budgetSetCta => 'ตั้งงบประมาณ';

  @override
  String get budgetSetLimit => 'ตั้งวงเงิน';

  @override
  String get budgetRemoveCategory => 'ลบ';

  @override
  String get budgetNoCategoryBudgets => 'ยังไม่มีงบรายหมวด';

  @override
  String get homeBudget => 'งบเดือนนี้';

  @override
  String get txnAllTitle => 'รายการทั้งหมด';

  @override
  String get txnSearchHint => 'ค้นหาโน้ต…';

  @override
  String get txnFilterAll => 'ทั้งหมด';

  @override
  String get txnFilterClear => 'ล้างตัวกรอง';

  @override
  String get txnNoResults => 'ไม่พบรายการที่ตรงกัน';

  @override
  String txnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get settingsSavings => 'เงินออม';

  @override
  String get savingsTitle => 'เงินออม';

  @override
  String get savingsBalance => 'ยอดเงินออม';

  @override
  String get savingsDeposit => 'เพิ่มเงินออม';

  @override
  String get savingsWithdraw => 'ถอน';

  @override
  String get savingsDepositTitle => 'เพิ่มเงินออม';

  @override
  String get savingsWithdrawTitle => 'ถอนเงินออม';

  @override
  String get savingsHistory => 'ประวัติการออม';

  @override
  String get savingsInThisMonth => 'เข้าเดือนนี้';

  @override
  String get savingsOutThisMonth => 'ออกเดือนนี้';

  @override
  String get savingsDeleteConfirm => 'ลบรายการออมนี้?';

  @override
  String get savingsEmptyTitle => 'เริ่มออมเงิน';

  @override
  String get savingsEmptyBody =>
      'บันทึกเงินที่กันไว้ แล้วดูเป้าหมาย เงินสำรองฉุกเฉิน และคะแนนเติบโต';

  @override
  String get shareCardTitle => 'สุขภาพการเงินของฉัน';

  @override
  String get shareCardScore => 'คะแนนสุขภาพ';

  @override
  String get shareCardMadeWith => 'สร้างด้วย Money Bird';

  @override
  String get shareSheetTitle => 'แชร์ความก้าวหน้าของคุณ';

  @override
  String get shareToStory => 'Instagram Story';

  @override
  String get shareToFeed => 'แชร์ไปที่…';

  @override
  String get shareSaveImage => 'บันทึกรูปภาพ';

  @override
  String shareCaption(int score) {
    return 'สุขภาพการเงินของฉันอยู่ที่ $score/100 — บันทึกด้วย Money Bird 💰';
  }

  @override
  String get notifChannelName => 'การเตือนประจำวัน';

  @override
  String get notifChannelDesc => 'เตือนให้บันทึกการใช้จ่ายประจำวัน';

  @override
  String get notifReminderTitle => 'บันทึกรายจ่ายวันนี้กันเถอะ';

  @override
  String get notifReminderBody =>
      'วันนี้คุณใช้เงินไปกี่บาท? แตะเพื่อบันทึกก่อนลืม';

  @override
  String get notifSummaryTitle => 'สรุปประจำวัน';

  @override
  String notifSummaryBody(String amount) {
    return 'วันนี้คุณใช้ไป $amount บันทึกได้เยี่ยมมาก!';
  }

  @override
  String get widgetTitle => 'สุขภาพการเงิน';

  @override
  String get widgetSpentToday => 'ใช้ไปวันนี้';

  @override
  String get widgetTapToAdd => 'แตะเพื่อเพิ่ม';
}

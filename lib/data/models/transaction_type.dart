/// Whether a transaction is money going out (expense) or coming in (income).
enum TransactionType {
  expense,
  income;

  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;
}

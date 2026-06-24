import 'check_transaction.dart';
import 'functions.dart';
import 'record.dart';

/// Use Case: Check a list of transactions for data errors
Result<List<Transaction>> checkTransactions(
  Result<List<Transaction>> transactions,
) {
  switch (transactions) {
    case Ok<List<Transaction>> _:
      return check(transactions.value.map(checkTransaction));
    case Error<List<Transaction>> _:
      return transactions;
  }
}

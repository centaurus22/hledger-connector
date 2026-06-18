import 'check_transaction.dart';
import 'functions.dart';
import 'record.dart';

/// Use Case: Check a list of transactions for data errors
Result<List<Transaction>> checkTransactions(
  Result<List<Transaction>> transactions,
) {
  switch (transactions) {
    case Success<List<Transaction>> _:
      return checkResultList(transactions.value.map(checkTransaction));
    case Error<List<Transaction>> _:
      return transactions;
  }
}

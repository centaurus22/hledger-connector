import 'record.dart';

/// Use Case: Convert a list of [Transaction]s to a hledger journal entry.
Result<String> objectsToString(Result<List<Transaction>> transactions) {
  switch (transactions) {
    case Ok<List<Transaction>> _:
      return _objectsToString(transactions.value);
    case Error<List<Transaction>> _:
      return Error(transactions.message);
  }
}

Result<String> _objectsToString(List<Transaction> transaction) {
  return Ok("");
}

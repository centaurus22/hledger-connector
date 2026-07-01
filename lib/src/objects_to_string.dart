import 'functions.dart';
import 'object_to_string.dart';

import 'record.dart';

/// Use Case: Convert a list of [Transaction]s to hledger journal entries.
Result<String> objectsToString(Result<List<Transaction>> transactions) {
  switch (transactions) {
    case Ok<List<Transaction>> _:
      return _objectsToString(transactions.value);
    case Error<List<Transaction>> _:
      return Error(transactions.message);
  }
}

Result<String> _objectsToString(List<Transaction> transaction) {
  Result<List<String>> parsedTransaction = check(
    transaction.map((t) => objectToString(Ok(t))),
  );

  switch (parsedTransaction) {
    case Ok<List<String>> _:
      return Ok(parsedTransaction.value.join(''));
    case Error<List<String>> _:
      return Error(parsedTransaction.message);
  }
}

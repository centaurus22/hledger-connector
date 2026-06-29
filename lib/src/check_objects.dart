import 'check_object.dart';
import 'functions.dart';
import 'record.dart';

/// Use Case: Check a list of [Transaction]s for data errors.
Result<List<Transaction>> checkObjects(Result<List<Transaction>> transactions) {
  switch (transactions) {
    case Ok<List<Transaction>> _:
      return check(transactions.value.map(checkObject));
    case Error<List<Transaction>> _:
      return transactions;
  }
}

import 'object_to_string.dart';

import 'record.dart';

/// Use Case: Convert a list of [Transaction]s to hledger journal entries.
String objectsToString(List<Transaction> transactions) {
  return transactions.map(objectToString).join('');
}

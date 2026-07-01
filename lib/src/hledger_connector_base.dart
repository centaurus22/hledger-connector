import 'check_object.dart';
import 'check_objects.dart';
import 'object_to_string.dart';
import 'objects_to_string.dart';
import 'string_to_objects.dart';
import 'write_to_file.dart';
import 'read_from_file.dart';
import 'record.dart';

/// Checks a [Transaction] for data errors, than converts it into hledger
/// journal entry and appends it to a file.
///
/// If the file does not exist it creates a new one.
///
/// The checks are:
/// * Test if the account names are valid,
/// * test if the [Transaction] contains any [Posting],
/// * test if the [Transaction] is balanced.
///
/// It requires the [Transaction] and a the [file] path. This returns [Ok] or
/// [Error].
Result<String> addTransaction(Transaction transaction, String file) {
  return writeToFile(objectToString(checkObject(transaction)), file);
}

/// Checks a list of [Transaction] for data errors, than converts it into
/// hledger journal entry and appends it to a file.
///
/// If the file does not exist it creates a new one.
///
/// The checks are:
/// * Test if the account names are valid,
/// * test if the [Transaction] contains any [Posting],
/// * test if the [Transaction] is balanced.
///
/// It requires the [Transaction] and a the [file] path. This returns [Ok] or
/// [Error].
Result<String> addTransactions(List<Transaction> transactions, String file) {
  return writeToFile(objectsToString(checkObjects(Ok(transactions))), file);
}

/// Just checks a [Transaction] for data errors, than converts it into hledger
/// journal entry.
///
/// The checks are:
/// * Test if the account names are valid,
/// * test if the [Transaction] contains any [Posting],
/// * test if the [Transaction] is balanced.
///
/// It requires the [Transaction] and returns [Ok] or [Error].
Result<String> toJournalString(Transaction transaction) {
  return objectToString(checkObject(transaction));
}

/// Reads all journal entries from a file, converts it to a list of
/// [Transaction]s and than checks every [Transaction].
///
/// The checks are:
/// * Test if the account names are valid,
/// * test if the [Transaction] contains any [Posting],
/// * test if the [Transaction] is balanced.
///
/// It requires the [file] path and returns [Ok] or [Error].
Result<List<Transaction>> readTransactions(String file) {
  return checkObjects(stringToObjects(readFromFile(file)));
}

/// Just converts a [journal] to a list of [Transaction]s and than checks every
/// [Transaction].
///
/// The checks are:
/// * Test if the account names are valid,
/// * test if the [Transaction] contains any [Posting],
/// * test if the [Transaction] is balanced.
///
/// It requires the [journal] and returns [Ok] or [Error].
Result<List<Transaction>> toJournalObject(List<String> journal) {
  return checkObjects(stringToObjects(Ok(journal)));
}

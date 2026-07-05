import 'validate_object.dart';
import 'validate_objects.dart';
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
void addTransaction(Transaction transaction, String file) {
  final validationResult = validateObject(transaction);

  switch (validationResult) {
    case Valid _:
      try {
        writeToFile(objectToString(transaction), file);
      } catch (e) {
        rethrow;
      }
    case Invalid _:
      throw FormatException(validationResult.error);
  }
}

/// Checks a list of [Transaction]s for data errors, than converts it into
/// hledger journal entries and append them to a file.
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
void addTransactions(List<Transaction> transactions, String file) {
  final validationResult = validateObjects(transactions);

  switch (validationResult) {
    case Valid _:
      try {
        writeToFile(objectsToString(transactions), file);
      } catch (e) {
        rethrow;
      }
    case Invalid _:
      throw FormatException(validationResult.error);
  }
}

/// Checks a [Transaction] for data errors, than converts it into hledger
/// journal entry.
///
/// The checks are:
/// * Test if the account names are valid,
/// * test if the [Transaction] contains any [Posting],
/// * test if the [Transaction] is balanced.
///
/// It requires the [Transaction] and returns [Ok] or [Error].
String toJournalString(Transaction transaction) {
  final validationResult = validateObject(transaction);

  switch (validationResult) {
    case Valid _:
      return objectToString(transaction);
    case Invalid _:
      throw FormatException(validationResult.error);
  }
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
List<Transaction> readTransactions(String file) {
  try {
    final translations = stringToObjects(readFromFile(file));
    final validationResult = validateObjects(translations);

    switch (validationResult) {
      case Valid _:
        return translations;
      case Invalid _:
        throw FormatException(validationResult.error);
    }
  } catch (e) {
    rethrow;
  }
}

/// Converts a [journal] to a list of [Transaction]s and than checks every
/// [Transaction].
///
/// The checks are:
/// * Test if the account names are valid,
/// * test if the [Transaction] contains any [Posting],
/// * test if the [Transaction] is balanced.
///
/// It requires the [journal] and returns [Ok] or [Error].
List<Transaction> toJournalObject(List<String> journal) {
  final translations = stringToObjects(journal);
  final validationResult = validateObjects(translations);

  switch (validationResult) {
    case Valid _:
      return translations;
    case Invalid _:
      throw FormatException(validationResult.error);
  }
}

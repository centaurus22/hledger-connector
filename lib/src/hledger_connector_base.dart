import 'check_transaction.dart';
import 'check_transactions.dart';
import 'to_journal_string.dart';
import 'to_journal_object.dart';
import 'write_to_file.dart';
import 'read_from_file.dart';
import 'record.dart';

Result<String> addTransaction(Transaction transaction, String file) {
  return writeToFile(toJournalString(checkTransaction(transaction)), file);
}

Result<List<Transaction>> readTransactions(String file) {
  return checkTransactions(toJournalObject(readFromFile(file)));
}

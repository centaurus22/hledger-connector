import 'check_transaction.dart';
import 'check_transactions.dart';
import 'to_string.dart';
import 'to_object.dart';
import 'write_to_file.dart';
import 'read_from_file.dart';
import 'record.dart';

Result<String> addTransaction(Transaction transaction, String file) {
  return writeToFile(toString(checkTransaction(transaction)), file);
}

Result<String> toJournalString(Transaction transaction, String file) {
  return toString(checkTransaction(transaction));
}

Result<List<Transaction>> readTransactions(String file) {
  return checkTransactions(toObject(readFromFile(file)));
}

Result<List<Transaction>> toJournalObject(List<String> text) {
  return checkTransactions(toObject(Ok(text)));
}

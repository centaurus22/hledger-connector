import 'check_object.dart';
import 'check_objects.dart';
import 'to_string.dart';
import 'to_objects.dart';
import 'write_to_file.dart';
import 'read_from_file.dart';
import 'record.dart';

Result<String> addTransaction(Transaction transaction, String file) {
  return writeToFile(toString(checkObject(transaction)), file);
}

Result<String> toJournalString(Transaction transaction, String file) {
  return toString(checkObject(transaction));
}

Result<List<Transaction>> readTransactions(String file) {
  return checkObjects(toObjects(readFromFile(file)));
}

Result<List<Transaction>> toJournalObject(List<String> text) {
  return checkObjects(toObjects(Ok(text)));
}

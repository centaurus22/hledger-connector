import 'parse_transaction.dart';
import 'write_to_file.dart';
import 'record.dart';

Result<String> addTransaction(Transaction transaction, String file) {
  return writeToFile(parseTransaction(transaction), file);
}

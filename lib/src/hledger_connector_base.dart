import 'parse_transaction.dart';
import 'write_to_file.dart';
import 'record.dart';

Future<Result> addTransaction(Transaction transaction, JournalFile file) async {
  return await writeToFile(parseTransaction(transaction), file);
}

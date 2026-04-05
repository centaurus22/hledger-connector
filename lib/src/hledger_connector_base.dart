import 'parse_transaction.dart';
import 'write_to_file.dart';
import 'record.dart';

Future<Result> addTransaction(Transaction transaction, JournalFile file) async {
  var parsedTransaction = parseTransaction(transaction);

  switch (parsedTransaction) {
    case Error _:
      return parsedTransaction;
    case Success _:
      return await writeToFile(parsedTransaction.value, file);
  }
}

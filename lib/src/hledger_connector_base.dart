import 'parse_transaction.dart';
import 'write_to_file.dart';
import 'record.dart';

Result addTransaction(Transaction transaction, File file) {
  var parsedTransaction = parseTransaction(transaction);

  switch (parsedTransaction) {
    case Error _:
      return parsedTransaction;
    case Success _:
      return writeToFile(parsedTransaction.value, file);
  }
}

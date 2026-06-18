import 'check_transaction.dart';
import 'check_transactions.dart';
import 'parse_transaction_record.dart';
import 'parse_transaction_string.dart';
import 'write_to_file.dart';
import 'read_from_file.dart';
import 'record.dart';

Result<String> addTransaction(Transaction transaction, String file) {
  return writeToFile(
    parseTransactionRecord(checkTransaction(transaction)),
    file,
  );
}

Result<List<Transaction>> readTransactions(String file) {
  return checkTransactions(parseTransactionString(readFromFile(file)));
}

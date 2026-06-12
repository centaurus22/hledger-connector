import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction_string.dart';

void main() {
  test('returning error if the input is an Error', () {
    Error<List<String>> value = Error(message: 'The file cannot be found.');
    var result = parseTransactionString(value);
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing basic transaction', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025,12,03));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.elementAt(1).account, 'assets');
      expect(parsedTransaction.subTransactions.elementAt(1).amount.value, -3);
    }
  });
}

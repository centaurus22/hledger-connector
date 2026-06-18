import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/check_transactions.dart';

void main() {
  test('Transaction list with data error', () {
    List<Transaction> transactions = List.empty(growable: true);
    transactions.add(
      Transaction(date: DateTime(2003, 12, 05), subTransactions: List.empty()),
    );
    final transactionResult = Success(value: transactions);
    final result = checkTransactions(transactionResult);
    expect(result.runtimeType, Error<List<Transaction>>);
  });
}

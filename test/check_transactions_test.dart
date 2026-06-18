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
  test('Transaction list without data error', () {
    List<Transaction> transactions = List.empty(growable: true);
    transactions.add(
      Transaction(
        date: DateTime(2003, 12, 05),
        subTransactions: [
          SubTransaction(account: 'assets', amount: Amount(value: -5)),
          SubTransaction(account: 'rent', amount: Amount(value: 5)),
        ],
      ),
    );
    final transactionResult = Success(value: transactions);
    final result = checkTransactions(transactionResult);
    expect(result.runtimeType, Success<List<Transaction>>);
  });
}

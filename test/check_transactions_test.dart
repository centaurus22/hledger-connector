import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/check_transactions.dart';

void main() {
  test('Transaction list with data error', () {
    List<Transaction> transactions = List.empty(growable: true);
    transactions.add(
      Transaction(date: DateTime(2003, 12, 05), postings: List.empty()),
    );
    final transactionResult = Ok(transactions);
    final result = checkTransactions(transactionResult);
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('Transaction list without data error', () {
    List<Transaction> transactions = List.empty(growable: true);
    transactions.add(
      Transaction(
        date: DateTime(2003, 12, 05),
        postings: [
          Posting(account: 'assets', amount: Amount(value: -5)),
          Posting(account: 'rent', amount: Amount(value: 5)),
        ],
      ),
    );
    final transactionResult = Ok(transactions);
    final result = checkTransactions(transactionResult);
    expect(result.runtimeType, Ok<List<Transaction>>);
  });
  test('Error as input', () {
    Error<List<Transaction>> value = Error('The file cannot be found.');
    var result = checkTransactions(value);
    expect(result.runtimeType, Error<List<Transaction>>);
  });
}

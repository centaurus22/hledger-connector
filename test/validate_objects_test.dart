import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/validate_objects.dart';

void main() {
  test('Transaction list with data error', () {
    List<Transaction> transactions = List.empty(growable: true);
    transactions.add(
      Transaction(date: DateTime(2003, 12, 05), postings: List.empty()),
    );
    final result = validateObjects(transactions);
    expect(result.runtimeType, Invalid);
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
    final result = validateObjects(transactions);
    expect(result.runtimeType, Valid);
  });
}

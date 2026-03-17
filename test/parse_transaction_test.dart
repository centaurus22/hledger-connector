import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction.dart';

void main() {
  var basisSubTransactions = [
    SubTransaction(
      account: Account(main: 'assets'),
      amount: Amount(amount: 10),
    ),
    SubTransaction(
      account: Account(main: 'expenses'),
      amount: Amount(amount: -10),
    ),
  ];
  test('if transaction starts with a date', () {
    var transaction = Transaction(
      date: DateTime(2026, 01, 01),
      subTransactions: basisSubTransactions,
    );
    var result = parseTransaction(transaction);
    expect(result.runtimeType, Success);
    if (result is Success) {
      expect(result.value.substring(0, result.value.length), '\n2026-01-01\n');
    }
  });
  test('if description is rendered', () {
    var transaction = Transaction(
      date: DateTime(2026, 01, 02),
      description: 'First Transaction',
      subTransactions: basisSubTransactions,
    );
    var result = parseTransaction(transaction);
    expect(result.runtimeType, Success);
    if (result is Success) {
      expect(
        result.value.substring(0, result.value.length),
        '\n2026-01-02 First Transaction\n',
      );
    }
  });
  test('date with only a year', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: basisSubTransactions,
    );
    var result = parseTransaction(transaction);
    expect(result.runtimeType, Success);
    if (result is Success) {
      expect(result.value.substring(0, result.value.length), '\n2026-01-01\n');
    }
  });
  test('transaction with no sub-transactions', () {
    var transaction = Transaction(date: DateTime(2026), subTransactions: []);
    var result = parseTransaction(transaction);
    expect(result.runtimeType, Error);
  });
  test('unbalanced transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(
          account: Account(main: 'assets'),
          amount: Amount(amount: 10),
        ),
        SubTransaction(
          account: Account(main: 'expenses'),
          amount: Amount(amount: -5),
        ),
      ],
    );
    var result = parseTransaction(transaction);
    expect(result.runtimeType, Error);
  });
  test('balanced transaction with floating point numbers', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(
          account: Account(main: 'assets'),
          amount: Amount(amount: -0.000004),
        ),
        SubTransaction(
          account: Account(main: 'expenses'),
          amount: Amount(amount: 0.000004),
        ),
      ],
    );
    var result = parseTransaction(transaction);
    expect(result.runtimeType, Success);
  });
  test('balanced transaction with more than one unit', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(
          account: Account(main: 'assets'),
          amount: Amount(amount: 10, unit: '€'),
        ),
        SubTransaction(
          account: Account(main: 'assets'),
          amount: Amount(amount: 5, unit: 'USD'),
        ),
        SubTransaction(
          account: Account(main: 'expenses'),
          amount: Amount(amount: -10, unit: '€'),
        ),
        SubTransaction(
          account: Account(main: 'assets'),
          amount: Amount(amount: -5, unit: 'USD'),
        ),
      ],
    );
    var result = parseTransaction(transaction);
    expect(result.runtimeType, Success);
  });
}

import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction_record.dart';

void main() {
  var basisSubTransactions = [
    SubTransaction(account: 'assets', amount: Amount(value: 10)),
    SubTransaction(account: 'expenses', amount: Amount(value: -10)),
  ];
  test('if transaction starts with a date', () {
    var transaction = Transaction(
      date: DateTime(2026, 01, 01),
      subTransactions: basisSubTransactions,
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
    if (result is Success<String>) {
      expect(result.value.substring(0, 13), '\n\n2026-01-01\n');
    }
  });
  test('if description is rendered', () {
    var transaction = Transaction(
      date: DateTime(2026, 01, 02),
      description: 'First Transaction',
      subTransactions: basisSubTransactions,
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
    if (result is Success<String>) {
      expect(
        result.value.substring(0, 31),
        '\n\n2026-01-02 First Transaction\n',
      );
    }
  });
  test('date with only a year', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: basisSubTransactions,
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
    if (result is Success<String>) {
      expect(result.value.substring(0, 13), '\n\n2026-01-01\n');
    }
  });
  test('transaction with no sub-transactions', () {
    var transaction = Transaction(date: DateTime(2026), subTransactions: []);
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Error<String>);
  });
  test('unbalanced transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(account: 'assets', amount: Amount(value: 10)),
        SubTransaction(account: 'expenses', amount: Amount(value: -5)),
      ],
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Error<String>);
  });
  test('balanced transaction with floating point numbers', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(account: 'assets', amount: Amount(value: -0.000004)),
        SubTransaction(account: 'expenses', amount: Amount(value: 0.000004)),
      ],
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
  });
  test('balanced transaction with more than one unit', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(
          account: 'assets',
          amount: Amount(value: 10, unit: '€'),
        ),
        SubTransaction(
          account: 'assets',
          amount: Amount(value: 5, unit: 'USD'),
        ),
        SubTransaction(
          account: 'expenses',
          amount: Amount(value: -10, unit: '€'),
        ),
        SubTransaction(
          account: 'assets',
          amount: Amount(value: -5, unit: 'USD'),
        ),
      ],
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
  });
  test('valid conversion transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(
          account: 'assets:bank 1',
          amount: Amount(value: 5, unit: 'USD'),
        ),
        SubTransaction(
          account: 'assets:bank 2',
          amount: Amount(value: -10, unit: '€'),
        ),
      ],
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
  });
  test('invalid multi-conversion transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(
          account: 'assets:bank 1',
          amount: Amount(value: 5, unit: 'USD'),
        ),
        SubTransaction(
          account: 'assets:bank 1',
          amount: Amount(value: 5, unit: 'GPB'),
        ),
        SubTransaction(
          account: 'assets:bank 2',
          amount: Amount(value: -10, unit: '€'),
        ),
      ],
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Error<String>);
  });
  test('valid conversion transaction with one reduced value', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: [
        SubTransaction(
          account: 'assets:bank 2',
          amount: Amount(value: 9, unit: '€'),
        ),
        SubTransaction(
          account: 'assets:bank',
          amount: Amount(value: 5, unit: 'USD'),
        ),
        SubTransaction(
          account: 'assets:bank 2',
          amount: Amount(value: -10, unit: '€'),
        ),
      ],
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
  });
  test('sub-transactions in output', () {
    var transaction = Transaction(
      date: DateTime(2026),
      subTransactions: basisSubTransactions,
    );
    var realResult = parseTransactionRecord(transaction);
    var expectedResult =
        '\n\n'
        '2026-01-01\n'
        '    assets     10.0\n'
        '    expenses  -10.0';
    expect(realResult.runtimeType, Success<String>);
    if (realResult is Success<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('sub-transactions with unit', () {
    var transaction = Transaction(
      date: DateTime(2026, 04, 03),
      subTransactions: [
        SubTransaction(
          account: 'expenses',
          amount: Amount(value: 4, unit: '\$'),
        ),
        SubTransaction(
          account: 'assets',
          amount: Amount(value: -4, unit: '\$'),
        ),
      ],
    );
    var realResult = parseTransactionRecord(transaction);
    var expectedResult =
        '\n\n'
        '2026-04-03\n'
        '    expenses   \$4.0\n'
        '    assets    \$-4.0';
    expect(realResult.runtimeType, Success<String>);
    if (realResult is Success<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('sub-transactions with suffixed unit', () {
    var transaction = Transaction(
      date: DateTime(2026, 02, 03),
      subTransactions: [
        SubTransaction(
          account: 'expenses',
          amount: SuffixedAmount(value: -4, unit: '€'),
        ),
        SubTransaction(
          account: 'assets',
          amount: Amount(value: 4, unit: '\$'),
        ),
      ],
    );
    var realResult = parseTransactionRecord(transaction);
    var expectedResult =
        '\n\n'
        '2026-02-03\n'
        '    expenses  -4.0 €\n'
        '    assets      \$4.0';
    expect(realResult.runtimeType, Success<String>);
    if (realResult is Success<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('suffixed amount without a unit', () {
    var transaction = Transaction(
      date: DateTime(2026, 02, 03),
      subTransactions: [
        SubTransaction(account: 'expenses', amount: SuffixedAmount(value: 4)),
        SubTransaction(account: 'assets', amount: SuffixedAmount(value: -4)),
      ],
    );
    var realResult = parseTransactionRecord(transaction);
    var expectedResult =
        '\n\n'
        '2026-02-03\n'
        '    expenses   4.0\n'
        '    assets    -4.0';
    expect(realResult.runtimeType, Success<String>);
    if (realResult is Success<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('throwing error if an account string is empty', () {
    var transaction = Transaction(
      date: DateTime(2026, 02, 03),
      subTransactions: [
        SubTransaction(account: '', amount: Amount(value: 4333)),
        SubTransaction(account: 'assets:cash', amount: Amount(value: -4333)),
      ],
    );
    var realResult = parseTransactionRecord(transaction);
    expect(realResult.runtimeType, Error<String>);
  });
}

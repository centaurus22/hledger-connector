import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction_record.dart';

void main() {
  final basisSubTransactions = [
    SubTransaction(account: 'assets', amount: Amount(value: 10)),
    SubTransaction(account: 'expenses', amount: Amount(value: -10)),
  ];
  test('if transaction starts with a date', () {
    final transaction = Success(
      value: Transaction(
        date: DateTime(2026, 01, 01),
        subTransactions: basisSubTransactions,
      ),
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
    if (result is Success<String>) {
      expect(result.value.substring(0, 13), '\n\n2026-01-01\n');
    }
  });
  test('if description is rendered', () {
    final transaction = Success(
      value: Transaction(
        date: DateTime(2026, 01, 02),
        description: 'First Transaction',
        subTransactions: basisSubTransactions,
      ),
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
    final transaction = Success(
      value: Transaction(
        date: DateTime(2026),
        subTransactions: basisSubTransactions,
      ),
    );
    var result = parseTransactionRecord(transaction);
    expect(result.runtimeType, Success<String>);
    if (result is Success<String>) {
      expect(result.value.substring(0, 13), '\n\n2026-01-01\n');
    }
  });
  test('sub-transactions in output', () {
    final transaction = Success(
      value: Transaction(
        date: DateTime(2026),
        subTransactions: basisSubTransactions,
      ),
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
    final transaction = Success(
      value: Transaction(
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
      ),
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
    final transaction = Success(
      value: Transaction(
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
      ),
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
    final transaction = Success(
      value: Transaction(
        date: DateTime(2026, 02, 03),
        subTransactions: [
          SubTransaction(account: 'expenses', amount: SuffixedAmount(value: 4)),
          SubTransaction(account: 'assets', amount: SuffixedAmount(value: -4)),
        ],
      ),
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
}

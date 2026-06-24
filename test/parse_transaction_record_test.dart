import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/to_journal_string.dart';

void main() {
  final basePostings = [
    Posting(account: 'assets', amount: Amount(value: 10)),
    Posting(account: 'expenses', amount: Amount(value: -10)),
  ];
  test('transaction starting with a date', () {
    final transaction = Ok(
      Transaction(date: DateTime(2026, 01, 01), postings: basePostings),
    );
    var result = toJournalString(transaction);
    expect(result.runtimeType, Ok<String>);
    if (result is Ok<String>) {
      expect(result.value.substring(0, 13), '\n\n2026-01-01\n');
    }
  });
  test('description rendering', () {
    final transaction = Ok(
      Transaction(
        date: DateTime(2026, 01, 02),
        description: 'First Transaction',
        postings: basePostings,
      ),
    );
    var result = toJournalString(transaction);
    expect(result.runtimeType, Ok<String>);
    if (result is Ok<String>) {
      expect(
        result.value.substring(0, 31),
        '\n\n2026-01-02 First Transaction\n',
      );
    }
  });
  test('date with only a year', () {
    final transaction = Ok(
      Transaction(date: DateTime(2026), postings: basePostings),
    );
    var result = toJournalString(transaction);
    expect(result.runtimeType, Ok<String>);
    if (result is Ok<String>) {
      expect(result.value.substring(0, 13), '\n\n2026-01-01\n');
    }
  });
  test('posting', () {
    final transaction = Ok(
      Transaction(date: DateTime(2026), postings: basePostings),
    );
    var realResult = toJournalString(transaction);
    var expectedResult =
        '\n\n'
        '2026-01-01\n'
        '    assets     10.0\n'
        '    expenses  -10.0';
    expect(realResult.runtimeType, Ok<String>);
    if (realResult is Ok<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('posting with unit', () {
    final transaction = Ok(
      Transaction(
        date: DateTime(2026, 04, 03),
        postings: [
          Posting(
            account: 'expenses',
            amount: Amount(value: 4, unit: '\$'),
          ),
          Posting(
            account: 'assets',
            amount: Amount(value: -4, unit: '\$'),
          ),
        ],
      ),
    );
    var realResult = toJournalString(transaction);
    var expectedResult =
        '\n\n'
        '2026-04-03\n'
        '    expenses   \$4.0\n'
        '    assets    \$-4.0';
    expect(realResult.runtimeType, Ok<String>);
    if (realResult is Ok<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('postings with suffixed unit', () {
    final transaction = Ok(
      Transaction(
        date: DateTime(2026, 02, 03),
        postings: [
          Posting(
            account: 'expenses',
            amount: SuffixedAmount(value: -4, unit: '€'),
          ),
          Posting(
            account: 'assets',
            amount: Amount(value: 4, unit: '\$'),
          ),
        ],
      ),
    );
    var realResult = toJournalString(transaction);
    var expectedResult =
        '\n\n'
        '2026-02-03\n'
        '    expenses  -4.0 €\n'
        '    assets      \$4.0';
    expect(realResult.runtimeType, Ok<String>);
    if (realResult is Ok<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('suffixed amount without a unit', () {
    final transaction = Ok(
      Transaction(
        date: DateTime(2026, 02, 03),
        postings: [
          Posting(account: 'expenses', amount: SuffixedAmount(value: 4)),
          Posting(account: 'assets', amount: SuffixedAmount(value: -4)),
        ],
      ),
    );
    var realResult = toJournalString(transaction);
    var expectedResult =
        '\n\n'
        '2026-02-03\n'
        '    expenses   4.0\n'
        '    assets    -4.0';
    expect(realResult.runtimeType, Ok<String>);
    if (realResult is Ok<String>) {
      expect(realResult.value, expectedResult);
    }
  });
  test('Error passed to function', () {
    final transaction = Error<Transaction>("transaction invalid.");
    var realResult = toJournalString(transaction);
    expect(realResult.runtimeType, Error<String>);
  });
}

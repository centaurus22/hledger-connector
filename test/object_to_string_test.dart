import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/object_to_string.dart';

void main() {
  final basePostings = [
    Posting(account: 'assets', amount: Amount(value: 10)),
    Posting(account: 'expenses', amount: Amount(value: -10)),
  ];
  test('transaction starting with a date', () {
    final transaction = Transaction(
      date: DateTime(2026, 01, 01),
      postings: basePostings,
    );
    var result = objectToString(transaction);
    expect(result.substring(0, 13), '\n\n2026-01-01\n');
  });
  test('description rendering', () {
    final transaction = Transaction(
      date: DateTime(2026, 01, 02),
      description: 'First Transaction',
      postings: basePostings,
    );
    var result = objectToString(transaction);
    expect(result.substring(0, 31), '\n\n2026-01-02 First Transaction\n');
  });
  test('date with only a year', () {
    final transaction = Transaction(
      date: DateTime(2026),
      postings: basePostings,
    );
    var result = objectToString(transaction);
    expect(result.substring(0, 13), '\n\n2026-01-01\n');
  });
  test('posting', () {
    final transaction = Transaction(
      date: DateTime(2026),
      postings: basePostings,
    );
    var realResult = objectToString(transaction);
    var expectedResult =
        '\n\n'
        '2026-01-01\n'
        '    assets     10.0\n'
        '    expenses  -10.0';
    expect(realResult, expectedResult);
  });
  test('posting with symbol', () {
    final transaction = Transaction(
      date: DateTime(2026, 04, 03),
      postings: [
        Posting(
          account: 'expenses',
          amount: Amount(value: 4, symbol: PrecedingSymbol(r'$')),
        ),
        Posting(
          account: 'assets',
          amount: Amount(value: -4, symbol: PrecedingSymbol(r'$')),
        ),
      ],
    );
    var realResult = objectToString(transaction);
    var expectedResult =
        '\n\n'
        '2026-04-03\n'
        '    expenses   \$4.0\n'
        '    assets    \$-4.0';
    expect(realResult, expectedResult);
  });
  test('postings with following symbol', () {
    final transaction = Transaction(
      date: DateTime(2026, 02, 03),
      postings: [
        Posting(
          account: 'expenses',
          amount: Amount(value: -4, symbol: FollowingSymbol('€')),
        ),
        Posting(
          account: 'assets',
          amount: Amount(value: 4, symbol: PrecedingSymbol(r'$')),
        ),
      ],
    );
    var realResult = objectToString(transaction);
    var expectedResult =
        '\n\n'
        '2026-02-03\n'
        '    expenses  -4.0 €\n'
        '    assets      \$4.0';
    expect(realResult, expectedResult);
  });
}

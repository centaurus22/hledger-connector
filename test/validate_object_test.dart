import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/validate_object.dart';

void main() {
  test('transaction with no postings', () {
    var transaction = Transaction(date: DateTime(2026), postings: []);
    var result = validateObject(transaction);
    expect(result.runtimeType, Invalid);
  });
  test('unbalanced transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(account: 'assets', amount: Amount(value: 10)),
        Posting(account: 'expenses', amount: Amount(value: -5)),
      ],
    );
    var result = validateObject(transaction);
    expect(result.runtimeType, Invalid);
  });
  test('balanced transaction with floating point numbers', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(account: 'assets', amount: Amount(value: -0.000004)),
        Posting(account: 'expenses', amount: Amount(value: 0.000004)),
      ],
    );
    var result = validateObject(transaction);
    expect(result.runtimeType, Valid);
  });
  test('balanced transaction with more than one symbol', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(
          account: 'assets',
          amount: Amount(value: 10, symbol: PrecedingSymbol('€')),
        ),
        Posting(
          account: 'assets',
          amount: Amount(value: 5, symbol: PrecedingSymbol('USD')),
        ),
        Posting(
          account: 'expenses',
          amount: Amount(value: -10, symbol: PrecedingSymbol('€')),
        ),
        Posting(
          account: 'assets',
          amount: Amount(value: -5, symbol: PrecedingSymbol('USD')),
        ),
      ],
    );
    var result = validateObject(transaction);
    expect(result.runtimeType, Valid);
  });
  test('valid conversion transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(
          account: 'assets:bank 1',
          amount: Amount(value: 5, symbol: PrecedingSymbol('USD')),
        ),
        Posting(
          account: 'assets:bank 2',
          amount: Amount(value: -10, symbol: FollowingSymbol('€')),
        ),
      ],
    );
    var result = validateObject(transaction);
    expect(result.runtimeType, Valid);
  });
  test('invalid multi-conversion transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(
          account: 'assets:bank 1',
          amount: Amount(value: 5, symbol: PrecedingSymbol('USD')),
        ),
        Posting(
          account: 'assets:bank 1',
          amount: Amount(value: 5, symbol: PrecedingSymbol('GPB')),
        ),
        Posting(
          account: 'assets:bank 2',
          amount: Amount(value: -10, symbol: FollowingSymbol('€')),
        ),
      ],
    );
    var result = validateObject(transaction);
    expect(result.runtimeType, Invalid);
  });
  test('valid conversion transaction with one reduced value', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(
          account: 'assets:bank 2',
          amount: Amount(value: 9, symbol: FollowingSymbol('€')),
        ),
        Posting(
          account: 'assets:bank',
          amount: Amount(value: 5, symbol: PrecedingSymbol('USD')),
        ),
        Posting(
          account: 'assets:bank 2',
          amount: Amount(value: -10, symbol: FollowingSymbol('€')),
        ),
      ],
    );
    var result = validateObject(transaction);
    expect(result.runtimeType, Valid);
  });
  test('empty account string', () {
    var transaction = Transaction(
      date: DateTime(2026, 02, 03),
      postings: [
        Posting(account: '', amount: Amount(value: 4333)),
        Posting(account: 'assets:cash', amount: Amount(value: -4333)),
      ],
    );
    var realResult = validateObject(transaction);
    expect(realResult.runtimeType, Invalid);
  });
  test('account string with two following spaces', () {
    var transaction = Transaction(
      date: DateTime(2026, 02, 03),
      postings: [
        Posting(account: 'fo  od', amount: Amount(value: 4333)),
        Posting(account: 'assets:cash', amount: Amount(value: -4333)),
      ],
    );
    var realResult = validateObject(transaction);
    expect(realResult.runtimeType, Invalid);
  });
}

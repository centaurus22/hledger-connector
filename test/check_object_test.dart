import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/check_object.dart';

void main() {
  test('transaction with no postings', () {
    var transaction = Transaction(date: DateTime(2026), postings: []);
    var result = checkObject(transaction);
    expect(result.runtimeType, Error<Transaction>);
  });
  test('unbalanced transaction', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(account: 'assets', amount: Amount(value: 10)),
        Posting(account: 'expenses', amount: Amount(value: -5)),
      ],
    );
    var result = checkObject(transaction);
    expect(result.runtimeType, Error<Transaction>);
  });
  test('balanced transaction with floating point numbers', () {
    var transaction = Transaction(
      date: DateTime(2026),
      postings: [
        Posting(account: 'assets', amount: Amount(value: -0.000004)),
        Posting(account: 'expenses', amount: Amount(value: 0.000004)),
      ],
    );
    var result = checkObject(transaction);
    expect(result.runtimeType, Ok<Transaction>);
  });
  test('balanced transaction with more than one unit', () {
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
    var result = checkObject(transaction);
    expect(result.runtimeType, Ok<Transaction>);
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
    var result = checkObject(transaction);
    expect(result.runtimeType, Ok<Transaction>);
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
    var result = checkObject(transaction);
    expect(result.runtimeType, Error<Transaction>);
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
    var result = checkObject(transaction);
    expect(result.runtimeType, Ok<Transaction>);
  });
  test('empty account string', () {
    var transaction = Transaction(
      date: DateTime(2026, 02, 03),
      postings: [
        Posting(account: '', amount: Amount(value: 4333)),
        Posting(account: 'assets:cash', amount: Amount(value: -4333)),
      ],
    );
    var realResult = checkObject(transaction);
    expect(realResult.runtimeType, Error<Transaction>);
  });
  test('account string with two following spaces', () {
    var transaction = Transaction(
      date: DateTime(2026, 02, 03),
      postings: [
        Posting(account: 'fo  od', amount: Amount(value: 4333)),
        Posting(account: 'assets:cash', amount: Amount(value: -4333)),
      ],
    );
    var realResult = checkObject(transaction);
    expect(realResult.runtimeType, Error<Transaction>);
  });
}

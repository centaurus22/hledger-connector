import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction_string.dart';

void main() {
  test('returning error if the input is an Error', () {
    Error<List<String>> value = Error(message: 'The file cannot be found.');
    var result = parseTransactionString(value);
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing basic transaction', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 12, 03));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.elementAt(1).account, 'assets');
      expect(parsedTransaction.subTransactions.elementAt(1).amount.value, -3);
    }
  });
  test('parsing transaction with three accounts', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food            3");
    transaction.add("    assets:bank  -2.0");
    transaction.add("    assets:cash  -1.0");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var subTransactions = result.value.first.subTransactions;
      expect(subTransactions.first.account, 'food');
      expect(subTransactions.first.amount.value, 3);
      expect(subTransactions.elementAt(1).account, 'assets:bank');
      expect(subTransactions.elementAt(1).amount.value, -2);
      expect(subTransactions.elementAt(2).account, 'assets:cash');
      expect(subTransactions.elementAt(2).amount.value, -1);
    }
  });
  test('parsing transaction with small amounts', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        0.4");
    transaction.add("    assets     -0.4");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var subTransactions = result.value.first.subTransactions;
      expect(subTransactions.first.account, 'food');
      expect(subTransactions.first.amount.value, 0.4);
      expect(subTransactions.elementAt(1).account, 'assets');
      expect(subTransactions.elementAt(1).amount.value, -0.4);
    }
  });
  test('returning error if SubTransaction is not parsable', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        0.4");
    transaction.add("    assets");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing amounts with a prefixed unit', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food        $0.4");
    transaction.add(r"    assets     $-0.4");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var subTransactions = result.value.first.subTransactions;
      expect(subTransactions.first.account, 'food');
      expect(subTransactions.first.amount.value, 0.4);
      expect(subTransactions.first.amount.unit, r'$');
      expect(subTransactions.elementAt(1).account, 'assets');
      expect(subTransactions.elementAt(1).amount.value, -0.4);
      expect(subTransactions.elementAt(1).amount.unit, r'$');
    }
  });
  test('parsing transaction with two spaces between unit and value', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      €  0.4");
    transaction.add(r"    assets    € -0.4");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var subTransactions = result.value.first.subTransactions;
      expect(subTransactions.first.account, 'food');
      expect(subTransactions.first.amount.value, 0.4);
      expect(subTransactions.first.amount.unit, '€');
      expect(subTransactions.elementAt(1).account, 'assets');
      expect(subTransactions.elementAt(1).amount.value, -0.4);
      expect(subTransactions.elementAt(1).amount.unit, '€');
    }
  });
  test('return Error when a unit contains a space', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      a b  0.4");
    transaction.add(r"    assets    € -0.4");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing transaction with suffixed unit', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      0.4 €");
    transaction.add(r"    assets   -0.4 €");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var subTransactions = result.value.first.subTransactions;
      expect(subTransactions.first.account, 'food');
      expect(subTransactions.first.amount.value, 0.4);
      expect(subTransactions.first.amount.unit, '€');
      expect(subTransactions.elementAt(1).account, 'assets');
      expect(subTransactions.elementAt(1).amount.value, -0.4);
      expect(subTransactions.elementAt(1).amount.unit, '€');
      expect(subTransactions.first.amount.runtimeType, SuffixedAmount);
    }
  });
  test('returning Error when a suffix unit contains a space', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      0.4 b a");
    transaction.add(r"    assets   -0.4 d e");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('returning Error if an amount has a prefix and suffix unit', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food     e0.4 b");
    transaction.add(r"    assets   e-0.4 d");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing transaction with description', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03 Bought vegan milk  ");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = parseTransactionString(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 12, 03));
      expect(parsedTransaction.description, 'Bought vegan milk');
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.elementAt(1).account, 'assets');
      expect(parsedTransaction.subTransactions.elementAt(1).amount.value, -3);
    }
  });
}

import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/to_journal_object.dart';

void main() {
  test('returning error if the input is an Error', () {
    Error<List<String>> value = Error(message: 'The file cannot be found.');
    var result = toJournalObject(value);
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing basic transaction', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = toJournalObject(Success(value: transaction));
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
    var result = toJournalObject(Success(value: transaction));
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
    var result = toJournalObject(Success(value: transaction));
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
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing amounts with a prefixed unit', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food        $0.4");
    transaction.add(r"    assets     $-0.4");
    var result = toJournalObject(Success(value: transaction));
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
    var result = toJournalObject(Success(value: transaction));
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
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing transaction with suffixed unit', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      0.4 €");
    transaction.add(r"    assets   -0.4 €");
    var result = toJournalObject(Success(value: transaction));
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
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('returning Error if an amount has a prefix and suffix unit', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food     e0.4 b");
    transaction.add(r"    assets   e-0.4 d");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing transaction with description', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03 Bought vegan milk  ");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = toJournalObject(Success(value: transaction));
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
  test('Returning an Error if the date is malformed', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04  Bought banana");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('Returning an Error if the date is invalid', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-31  Bought banana");
    transaction.add("    assets:cash:bank      3 €");
    transaction.add("    assets:cash:cash     -3 €");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Error<List<Transaction>>);
  });
  test('parsing two transactions', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-12-03 Debit bank account");
    transaction.add("    assets:cash:cash      150 €");
    transaction.add("    assets:cash:bank     -150 €");
    transaction.add("2026-12-05 Debit bank account");
    transaction.add("    assets:cash:cash     200 €");
    transaction.add("    assets:cash:bank     -200 €");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      var subTransactions = parsedTransaction.subTransactions;
      expect(parsedTransaction.date, DateTime(2026, 12, 03));
      expect(parsedTransaction.description, 'Debit bank account');
      expect(subTransactions.first.account, 'assets:cash:cash');
      expect(subTransactions.first.amount.value, 150);
      expect(subTransactions.elementAt(1).account, 'assets:cash:bank');
      expect(subTransactions.elementAt(1).amount.value, -150);
      parsedTransaction = result.value[1];
      subTransactions = parsedTransaction.subTransactions;
      expect(parsedTransaction.date, DateTime(2026, 12, 05));
      expect(parsedTransaction.description, 'Debit bank account');
      expect(subTransactions.first.account, 'assets:cash:cash');
      expect(subTransactions.first.amount.value, 200);
      expect(subTransactions.elementAt(1).account, 'assets:cash:bank');
      expect(subTransactions.elementAt(1).amount.value, -200);
    }
  });
  test('parsing transaction with prefixed unit', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      € 0.4");
    transaction.add(r"    assets   € -0.4");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var subTransactions = result.value.first.subTransactions;
      expect(subTransactions.first.amount.runtimeType, Amount);
    }
  });
  test('Parse numbers in account names', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    23      3 €");
    transaction.add("    12     -3 €");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 04, 30));
      expect(parsedTransaction.subTransactions.first.account, '23');
      expect(parsedTransaction.subTransactions.elementAt(1).account, '12');
    }
  });
  test('Parse numbers in account names', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    23      3 €");
    transaction.add("    12     -3 €");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 04, 30));
      expect(parsedTransaction.subTransactions.first.account, '23');
      expect(parsedTransaction.subTransactions.elementAt(1).account, '12');
    }
  });
  test('Parse spaces in account names', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    f 3      3 €");
    transaction.add("    x 2     -3 €");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 04, 30));
      expect(parsedTransaction.subTransactions.first.account, 'f 3');
      expect(parsedTransaction.subTransactions.elementAt(1).account, 'x 2');
    }
  });
  test('ignoring tags in SubTransactions', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3 €; tag1 ");
    transaction.add("    assets   -3 €");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 04, 30));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.first.amount.unit, '€');
    }
  });
  test('ignoring tags in SubTransactions separated by two spaces', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3 €  ; tag1 ");
    transaction.add("    assets   -3€ ");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 04, 30));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.first.amount.unit, '€');
    }
  });
  test('ignoring tags in SubTransaction with separated unit and tag', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3  €  ; tag1 ");
    transaction.add("    assets   -3€ ");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 04, 30));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.first.amount.unit, '€');
    }
  });
  test('ignoring tags when separated from ; by more than two spaces', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3  €  ;  tag1 ");
    transaction.add("    assets   -3€ ");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 04, 30));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.first.amount.unit, '€');
    }
  });
  test('ignoring comments that claim a complete line', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-03-30");
    transaction.add("    food            3  €  ;  tag1 ");
    transaction.add(" ; I am a comment");
    transaction.add("    assets:bank   -3€ ");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 3, 30));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.first.amount.unit, '€');
    }
  });
  test('sorting two transactions by date', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-12-06 Debit bank account");
    transaction.add("    assets:cash:cash      150 €");
    transaction.add("    assets:cash:bank     -150 €");
    transaction.add("2026-12-05 Debit bank account");
    transaction.add("    assets:cash:cash     200 €");
    transaction.add("    assets:cash:bank     -200 €");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2026, 12, 05));
      parsedTransaction = result.value[1];
      expect(parsedTransaction.date, DateTime(2026, 12, 06));
    }
  });
  test('ignoring # comments', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-03-30");
    transaction.add("    food            3  €  ;  tag1 ");
    transaction.add(" # I am a comment too");
    transaction.add("    assets:bank   -3€ ");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2025, 3, 30));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.first.amount.unit, '€');
    }
  });
  test('ignoring * comments', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-01-04");
    transaction.add("    food            3  €  ;  tag1 ");
    transaction.add(" * I am a comment too");
    transaction.add("    assets:bank   -3€ ");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      var parsedTransaction = result.value.first;
      expect(parsedTransaction.date, DateTime(2026, 1, 4));
      expect(parsedTransaction.subTransactions.first.account, 'food');
      expect(parsedTransaction.subTransactions.first.amount.value, 3);
      expect(parsedTransaction.subTransactions.first.amount.unit, '€');
    }
  });
  test('simple date with period separator', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025.12.03");
    transaction.add("    food      € 0.4");
    transaction.add("    assets   € -0.4");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      expect(result.value.first.date, DateTime(2025, 12, 3));
    }
  });
  test('simple date with slash separator', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2027/08/02");
    transaction.add("    food      € 0.4");
    transaction.add("    assets   € -0.4");
    var result = toJournalObject(Success(value: transaction));
    expect(result.runtimeType, Success<List<Transaction>>);
    if (result is Success<List<Transaction>>) {
      expect(result.value.first.date, DateTime(2027, 8, 2));
    }
  });
}

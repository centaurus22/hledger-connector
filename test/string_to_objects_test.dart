import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/string_to_objects.dart';

void main() {
  test('parsing basic transaction', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 12, 03));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.elementAt(1).account, 'assets');
    expect(parsedTransaction.postings.elementAt(1).amount.value, -3);
  });
  test('parsing transaction with three accounts', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food            3");
    transaction.add("    assets:bank  -2.0");
    transaction.add("    assets:cash  -1.0");
    var result = stringToObjects(transaction);
    var postings = result.transactions.first.postings;
    expect(postings.first.account, 'food');
    expect(postings.first.amount.value, 3);
    expect(postings.elementAt(1).account, 'assets:bank');
    expect(postings.elementAt(1).amount.value, -2);
    expect(postings.elementAt(2).account, 'assets:cash');
    expect(postings.elementAt(2).amount.value, -1);
  });
  test('parsing transaction with small amounts', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        0.4");
    transaction.add("    assets     -0.4");
    var result = stringToObjects(transaction);
    var postings = result.transactions.first.postings;
    expect(postings.first.account, 'food');
    expect(postings.first.amount.value, 0.4);
    expect(postings.elementAt(1).account, 'assets');
    expect(postings.elementAt(1).amount.value, -0.4);
  });
  test('returning error if a Posting is not parsable', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add("    food        0.4");
    transaction.add("    assets");
    expect(() => stringToObjects(transaction), throwsFormatException);
  });
  test('parsing amounts with a preceding symbol', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food        $0.4");
    transaction.add(r"    assets     $-0.4");
    var result = stringToObjects(transaction);
    var postings = result.transactions.first.postings;
    expect(postings.first.account, 'food');
    expect(postings.first.amount.value, 0.4);
    expect(postings.first.amount.symbol?.name, r'$');
    expect(postings.elementAt(1).account, 'assets');
    expect(postings.elementAt(1).amount.value, -0.4);
    expect(postings.elementAt(1).amount.symbol?.name, r'$');
  });
  test('parsing transaction with two spaces between symbol and value', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      €  0.4");
    transaction.add(r"    assets    € -0.4");
    var result = stringToObjects(transaction);
    var postings = result.transactions.first.postings;
    expect(postings.first.account, 'food');
    expect(postings.first.amount.value, 0.4);
    expect(postings.first.amount.symbol?.name, '€');
    expect(postings.elementAt(1).account, 'assets');
    expect(postings.elementAt(1).amount.value, -0.4);
    expect(postings.elementAt(1).amount.symbol?.name, '€');
  });
  test('return Error when a unit contains a space', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      a b  0.4");
    transaction.add(r"    assets    € -0.4");
    expect(() => stringToObjects(transaction), throwsFormatException);
  });
  test('parsing transaction with following symbol', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      0.4 €");
    transaction.add(r"    assets   -0.4 €");
    var result = stringToObjects(transaction);
    var postings = result.transactions.first.postings;
    expect(postings.first.account, 'food');
    expect(postings.first.amount.value, 0.4);
    expect(postings.first.amount.symbol?.name, '€');
    expect(postings.elementAt(1).account, 'assets');
    expect(postings.elementAt(1).amount.value, -0.4);
    expect(postings.elementAt(1).amount.symbol?.name, '€');
    expect(postings.first.amount.symbol.runtimeType, FollowingSymbol);
  });
  test('parsing transaction with preceding symbol', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      $0.4");
    transaction.add(r"    assets   $-0.4");
    var result = stringToObjects(transaction);
    var postings = result.transactions.first.postings;
    expect(postings.first.amount.symbol.runtimeType, PrecedingSymbol);
  });
  test('returning Error when a following symbol contains a space', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      0.4 b a");
    transaction.add(r"    assets   -0.4 d e");
    expect(() => stringToObjects(transaction), throwsFormatException);
  });
  test('returning Error if an amount has a preceding and following symbol', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food     e0.4 b");
    transaction.add(r"    assets   e-0.4 d");
    expect(() => stringToObjects(transaction), throwsFormatException);
  });
  test('parsing transaction with description', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03 Bought vegan milk  ");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 12, 03));
    expect(parsedTransaction.description, 'Bought vegan milk');
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.elementAt(1).account, 'assets');
    expect(parsedTransaction.postings.elementAt(1).amount.value, -3);
  });
  test('Returning an Error if the date is malformed', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04  Bought banana");
    transaction.add("    food        3");
    transaction.add("    assets     -3");
    expect(() => stringToObjects(transaction), throwsFormatException);
  });
  test('Returning an Error if the date is invalid', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-31  Bought banana");
    transaction.add("    assets:cash:bank      3 €");
    transaction.add("    assets:cash:cash     -3 €");
    expect(() => stringToObjects(transaction), throwsFormatException);
  });
  test('parsing two transactions', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-12-03 Debit bank account");
    transaction.add("    assets:cash:cash      150 €");
    transaction.add("    assets:cash:bank     -150 €");
    transaction.add("2026-12-05 Debit bank account");
    transaction.add("    assets:cash:cash     200 €");
    transaction.add("    assets:cash:bank     -200 €");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    var postings = parsedTransaction.postings;
    expect(parsedTransaction.date, DateTime(2026, 12, 03));
    expect(parsedTransaction.description, 'Debit bank account');
    expect(postings.first.account, 'assets:cash:cash');
    expect(postings.first.amount.value, 150);
    expect(postings.elementAt(1).account, 'assets:cash:bank');
    expect(postings.elementAt(1).amount.value, -150);
    parsedTransaction = result.transactions[1];
    postings = parsedTransaction.postings;
    expect(parsedTransaction.date, DateTime(2026, 12, 05));
    expect(parsedTransaction.description, 'Debit bank account');
    expect(postings.first.account, 'assets:cash:cash');
    expect(postings.first.amount.value, 200);
    expect(postings.elementAt(1).account, 'assets:cash:bank');
    expect(postings.elementAt(1).amount.value, -200);
  });
  test('parsing transaction with preceding symbol', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-12-03");
    transaction.add(r"    food      € 0.4");
    transaction.add(r"    assets   € -0.4");
    var result = stringToObjects(transaction);
    var postings = result.transactions.first.postings;
    expect(postings.first.amount.runtimeType, Amount);
  });
  test('Parse numbers in account names', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    23      3 €");
    transaction.add("    12     -3 €");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 04, 30));
    expect(parsedTransaction.postings.first.account, '23');
    expect(parsedTransaction.postings.elementAt(1).account, '12');
  });
  test('Parse spaces in account names', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    f 3      3 €");
    transaction.add("    x 2     -3 €");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 04, 30));
    expect(parsedTransaction.postings.first.account, 'f 3');
    expect(parsedTransaction.postings.elementAt(1).account, 'x 2');
  });
  test('ignoring tags in postings', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3 €; tag1 ");
    transaction.add("    assets   -3 €");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 04, 30));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.first.amount.symbol?.name, '€');
  });
  test('ignoring tags in postings separated by two spaces', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3 €  ; tag1 ");
    transaction.add("    assets   -3€ ");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 04, 30));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.first.amount.symbol?.name, '€');
  });
  test('ignoring tags in Posting with separated symbol and tag', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3  €  ; tag1 ");
    transaction.add("    assets   -3€ ");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 04, 30));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.first.amount.symbol?.name, '€');
  });
  test('ignoring tags when separated from ; by more than two spaces', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-04-30");
    transaction.add("    food      3  €  ;  tag1 ");
    transaction.add("    assets   -3€ ");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 04, 30));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.first.amount.symbol?.name, '€');
  });
  test('ignoring comments that claim a complete line', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-03-30");
    transaction.add("    food            3  €  ;  tag1 ");
    transaction.add(" ; I am a comment");
    transaction.add("    assets:bank   -3€ ");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 3, 30));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.first.amount.symbol?.name, '€');
    expect(result.warnings!.length, 1);
  });
  test('sorting two transactions by date', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-12-06 Debit bank account");
    transaction.add("    assets:cash:cash      150 €");
    transaction.add("    assets:cash:bank     -150 €");
    transaction.add("2026-12-05 Debit bank account");
    transaction.add("    assets:cash:cash     200 €");
    transaction.add("    assets:cash:bank     -200 €");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2026, 12, 05));
    parsedTransaction = result.transactions[1];
    expect(parsedTransaction.date, DateTime(2026, 12, 06));
  });
  test('ignoring # comments', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025-03-30");
    transaction.add("    food            3  €  ;  tag1 ");
    transaction.add(" # I am a comment too");
    transaction.add("    assets:bank   -3€ ");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2025, 3, 30));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.first.amount.symbol?.name, '€');
  });
  test('ignoring * comments', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-01-04");
    transaction.add("    food            3  €  ;  tag1 ");
    transaction.add(" * I am a comment too");
    transaction.add("    assets:bank   -3€ ");
    var result = stringToObjects(transaction);
    var parsedTransaction = result.transactions.first;
    expect(parsedTransaction.date, DateTime(2026, 1, 4));
    expect(parsedTransaction.postings.first.account, 'food');
    expect(parsedTransaction.postings.first.amount.value, 3);
    expect(parsedTransaction.postings.first.amount.symbol?.name, '€');
  });
  test('simple date with period separator', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2025.12.03");
    transaction.add("    food      € 0.4");
    transaction.add("    assets   € -0.4");
    var result = stringToObjects(transaction);
    expect(result.transactions.first.date, DateTime(2025, 12, 3));
  });
  test('simple date with slash separator', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2027/08/02");
    transaction.add("    food      € 0.4");
    transaction.add("    assets   € -0.4");
    var result = stringToObjects(transaction);
    expect(result.transactions.first.date, DateTime(2027, 8, 2));
  });
  test('adding warnings when ignoring comments', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-01-04");
    transaction.add("    food            3  €  ;  tag1 ");
    transaction.add(" * I am a comment too");
    transaction.add("    assets:bank   -3€ ");
    var result = stringToObjects(transaction);
    expect(result.warnings == null, false);
    expect(result.warnings?.length, 1);
  });
  test('; as preceding symbol is throwing an error', () {
    List<String> transaction = List.empty(growable: true);
    transaction.add("2026-01-04");
    transaction.add("    food           ; 3");
    transaction.add("    assets:bank   -3");
    expect(() => stringToObjects(transaction), throwsFormatException);
  });
}

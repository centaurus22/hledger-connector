# Examples

A few usage examples how to use the `hledger_connector` library.

## Base example

Convert a Transaction object to a hledger journal entry and back to an object. 

The following Dart record structure

```dart
import 'package:hledger_connector/hledger_connector.dart';

var transaction = Transaction(
  description: 'Example transaction',
  date: DateTime(2026, 1, 1),
  postings: [
    Posting(
      account: 'assets:cash',
      amount: Amount(value: -5, symbol: PrecedingSymbol(r'$')),
    ),
    Posting(
      account: 'expenses:food',
      amount: Amount(value: 5, symbol: PrecedingSymbol(r'$')),
    ),
  ],
);

final writeResult = addTransaction(transaction, 'example.journal');
```

adds the following transaction to the journal:

```ledger
2026-01-01 Example transaction
    assets:cash    $-5.0
    expenses:food   $5.0
```

You can read the information back with

```dart
final readResult = readTransactions('example.journal');

if (readResult is Ok<List<Transaction>>) {
  final transaction = readResult.value.first;
}
```
The `transaction` variable contains the record structure that you just wrote
to disk.

## Minimal example

This is a minimal example with all absolutely required data for one transaction:

```dart
import 'package:hledger_connector/hledger_connector.dart';

var transaction = Transaction(
  date: DateTime(2026, 1, 1),
  postings: [
    Posting(account: 'assets', amount: Amount(value: 5)),
    Posting(account: 'expenses', amount: Amount(value: -5)),
  ],
);

final result = addTransaction(transaction, 'example.journal');
```
And this is the resulting journal entry:

```hledger
2026-01-01
    assets     5.0
    expenses  -5.0
```

## Conversion example

This is an example with unit conversion:

```dart
import 'package:hledger_connector/hledger_connector.dart';

var transaction = Transaction(
  date: DateTime(2026, 1, 1),
  description: 'Conversion example',
  postings: [
    Posting(
      account: 'assets:account1',
      amount: Amount(value: -5, symbol: PrecedingSymbol(r'$')),
    ),
    Posting(
      account: 'expenses:account2',
      amount: Amount(value: 4.28, symbol: FollowingSymbol(r'€')),
    ),
  ],
);

var result = addTransaction(transaction, 'example.journal');
```

The result is the following:

```hledger
2026-01-01 Conversion example
    assets:account1     $-5.0
    expenses:account2  4.28 €
```

## Error example

This is an example with a unbalanced Transaction. The parser returns an Error:

```dart
import 'package:hledger_connector/hledger_connector.dart';

var transaction = Transaction(
  date: DateTime(2026, 1, 1),
  description: 'Unbalanced example',
  postings: [
    Posting(
      account: 'assets:account1',
      amount: Amount(value: -5, symbol: PrecedingSymbol(r'\$')),
    ),
  ],
);

var result = addTransaction(transaction, 'example.journal');

if (result is Error<String>) {
  print(result.message);
}
```

prints out `This transaction is unbalanced. The sum should be 0.`

## Direct conversion example

One can directly convert an Transaction object to a hledger journal entry and than
back to a Transaction object.

```dart
var transaction = Transaction(
  date: DateTime(2026, 1, 1),
  postings: [
    Posting(account: 'assets', amount: Amount(value: 5)),
    Posting(account: 'expenses', amount: Amount(value: -5)),
  ],
);

final journalEntry = toJournalString(transaction);

if (journalEntry is Ok<String>) {
  Result<List<Transaction>> transactions = toJournalObject(
    journalEntry.value.split('\n'),
  );
}
```
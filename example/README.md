# Examples

A few usage examples for the `hledger_connector`.

## Base example

The following Dart record structure

```dart
import 'package:hledger_connector/hledger_connector.dart';

var file = JournalFile(name: 'test.journal');

var transaction = Transaction(
  date: DateTime(2026,1,1),
  subTransactions: [
    SubTransaction(
      account: Account(main: 'assets', sub: ['cash']),
      amount: Amount(value: -5, unit: '\$')
    ),
    SubTransaction(
      account: Account(main: 'expenses', sub: ['food']),
      amount: Amount(value: 5, unit '\$')
    )
  ]);

final result = await addTransaction(transaction, file);
```
adds the following transaction to the journal:

```hledger
2026-01-01 Example transaction
    assets:cash    $-5.0
    expenses:food   $5.0
```

## Minimal example

This is a minimal example with all absolutely required data for one transaction:

```dart
import 'package:hledger_connector/hledger_connector.dart';

var file = JournalFile(name: 'test.journal');

var transaction = Transaction(
  date: DateTime(2026, 1, 1),
  subTransactions: [
    SubTransaction(
      account: Account(main: 'assets'),
      amount: Amount(value: 5),
    ),
    SubTransaction(
      account: Account(main: 'expenses'),
      amount: Amount(value: -5),
    ),
  ],
);

final result = await addTransaction(transaction, file);
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

var file = JournalFile(name: 'test.journal');

var transaction = Transaction(
  date: DateTime(2026,1,1),
  description: 'Conversion example',
  subTransactions: [
    SubTransaction(
      account: Account(main: 'assets', sub: ['account1']),
      amount: Amount(value: -5, unit: '\$')
    ),
    SubTransaction(
      account: Account(main: 'expenses', sub: ['account2']),
      amount: SuffixedAmount(value: 4.28, unit: '€')
    )
  ]);

  var result = await addTransaction(transaction, file);
```

The result is the following:

```hledger
2026-01-01 Conversion example
    assets:account1     $-5.0
    expenses:account2  4.28 €
```
# Examples

A few usage examples for the `hledger_connector`.

## Base example

The following Dart record structure

```dart
import 'package:hledger_connector/hledger_connector.dart';

var transaction = Transaction(
  description: 'Example transaction',
  date: DateTime(2026,1,1),
  subTransactions: [
    SubTransaction(
      account: 'assets:cash',
      amount: Amount(value: -5, unit: '\$')
    ),
    SubTransaction(
      account: 'expenses:food',
      amount: Amount(value: 5, unit: '\$')
    )
  ]);

final result = await addTransaction(transaction, 'test.journal');
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

var transaction = Transaction(
  date: DateTime(2026, 1, 1),
  subTransactions: [
    SubTransaction(
      account: 'assets',
      amount: Amount(value: 5),
    ),
    SubTransaction(
      account: 'expenses',
      amount: Amount(value: -5),
    ),
  ],
);

final result = await addTransaction(transaction, 'test.journal');
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
  date: DateTime(2026,1,1),
  description: 'Conversion example',
  subTransactions: [
    SubTransaction(
      account: 'assets:account1',
      amount: Amount(value: -5, unit: '\$')
    ),
    SubTransaction(
      account: 'expenses:account2',
      amount: SuffixedAmount(value: 4.28, unit: '€')
    )
  ]);

  var result = await addTransaction(transaction, 'test.journal');
```

The result is the following:

```hledger
2026-01-01 Conversion example
    assets:account1     $-5.0
    expenses:account2  4.28 €
```

## Error example

This is an example with unit conversion:

```dart
import 'package:hledger_connector/hledger_connector.dart';

var transaction = Transaction(
  date: DateTime(2026,1,1),
  description: 'Unbalanced example',
  subTransactions: [
    SubTransaction(
      account: 'assets:account1',
      amount: Amount(value: -5, unit: '\$')
    ),
  ]);

  var result = await addTransaction(transaction, 'test.journal');

  if  (result is Error) {
    print(result.message);
  }
```

prints out `This transaction is unbalanced. The sum should be 0.`
A dart library to connect with the
[hledger plain text accounting system](https://hledger.org/).

## License

This work is provided under the terms of the MIT license. Please take a look at
the LICENSE file for the full text.

## Features

These are the problems my library solves:

### Current features

* Generate journal entries and write it to a journal file with
  * a date and an optional description,
  * sub transactions between two or more accounts,
  * prefixed or suffixed values //Todo: overhaul
  * simple conversion transactions.
* Conversion transactions.
* Creates a new journal files if necessary.
* Returns a Success record when everything works correctly or an Error record
  which contains an error message.

### Not supported

This is a non-exhaustive list

* Secondary date (deprecated by hledger)

### Planned features

* Read and filter journal information.
* Add comments to journal entries.

If you need any feature please [contact](#contact) me.

## Usage

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

final result = addTransaction(transaction, 'test.journal');
```

adds the following transaction to the journal:

```hledger
2026-01-01 Example transaction
    assets:cash    $-5.0
    expenses:food   $5.0
```

For more usage examples, see the `example/` directory.

## Contact

If you have any questions just drop a message at mail@centaurus22.de.
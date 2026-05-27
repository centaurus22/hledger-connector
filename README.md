A dart library to connect with the
[hledger plain text accounting system](https://hledger.org/).

## License

This work is provided under the terms of the MIT license. Please take a look at
the LICENSE file for the full text.

## Features

These are the problems my library solves.

### Current features

* Generate journal entries and write it to a journal file with
  * a date and an optional description,
  * sub transactions between two or more accounts,
  * prefixed or suffixed units,
  * simple conversion transactions.
* Conversion transactions.
* Creates a new journal files if necessary.
* Returns a Success record when everything works correctly or an Error record
  which contains an error message.

### Planned features

* Create `Account` record from a default account string (eg.: "assets:cash").
* Create a `JournalFile` record from a file path.
* Read and filter journal information from a journal via hledger binary.
* Add comments to journal entries.

If you need any feature please [contact](#contact) me.

## Usage

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

This adds the following transaction to the journal:

```hledger
2026-01-01 Example transaction
    assets:cash    $-5.0
    expenses:food   $5.0
```

For more usage examples, see the `example/` directory.

## Contact

If you have any questions just drop a message at mail@centaurus22.de.
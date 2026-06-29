A dart library to connect with the
[hledger plain text accounting system](https://hledger.org/).

## License

This work is provided under the terms of the MIT license. Please take a look at
the LICENSE file for the full text.

## Features

* Generate and read journal entries
  * a date and an optional description,
  * transactions between two or more accounts,
  * preceding or following units
  * simple conversion transactions.
* Write them to file or read them from a file.
* Creates a new journal files if necessary.
* Returns a `Ok` when everything has worked correctly or an `Error` which
  contains an error message.
* Transform a Transaction from and to a string without any file access. To send
  it over the net or save it in a database for example.

### Planned features

* Filter a List of Transactions by account names, dates etc.
* Write a list of Transactions with one file access instead one access for
  every Transaction.
* Add a warning if a journal contains an ignored feature.

### List
Supported features according to the
[data formats page](https://hledger.org/1.52/hledger.html#part-2-data-formats)
on [hledger.org](hledger.org).

| Feature | Supported | Future dev?|
|---------|-----------|--------|
| Basic transaction | ✅ Supported |
| Tag | 👻 Ignored | 🗒️ On request |
| Group values by spaces | ❌ Not Supported | 🗒️ On request |
| Pending status | ❌ Not Supported | 🗒️ On request |
| Cleared status | ❌ Not Supported | 🗒️ On request |
| (code) | ❌ Not Supported | 🗒️ On request |
| Description as PAYEE \| NOTE ¹ | 👻 Ignored | 🗒️ On request |
| Complex commodity symbol | ❌ Not Supported | 🗒️ On request |
| Per unit cost | ❌ Not Supported | 🗒️ On request |
| Total cost | ❌ Not Supported | 🗒️ On request |
| Cost basis | ❌ Not Supported | 🗒️ On request |
| Balance assertion | ❌ Not Supported | 🗒️ On request |
| Virtual postings | ❌ Not Supported | 🗒️ On request |
| comment | 👻 Ignored | 🗒️ On request |
| Secondary date ² | ❌ Not Supported |  ❌ Won't implement |
| Block comment | ❌ Not Supported | 🗒️ On request |
| account directive | ❌ Not Supported | 🗒️ On request |
| Gain postings | ❌ Not Supported | 🗒️ On request |
| alias directive | ❌ Not Supported | 🗒️ On request |
| commodity directive | ❌ Not Supported | 🗒️ On request |
| decimal-mark directive | ❌ Not Supported | 🗒️ On request |
| payee directive | ❌ Not Supported | 🗒️ On request |
| tag directive | ❌ Not Supported | 🗒️ On request |
| Market price directive | ❌ Not Supported | 🗒️ On request |
| include directive | ❌ Not Supported | 🗒️ On request |
| Periodic transaction | ❌ Not Supported | 🗒️ On request |
| apply account | ❌ Not Supported | 🗒️ On request |
| Default commodity | ❌ Not Supported | 🗒️ On request |
| Default year | ❌ Not Supported | 🗒️ On request |
| Other ledger directives | ❌ Not Supported | 🗒️ On request |

1. Is part of description 
2. Is deprecated by hledger

* '👻 Ignored' means: The content of this element will be silently dropped if
  present in a journal. It cannot be added to a Transaction record.
* '❌ Not Supported' means: This element will cause an error.

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
      amount: Amount(value: -5, unit: r'$')
    ),
    SubTransaction(
      account: 'expenses:food',
      amount: Amount(value: 5, unit: r'$')
    )
]);

final writeResult = addTransaction(transaction, 'test.journal');
```

adds the following transaction to the journal:

```ledger
2026-01-01 Example transaction
    assets:cash    $-5.0
    expenses:food   $5.0
```

You can read the information back with

```dart
final readResult = readTransactions('test.journal');

if (readResult is Success) {
  final transaction = readResult.value.first;
}
```
The `transaction` variable contains the record structure that you just wrote
to disk.

For more usage examples, see the `example/` directory.

## Contact

If you have any questions just drop a message at mail@centaurus22.de.
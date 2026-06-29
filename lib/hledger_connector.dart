/// A dart library to connect with the hledger plain text accounting system
/// (https://hledger.org/).
///
/// ## Features
///
/// * Generate and read journal entries
///   * a date and an optional description,
///   * transactions between two or more accounts,
///   * preceding or following units
///   * simple conversion transactions.
/// * Write them to file or read them from a file.
/// * Creates a new journal files if necessary.
/// * Returns a `Ok` when everything has worked correctly or an `Error` which
///   contains an error message.
/// * Transform a Transaction from and to a string without any file access. To
///   send it over the net or save it in a database for example.
///
/// ## Planned features
///
/// * Filter a List of Transactions by account names, dates etc.
/// * Write a list of Transactions with one file access instead one access for
///  every Transaction.
/// * Add a warning if a journal contains an ignored feature.
library;

export 'src/hledger_connector_base.dart';
export 'src/record.dart';

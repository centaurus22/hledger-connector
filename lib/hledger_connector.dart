/// A dart library to connect with the hledger plain text accounting system
/// (https://hledger.org/).
///
/// Features:
/// * Generate journal entries and write it to a journal file with
///   * a date and an optional description,
///   * sub transactions between two or more accounts,
///   * prefixed or suffixed units,
///   * simple conversion transactions.
/// * Creates a new journal file if necessary.

library;

export 'src/hledger_connector_base.dart';
export 'src/record.dart';

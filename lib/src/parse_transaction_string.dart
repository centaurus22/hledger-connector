import 'record.dart';

/// Use Case: Parse a String of Transactions to a List of Transaction Records
Result<List<Transaction>> parseTransactionString(
  Result<List<String>> transactions,
) {
  switch(transactions) {
    case Success<List<String>> _:
      return _parseTransactionString(transactions.value);
    case Error<List<String>> _:
      return Error(message: transactions.message);
  }
}

Result<List<Transaction>> _parseTransactionString(
  List<String> transactions
) {
  List<Transaction> parsedTransactions = List.empty(growable: true);

  parsedTransactions.add(Transaction(
    date: DateTime(2025, 12, 3),
    subTransactions: [
      SubTransaction(account: 'food', amount: Amount(value: 3)),
      SubTransaction(account: 'assets', amount: Amount(value: -3))
    ])
  );
  
  return Success(value: parsedTransactions);
}

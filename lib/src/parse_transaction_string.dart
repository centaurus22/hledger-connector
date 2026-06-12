import 'record.dart';

/// Use Case: Parse a String of Transactions to a List of Transaction Records
Result<List<Transaction>> parseTransactionString(
  Result<List<String>> transactions,
) {
  switch (transactions) {
    case Success<List<String>> _:
      return _parseTransactionString(transactions.value);
    case Error<List<String>> _:
      return Error(message: transactions.message);
  }
}

Result<List<Transaction>> _parseTransactionString(List<String> transactions) {
  List<Transaction> parsedTransactions = List.empty(growable: true);

  transactions.removeAt(0);
  var subTransactions = transactions
      .map((t) => parseSubTransaction(t))
      .toList();

  parsedTransactions.add(
    Transaction(date: DateTime(2025, 12, 3), subTransactions: subTransactions),
  );

  return Success(value: parsedTransactions);
}

SubTransaction parseSubTransaction(String line) {
  RegExp exp = RegExp(r'(.*)[ ]{2,}([-+]?[0-9][0-9]*.?[0-9]*)');
  RegExpMatch? match = exp.firstMatch(line);

  var account = match![1]!.trim();
  var amount = double.parse(match[2]!);
  return SubTransaction(
    account: account,
    amount: Amount(value: amount),
  );
}

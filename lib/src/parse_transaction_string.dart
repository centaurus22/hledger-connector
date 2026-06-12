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
  var packedSubTransactions = transactions
      .map((t) => parseSubTransaction(t))
      .toList();

  List<SubTransaction> subTransactions = List.empty(growable: true);

  for (var subTransaction in packedSubTransactions) {
    switch (subTransaction) {
      case Success<SubTransaction> _:
        subTransactions.add(subTransaction.value);
      case Error<SubTransaction> _:
        return Error(message: subTransaction.message);
    }
  }

  parsedTransactions.add(
    Transaction(date: DateTime(2025, 12, 3), subTransactions: subTransactions),
  );

  return Success(value: parsedTransactions);
}

Result<SubTransaction> parseSubTransaction(String line) {
  RegExp exp = RegExp(r'(.*)[ ]{2,}([-+]?[0-9][0-9]*.?[0-9]*)');
  RegExpMatch? match = exp.firstMatch(line);

  if (match == null) {
    return Error(message: 'Sub-transaction in line "$line" is not parsable');
  }
  var account = match[1]!.trim();
  var amount = double.parse(match[2]!);
  return Success(
    value: SubTransaction(
      account: account,
      amount: Amount(value: amount),
    ),
  );
}

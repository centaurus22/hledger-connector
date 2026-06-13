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
  final lineParts = line
      .split('  ')
      .map((l) => l.trim())
      .where((l) => l != '')
      .toList();

  final errorMessage = 'Sub-transaction in line "$line" is not parsable.';

  if (lineParts.length == 1 || lineParts.length > 3) {
    return Error(message: errorMessage);
  }

  final account = lineParts[0];

  String amount;
  if (lineParts.length == 3) {
    amount = lineParts[1] + lineParts[2];
  } else {
    amount = lineParts[1];
  }

  final exp = RegExp(
    r'(?<unit>[^0-9-]*)(?<value>[-+]?[0-9][0-9]*.?[0-9]*)(?<suffixed_unit>[^0-9-]*)',
  );
  final match = exp.firstMatch(amount);

  if (match == null) {
    return Error(message: errorMessage);
  }

  final value = match.namedGroup('value');
  if (value == null) {
    return Error(message: '$errorMessage The value is not parsable');
  }

  final unit = match.namedGroup('unit')?.trim();
  final suffixedUnit = match.namedGroup('suffixed_unit')?.trim();

  if (unit != null && unit.contains(' ')) {
    return Error(message: '$errorMessage The unit must not contain spaces.');
  }

  Amount parsedAmount;
  if (suffixedUnit != null && suffixedUnit != '') {
    parsedAmount = SuffixedAmount(
      value: double.parse(value),
      unit: suffixedUnit,
    );
  } else {
    parsedAmount = SuffixedAmount(value: double.parse(value), unit: unit);
  }

  return Success(
    value: SubTransaction(account: account, amount: parsedAmount),
  );
}

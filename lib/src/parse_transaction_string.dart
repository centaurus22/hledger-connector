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

  final dateDescription = _splitAndClean(transactions[0], ' ');

  final date = DateTime.tryParse(dateDescription[0]);
  if (date == null) {
    return Error(message: 'The date in line "$dateDescription" is not parsable.');
  }

  String? description;
  if (dateDescription.length > 1) {
    description = dateDescription.sublist(1).join(' ');
  } else {
    description = null;
  }

  var parsedSubTransactions = transactions
      .sublist(1)
      .map((t) => parseSubTransaction(t))
      .toList();

  List<SubTransaction> subTransactions = List.empty(growable: true);

  for (var subTransaction in parsedSubTransactions) {
    switch (subTransaction) {
      case Success<SubTransaction> _:
        subTransactions.add(subTransaction.value);
      case Error<SubTransaction> _:
        return Error(message: subTransaction.message);
    }
  }

  parsedTransactions.add(
    Transaction(
      date: date,
      description: description,
      subTransactions: subTransactions,
    ),
  );

  return Success(value: parsedTransactions);
}

Result<SubTransaction> parseSubTransaction(String line) {
  final lineParts = _splitAndClean(line, '  ');
  final baseErrorMessage = 'Sub-transaction in line "$line" is not parsable.';

  if (lineParts.length == 1 || lineParts.length > 3) {
    return Error(message: baseErrorMessage);
  }

  final account = lineParts[0];

  String amount;
  if (lineParts.length == 3) {
    amount = lineParts[1] + lineParts[2];
  } else {
    amount = lineParts[1];
  }

  final exp = RegExp(
    r'(?<unit>[^0-9-]*)(?<value>[-+]?[0-9][0-9]*.?[0-9]*)(?<suffix_unit>[^0-9-]*)',
  );
  final match = exp.firstMatch(amount);

  if (match == null) {
    return Error(message: baseErrorMessage);
  }

  final value = match.namedGroup('value');
  if (value == null) {
    return Error(message: '$baseErrorMessage The value is not parsable.');
  }

  final unit = match.namedGroup('unit')?.trim();
  final suffixUnit = match.namedGroup('suffix_unit')?.trim();
  final spacesErrorMessage =
      '$baseErrorMessage The unit must not contain spaces.';
  Amount parsedAmount;

  if (suffixUnit != null && unit != null && suffixUnit != '' && unit != '') {
    return Error(
      message: '$baseErrorMessage The amount must have only on unit.',
    );
  } else if (suffixUnit != null && suffixUnit != '') {
    if (suffixUnit.contains(' ')) {
      return Error(message: spacesErrorMessage);
    }
    parsedAmount = SuffixedAmount(value: double.parse(value), unit: suffixUnit);
  } else {
    if (unit != null && unit.contains(' ')) {
      return Error(message: spacesErrorMessage);
    }
    parsedAmount = SuffixedAmount(value: double.parse(value), unit: unit);
  }

  return Success(
    value: SubTransaction(account: account, amount: parsedAmount),
  );
}

List<String> _splitAndClean(String line, String delimiter) {
  return line
      .split(delimiter)
      .map((l) => l.trim())
      .where((l) => l != '')
      .toList();
}

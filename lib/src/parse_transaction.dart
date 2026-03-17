import 'dart:math';

import 'record.dart';

Result parseTransaction(Transaction transaction) {
  var checkResult = _checkSubTransactions(transaction.subTransactions);

  if (checkResult is Error) {
    return checkResult;
  }

  var dateString = _formatDate(transaction.date);

  String description;
  if (transaction.description != null) {
    description = ' ${transaction.description!}';
  } else {
    description = '';
  }

  String subTransactions = _formatSubTransactions(transaction.subTransactions);

  return Success(value: '\n\n$dateString$description$subTransactions');
}

Result _checkSubTransactions(List<SubTransaction> subTransactions) {
  if (subTransactions.isEmpty) {
    return Error(message: 'The transactions contains no sub-transactions');
  }

  Map<String, double> balances = {};

  subTransactions.fold(
    balances,
    (balances, subTransaction) =>
        _updateBalances(balances, subTransaction.amount),
  );

  if (balances.length == 1 && balances[balances.keys.first] != 0) {
    return Error(
      message: 'This transaction is unbalanced. The sum should be 0.',
    );
  }

  var numberPositiveBalances = 0;
  var numberNegativeBalances = 0;

  for (var balance in balances.entries) {
    if (balance.value > 0) {
      numberPositiveBalances += 1;
    } else if (balance.value < 0) {
      numberNegativeBalances += 1;
    }
  }

  //hledger allows conversion transactions with exactly two participating units
  if ((numberNegativeBalances == 1 && numberPositiveBalances == 1) ||
      (numberPositiveBalances == 0 && numberNegativeBalances == 0)) {
    return Success(value: true);
  }

  var mCError =
      'This multi-commodity transaction is unbalanced. The sum should be 0.';

  return Error(message: mCError);
}

Map<String, double> _updateBalances(
  Map<String, double> balances,
  Amount amount,
) {
  var unit = amount.unit;
  var value = amount.value;

  unit ??= ' ';
  balances[unit] = (balances[unit] ?? 0) + value;

  return balances;
}

String _formatDate(DateTime date) {
  return '${date.year}-${_padLeft(date.month)}-${_padLeft(date.day)}';
}

String _padLeft(int value) {
  return value.toString().padLeft(2, '0');
}

String _formatSubTransactions(List<SubTransaction> subTransactions) {
  int maxAccountNameLength = subTransactions.fold(
    0,
    (maxAccountNameLength, subTransactions) =>
        max(maxAccountNameLength, subTransactions.account.main.length),
  );

  int maxAmountLength = subTransactions.fold(
    0,
    (maxAmountLength, subTransaction) =>
        max(maxAmountLength, _calcAmountLength(subTransaction.amount)),
  );

  String subTransactionsString = subTransactions.fold(
    '',
    (subTransactionsString, subTransaction) =>
        subTransactionsString +
        _formatSubTransaction(
          subTransaction,
          maxAccountNameLength,
          maxAmountLength,
        ),
  );

  return subTransactionsString;
}

int _calcAmountLength(Amount amount) {
  var valueLength = amount.value.toString().length;
  var unit = amount.unit;

  if (amount is SuffixedAmount) {
    return valueLength + (unit != null ? unit.length + 1 : 0);
  }

  return valueLength + (unit != null ? unit.length : 0);
}

String _formatSubTransaction(
  SubTransaction subTransaction,
  int maxAccountNameLength,
  int maxAmountLength,
) {
  return '\n    '
      '${subTransaction.account.main.padRight(maxAccountNameLength)}'
      '  '
      '${_formatAmount(subTransaction.amount).padLeft(maxAmountLength)}';
}

String _formatAmount(Amount amount) {
  var unit = amount.unit;

  if (amount is SuffixedAmount) {
    unit = unit != null ? ' $unit' : '';
    return '${amount.value.toString()}$unit';
  } else {
    unit = unit ?? '';
    return '$unit${amount.value.toString()}';
  }
}

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
  var value = amount.amount;

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
    (maxAmountLength, subTransactions) =>
        max(maxAmountLength, subTransactions.amount.amount.toString().length),
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

String _formatSubTransaction(
  SubTransaction subTransaction,
  int maxAccountNameLength,
  int maxAmountLength,
) {
  return '\n    '
      '${subTransaction.account.main.padRight(maxAccountNameLength)}'
      '  '
      '${subTransaction.amount.amount.toString().padLeft(maxAmountLength)}';
}

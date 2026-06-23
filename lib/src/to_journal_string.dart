import 'dart:math';

import 'functions.dart';
import 'record.dart';

/// Use Case: Convert a transaction object to a hledger journal entry
Result<String> toJournalString(Result<Transaction> transaction) {
  switch (transaction) {
    case Success<Transaction> _:
      return _toJournalString(transaction.value);
    case Error<Transaction> _:
      return Error(message: transaction.message);
  }
}

Result<String> _toJournalString(Transaction transaction) {
  String dateString = _formatDate(transaction.date);
  String description = _formatDescription(transaction.description);
  String subTransactions = _formatSubTransactions(transaction.subTransactions);

  return Success(value: '\n\n$dateString$description$subTransactions');
}

String _formatDescription(String? description) {
  return description != null ? ' $description' : '';
}

String _formatDate(DateTime date) {
  return formatToIsoDate(date);
}

String _formatSubTransactions(List<SubTransaction> subTransactions) {
  int maxAccountNameLength = subTransactions.fold(
    0,
    (maxAccountNameLength, subTransaction) =>
        max(maxAccountNameLength, subTransaction.account.length),
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
  return '\n'
      '    '
      '${subTransaction.account.padRight(maxAccountNameLength)}'
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

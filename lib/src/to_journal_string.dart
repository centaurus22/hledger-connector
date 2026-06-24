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
  String postings = _formatPostings(transaction.postings);

  return Success(value: '\n\n$dateString$description$postings');
}

String _formatDescription(String? description) {
  return description != null ? ' $description' : '';
}

String _formatDate(DateTime date) {
  return formatToIsoDate(date);
}

String _formatPostings(List<Posting> postings) {
  int maxAccountNameLength = postings.fold(
    0,
    (maxAccountNameLength, posting) =>
        max(maxAccountNameLength, posting.account.length),
  );

  int maxAmountLength = postings.fold(
    0,
    (maxAmountLength, posting) =>
        max(maxAmountLength, _calcAmountLength(posting.amount)),
  );

  String postingsString = postings.fold(
    '',
    (postingsString, posting) =>
        postingsString +
        _formatPosting(posting, maxAccountNameLength, maxAmountLength),
  );

  return postingsString;
}

int _calcAmountLength(Amount amount) {
  var valueLength = amount.value.toString().length;
  var unit = amount.unit;

  if (amount is SuffixedAmount) {
    return valueLength + (unit != null ? unit.length + 1 : 0);
  }

  return valueLength + (unit != null ? unit.length : 0);
}

String _formatPosting(
  Posting posting,
  int maxAccountNameLength,
  int maxAmountLength,
) {
  return '\n'
      '    '
      '${posting.account.padRight(maxAccountNameLength)}'
      '  '
      '${_formatAmount(posting.amount).padLeft(maxAmountLength)}';
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

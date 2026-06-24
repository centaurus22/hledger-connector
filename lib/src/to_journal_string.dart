import 'dart:math';

import 'functions.dart';
import 'record.dart';

/// Use Case: Convert a transaction object to a hledger journal entry
Result<String> toJournalString(Result<Transaction> transaction) {
  switch (transaction) {
    case Ok<Transaction> _:
      return _toJournalString(transaction.value);
    case Error<Transaction> _:
      return Error(transaction.message);
  }
}

Result<String> _toJournalString(Transaction transaction) {
  String dateString = _formatDate(transaction.date);
  String description = _formatDescription(transaction.description);
  String postings = _formatPostings(transaction.postings);

  return Ok('\n\n$dateString$description$postings');
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
  final valueLength = amount.value.toString().length;
  final symbol = amount.symbol;

  switch (symbol) {
    case PrecedingSymbol _:
      return valueLength + symbol.name.length;
    case FollowingSymbol _:
      return valueLength + symbol.name.length + 1;
    default:
      return valueLength;
  }
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
  final symbol = amount.symbol;
  final value = amount.value.toString();

  switch (symbol) {
    case PrecedingSymbol _:
      return '${symbol.name}$value';
    case FollowingSymbol _:
      return '$value ${symbol.name}';
    default:
      return value;
  }
}

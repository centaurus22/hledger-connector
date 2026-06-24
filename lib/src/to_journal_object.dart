import 'functions.dart';
import 'record.dart';

/// Use Case: Parse a String of Transactions to a List of Transaction Records
Result<List<Transaction>> toJournalObject(Result<List<String>> transactions) {
  switch (transactions) {
    case Success<List<String>> _:
      return _toJournalObject(transactions.value);
    case Error<List<String>> _:
      return Error(message: transactions.message);
  }
}

Result<List<Transaction>> _toJournalObject(List<String> lines) {
  List<List<String>> transactions = List.empty(growable: true);
  List<String> transaction = List.empty(growable: true);
  int? firstChar;

  for (var line in lines) {
    //filter lines with a comment
    if ([';', '#', '*'].contains(line.trimLeft()[0])) {
      continue;
    }

    //Every transaction starts with a date
    firstChar = int.tryParse(line[0]);
    if (firstChar != null) {
      transactions.add(transaction);
      transaction = List.empty(growable: true);
    }
    transaction.add(line);
  }
  transactions.add(transaction);

  final parsedTransactions = transactions
      .sublist(1)
      .map((t) => _parseTransaction(t));

  return _sort(check(parsedTransactions));
}

Result<Transaction> _parseTransaction(List<String> transaction) {
  final dateDescription = _splitAndClean(transaction[0], ' ');
  final description = _parseDescription(dateDescription);

  final dateResult = _parseDate(dateDescription[0]);
  DateTime date;
  switch (dateResult) {
    case Success<DateTime> _:
      date = dateResult.value;
    case Error<DateTime> _:
      return Error(message: dateResult.message);
  }

  var parsedPostings = transaction
      .sublist(1)
      .map((t) => _parsePosting(t))
      .toList();

  final checkedPostings = check(parsedPostings);

  switch (checkedPostings) {
    case Success<List<Posting>> _:
      return Success(
        value: Transaction(
          date: date,
          description: description,
          postings: checkedPostings.value,
        ),
      );
    case Error<List<Posting>> _:
      return Error(message: checkedPostings.message);
  }
}

Result<Posting> _parsePosting(String line) {
  final lineParts = _splitAndClean(line, '  ');
  final baseErrorMessage = 'Posting in line "$line" is not parsable.';

  if (lineParts.length == 1) {
    return Error(message: baseErrorMessage);
  }

  final account = lineParts[0];
  final amount = lineParts.sublist(1).join(' ');

  final exp = RegExp(
    r'(?<unit>[^0-9-]*)'
    r'(?<value>[-+]?[0-9][0-9]*\.?[0-9]*)'
    r'(?<suffix_unit>[^0-9-;]*)',
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
    parsedAmount = Amount(value: double.parse(value), unit: unit);
  }

  return Success(
    value: Posting(account: account, amount: parsedAmount),
  );
}

List<String> _splitAndClean(String line, String delimiter) {
  return line
      .split(delimiter)
      .map((l) => l.trim())
      .where((l) => l != '')
      .toList();
}

String? _parseDescription(List<String> input) {
  if (input.length > 1) {
    return input.sublist(1).join(' ');
  } else {
    return null;
  }
}

Result<DateTime> _parseDate(String dateString) {
  dateString = dateString.replaceAll('.', '-').replaceAll('/', '-');
  final date = DateTime.tryParse(dateString);
  if (date == null) {
    return Error(message: 'The date in line "$dateString" is not parsable.');
  } else if (dateString != formatToIsoDate(date)) {
    return Error(message: 'The date in line "$dateString" is invalid.');
  } else {
    return Success(value: date);
  }
}

Result<List<Transaction>> _sort(Result<List<Transaction>> transactions) {
  switch (transactions) {
    case Success<List<Transaction>> _:
      transactions.value.sort((a, b) => a.date.compareTo(b.date));
      return transactions;
    case Error<List<Transaction>> _:
      return transactions;
  }
}

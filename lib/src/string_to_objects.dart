import 'functions.dart';
import 'record.dart';

/// Use Case: Convert transactions to a list of [Transaction]s.
Result<List<Transaction>> stringToObjects(Result<List<String>> transactions) {
  switch (transactions) {
    case Ok<List<String>> _:
      return _stringToObjects(transactions.value);
    case Error<List<String>> _:
      return Error(transactions.message);
  }
}

Result<List<Transaction>> _stringToObjects(List<String> lines) {
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
    case Ok<DateTime> _:
      date = dateResult.value;
    case Error<DateTime> _:
      return Error(dateResult.message);
  }

  var parsedPostings = transaction
      .sublist(1)
      .map((t) => _parsePosting(t))
      .toList();

  final checkedPostings = check(parsedPostings);

  switch (checkedPostings) {
    case Ok<List<Posting>> _:
      return Ok(
        Transaction(
          date: date,
          description: description,
          postings: checkedPostings.value,
        ),
      );
    case Error<List<Posting>> _:
      return Error(checkedPostings.message);
  }
}

Result<Posting> _parsePosting(String line) {
  final lineParts = _splitAndClean(line, '  ');
  final baseErrorMessage = 'Posting in line "$line" is not parsable.';

  if (lineParts.length == 1) {
    return Error(baseErrorMessage);
  }

  final account = lineParts[0];
  final amount = lineParts.sublist(1).join(' ');

  final exp = RegExp(
    r'(?<preceding_symbol>[^0-9-]*)'
    r'(?<value>[-+]?[0-9][0-9]*\.?[0-9]*)'
    r'(?<following_symbol>[^0-9-;]*)',
  );
  final match = exp.firstMatch(amount);

  if (match == null) {
    return Error(baseErrorMessage);
  }

  final value = match.namedGroup('value');
  if (value == null) {
    return Error('$baseErrorMessage The value is not parsable.');
  }

  final precedingSymbol = match.namedGroup('preceding_symbol')?.trim();
  final followingSymbol = match.namedGroup('following_symbol')?.trim();
  final spacesErrorMessage =
      '$baseErrorMessage The unit must not contain spaces.';

  Amount parsedAmount;
  if (precedingSymbol != null &&
      followingSymbol != null &&
      precedingSymbol != '' &&
      followingSymbol != '') {
    return Error('$baseErrorMessage The amount must have only on symbol.');
  } else if (precedingSymbol != null && precedingSymbol != '') {
    if (precedingSymbol.contains(' ')) {
      return Error(spacesErrorMessage);
    }
    parsedAmount = Amount(
      value: double.parse(value),
      symbol: PrecedingSymbol(precedingSymbol),
    );
  } else if (followingSymbol != null && followingSymbol != '') {
    if (followingSymbol.contains(' ')) {
      return Error(spacesErrorMessage);
    }
    parsedAmount = Amount(
      value: double.parse(value),
      symbol: FollowingSymbol(followingSymbol),
    );
  } else {
    parsedAmount = Amount(value: double.parse(value));
  }

  return Ok(Posting(account: account, amount: parsedAmount));
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
    return Error('The date in line "$dateString" is not parsable.');
  } else if (dateString != formatToIsoDate(date)) {
    return Error('The date in line "$dateString" is invalid.');
  } else {
    return Ok(date);
  }
}

Result<List<Transaction>> _sort(Result<List<Transaction>> transactions) {
  switch (transactions) {
    case Ok<List<Transaction>> _:
      transactions.value.sort((a, b) => a.date.compareTo(b.date));
      return transactions;
    case Error<List<Transaction>> _:
      return transactions;
  }
}

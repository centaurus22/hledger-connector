import 'record.dart';

/// Use Case: Check a transaction for data errors
Result<Transaction> checkTransaction(Transaction transaction) {
  final result = _checkPostings(transaction.postings);

  switch (result) {
    case Ok<String> _:
      return Ok(transaction);
    case Error<String> _:
      return Error(result.message);
  }
}

Result<String> _checkPostings(List<Posting> postings) {
  if (postings.isEmpty) {
    return Error('The transactions contains no sub-transactions');
  }

  for (var posting in postings) {
    /// hledger does not accept empty account names.
    if (posting.account.isEmpty || posting.account.contains('  ')) {
      return Error(
        'A valid hledger account name is required. Eg: assets:cash, expenses:food:eating out.',
      );
    }
  }

  Map<String, double> balances = {};

  postings.fold(
    balances,
    (balances, posting) => _updateBalances(balances, posting.amount),
  );

  if (balances.length == 1 && balances[balances.keys.first] != 0) {
    return Error('This transaction is unbalanced. The sum should be 0.');
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
    return Ok("Check complete");
  }

  var multiCommodityError =
      'This multi-commodity transaction is unbalanced. The sum should be 0.';

  return Error(multiCommodityError);
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

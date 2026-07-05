import 'record.dart';

/// Use Case: Check a [Transaction] for data errors.
Result validateObject(Transaction transaction) {
  final List<Posting> postings = transaction.postings;
  if (transaction.postings.isEmpty) {
    return Invalid('The transactions contains no postings');
  }

  for (var posting in transaction.postings) {
    /// hledger does not accept empty account names or account names with
    /// more than one space in a row
    if (posting.account.isEmpty || posting.account.contains('  ')) {
      return Invalid(
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
    return Invalid('This transaction is unbalanced. The sum should be 0.');
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
    return Valid();
  }

  var multiCommodityError =
      'This multi-commodity transaction is unbalanced. The sum should be 0.';

  return Invalid(multiCommodityError);
}

Map<String, double> _updateBalances(
  Map<String, double> balances,
  Amount amount,
) {
  var symbol = amount.symbol?.name;
  var value = amount.value;

  symbol ??= ' ';
  balances[symbol] = (balances[symbol] ?? 0) + value;

  return balances;
}

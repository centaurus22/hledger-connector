import 'record.dart';

/// Use Case: Check a transaction for data errors
Result<Transaction> checkTransaction(Transaction transaction) {
  final result = _checkSubTransactions(transaction.subTransactions);

  switch (result) {
    case Success<String> _:
      return Success(value: transaction);
    case Error<String> _:
      return Error(message: result.message);
  }
}

Result<String> _checkSubTransactions(List<SubTransaction> subTransactions) {
  if (subTransactions.isEmpty) {
    return Error(message: 'The transactions contains no sub-transactions');
  }

  for (var subTransaction in subTransactions) {
    /// hledger does not accept empty account names.
    if (subTransaction.account.isEmpty ||
        subTransaction.account.contains('  ')) {
      return Error(
        message:
            'A valid hledger account name is required. Eg: assets:cash, expenses:food:eating out.',
      );
    }
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
    return Success(value: "Check complete");
  }

  var multiCommodityError =
      'This multi-commodity transaction is unbalanced. The sum should be 0.';

  return Error(message: multiCommodityError);
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

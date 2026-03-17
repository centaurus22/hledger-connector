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

  return Success(value: '\n$dateString$description\n');
}

Result _checkSubTransactions(List<SubTransaction> subTransactions) {
  if (subTransactions.isEmpty) {
    return Error(message: 'The transactions contains no sub-transactions');
  }

  Map<String, double> balances = {};

  var balance = subTransactions.fold(
    balances,
    (balances, subTransaction) =>
        _updateBalances(balances, subTransaction.amount),
  );

  for (var balance in balances.entries) {
    if (balance.value != 0) {
      return Error(
        message: 'The transaction is unbalanced. The sum should be 0.',
      );
    }
  }

  return Success(value: balance);
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

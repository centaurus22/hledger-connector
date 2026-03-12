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

  var balance = subTransactions.fold(
    0.0,
    (balance, subTransaction) => balance + subTransaction.amount.amount,
  );

  if (balance == 0.0) {
    return Success(value: balance);
  }

  return Error(message: 'The transaction is unbalanced. The sum should be 0.');
}

String _formatDate(DateTime date) {
  return '${date.year}-${_padLeft(date.month)}-${_padLeft(date.day)}';
}

String _padLeft(int value) {
  return value.toString().padLeft(2, '0');
}

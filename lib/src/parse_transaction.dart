import 'record.dart';

Result parseTransaction(Transaction transaction) {
  if (transaction.subTransactions.isEmpty) {
    return Error(message: 'The transactions contains no sub-transactions');
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

String _formatDate(DateTime date) {
  return '${date.year}-${_padLeft(date.month)}-${_padLeft(date.day)}';
}

String _padLeft(int value) {
  return value.toString().padLeft(2, '0');
}

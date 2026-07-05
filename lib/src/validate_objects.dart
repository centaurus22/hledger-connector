import 'validate_object.dart';
import 'record.dart';

/// Use Case: Check a list of [Transaction]s for data errors.
Result validateObjects(List<Transaction> transactions) {
  final validationResults = transactions.map(validateObject);
  final invalidResults = validationResults.whereType<Invalid>();

  if (invalidResults.isEmpty) {
    return Valid();
  } else {
    return Invalid(invalidResults.first.error);
  }
}

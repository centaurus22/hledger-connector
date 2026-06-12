import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction_string.dart';

void main() {
  test('returning error if the input is an Error', () {
    Error<List<String>> value = Error(message: 'The file cannot be found.');
    var result = parseTransactionString(value);
    expect(result.runtimeType, Error<List<Transaction>>);
  });
}

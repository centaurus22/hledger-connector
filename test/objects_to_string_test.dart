import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/objects_to_string.dart';

void main() {
  test('Error as input', () {
    Error<List<Transaction>> value = Error('The file cannot be found.');
    var result = objectsToString(value);
    expect(result.runtimeType, Error<String>);
  });
}

import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/write_to_file.dart';

void main() {
  test('throwing error if the file path is empty', () {
    Result<String> result = writeToFile(Ok(''), '');
    expect(result.runtimeType, Error<String>);
    if (result is Error<String>) {
      expect(result.message, 'The file path cannot be empty.');
    }
  });
  test('Error passed to function', () {
    final transaction = Error<String>("transaction invalid.");
    var realResult = writeToFile(transaction, '');
    expect(realResult.runtimeType, Error<String>);
  });
}

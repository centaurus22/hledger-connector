import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/write_to_file.dart';

void main() {
  test('throwing error if the file name is empty', () async {
    Result<String> result = writeToFile(Success(value: ''), '');
    expect(result.runtimeType, Error<String>);
    if (result is Error<String>) {
      expect(result.message, 'The file name cannot be empty.');
    }
  });
}

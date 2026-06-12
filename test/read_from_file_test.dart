import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/read_from_file.dart';

void main() {
  test('throwing error if the file name is empty', () async {
    Result<List<String>> result = readFromFile('');
    expect(result.runtimeType, Error<List<String>>);
    if (result is Error<List<String>>) {
      expect(result.message, 'The file name cannot be empty.');
    }
  });
}

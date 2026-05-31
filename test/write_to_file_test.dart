import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/write_to_file.dart';

void main() {
  test('throwing error if the file name is empty', () async {
    Result result = await writeToFile(Success(value: ''), '');
    expect(result.runtimeType, Error);
    if (result is Error) {
      expect(result.message, 'The file name cannot be empty.');
    }
  });
}

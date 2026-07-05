import 'package:test/test.dart';

import 'package:hledger_connector/src/write_to_file.dart';

void main() {
  test('throwing error if the file path is empty', () {
    expect(() => writeToFile('', ''), throwsArgumentError);
  });
}

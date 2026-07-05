import 'package:test/test.dart';

import 'package:hledger_connector/src/read_from_file.dart';

void main() {
  test('throwing error if the file path is empty', () {
    expect(() => readFromFile(''), throwsArgumentError);
  });
}

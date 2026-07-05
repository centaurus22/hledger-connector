import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/objects_to_string.dart';

void main() {
  test('working conversions to string', () {
    final transaction = Transaction(
      date: DateTime(2012, 12, 12),
      postings: [
        Posting(account: 'assets', amount: Amount(value: 10)),
        Posting(account: 'expenses', amount: Amount(value: -10)),
      ],
    );
    var result = objectsToString([transaction, transaction]);
    var expectedResult =
        '\n\n'
        '2012-12-12\n'
        '    assets     10.0\n'
        '    expenses  -10.0\n'
        '\n'
        '2012-12-12\n'
        '    assets     10.0\n'
        '    expenses  -10.0';
    expect(result, expectedResult);
  });
}

import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction.dart';

void main() {
    test('if transaction starts with a date', () {
      var transaction = Transaction(date: DateTime(2026,01,01), subTransactions: []);
      var result = parseTransaction(transaction);
      expect(result.substring(0,11), '\n2026-01-01');
    });
}
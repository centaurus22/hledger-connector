import 'package:hledger_connector/src/record.dart';
import 'package:test/test.dart';

import 'package:hledger_connector/src/parse_transaction.dart';

void main() {
    test('if transaction starts with a date', () {
      var transaction = Transaction(date: DateTime(2026,01,01), subTransactions: []);
      var result = parseTransaction(transaction);
      expect(result.substring(0,result.length), '\n2026-01-01\n');
    });
    test('if description is rendered', () {
      var transaction = Transaction(
        date: DateTime(2026,01,02),
        description: 'First Transaction',
        subTransactions: []
      );
      var result = parseTransaction(transaction);
      expect(result.substring(0,result.length), '\n2026-01-02 First Transaction\n');
    });
    test('date with only a year', () {
      var transaction = Transaction(date: DateTime(2026), subTransactions: []);
      var result = parseTransaction(transaction);
      expect(result.substring(0,result.length), '\n2026-01-01\n');
    });
}
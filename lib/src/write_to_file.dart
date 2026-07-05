import 'functions.dart';
import 'record.dart';

import 'dart:io';

/// Use Case: Write the [Transaction] to file with the path [filePath].
void writeToFile(String content, String filePath) {
  if (filePath == '') {
    throw ArgumentError('The file path cannot be empty.');
  }

  final file = File(filePath);

  if (file.existsSync() == false || file.lengthSync() == 0) {
    file.writeAsStringSync(fileHeader());
  }

  file.writeAsStringSync(content, mode: FileMode.append);
}

String fileHeader() {
  final date = formatToIsoDate(DateTime.now());
  return '; Journal created $date by hledger-connector';
}

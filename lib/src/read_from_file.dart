import 'record.dart';

import 'dart:io';

/// Use Case: Write the [Transaction] to file with the [filePath].
List<String> readFromFile(String filePath) {
  if (filePath == '') {
    throw ArgumentError('The file path cannot be empty.');
  }

  return File(filePath).readAsLinesSync();
}

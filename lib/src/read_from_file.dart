import 'record.dart';

import 'dart:io';

/// Use Case: Write the transaction to file
Result<List<String>> readFromFile(String fileName) {
  if (fileName == '') {
    return Error('The file name cannot be empty.');
  }

  try {
    final file = File(fileName);

    if (file.existsSync()) {
      return Error("The file cannot be found.");
    }

    return Ok(file.readAsLinesSync());
  } catch (e) {
    return Error('$e');
  }
}

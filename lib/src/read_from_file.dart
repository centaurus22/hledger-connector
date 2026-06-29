import 'record.dart';

import 'dart:io';

/// Use Case: Write the [Transaction] to file with the [filePath].
Result<List<String>> readFromFile(String filePath) {
  if (filePath == '') {
    return Error('The file path cannot be empty.');
  }

  try {
    final file = File(filePath);

    if (file.existsSync()) {
      return Error("The file cannot be found.");
    }

    return Ok(file.readAsLinesSync());
  } catch (e) {
    return Error('$e');
  }
}

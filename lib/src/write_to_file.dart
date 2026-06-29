import 'functions.dart';
import 'record.dart';

import 'dart:io';

/// Use Case: Write the [Transaction] to file with the path [filePath].
Result<String> writeToFile(Result<String> contentResult, String filePath) {
  switch (contentResult) {
    case Ok<String> _:
      return _writeToFile(contentResult.value, filePath);
    case Error _:
      return contentResult;
  }
}

Result<String> _writeToFile(String content, String filePath) {
  if (filePath == '') {
    return Error('The file path cannot be empty.');
  }

  try {
    final file = File(filePath);

    if (file.existsSync() == false || file.lengthSync() == 0) {
      file.writeAsStringSync(fileHeader());
    }

    file.writeAsStringSync(content, mode: FileMode.append);
  } catch (e) {
    return Error('$e');
  }

  return Ok(content);
}

String fileHeader() {
  final date = formatToIsoDate(DateTime.now());
  return '; Journal created $date by hledger-connector';
}

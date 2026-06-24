import 'functions.dart';
import 'record.dart';

import 'dart:io';

/// Use Case: Write the transaction to file
Result<String> writeToFile(Result<String> contentResult, String fileName) {
  switch (contentResult) {
    case Ok<String> _:
      return _writeToFile(contentResult.value, fileName);
    case Error _:
      return contentResult;
  }
}

Result<String> _writeToFile(String content, String fileName) {
  if (fileName == '') {
    return Error('The file name cannot be empty.');
  }

  try {
    final file = File(fileName);

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

import 'functions.dart';
import 'record.dart';

import 'dart:io';

/// Use Case: Write the transaction to file
Result<String> writeToFile(Result<String> contentResult, String fileName) {
  switch (contentResult) {
    case Error _:
      return contentResult;
    case Success<String> _:
      return _writeToFile(contentResult.value, fileName);
  }
}

Result<String> _writeToFile(String content, String fileName) {
  if (fileName == '') {
    return Error(message: 'The file name cannot be empty.');
  }

  try {
    final file = File(fileName);

    if (file.existsSync() == false || file.lengthSync() == 0) {
      file.writeAsStringSync(fileHeader());
    }

    file.writeAsStringSync(content, mode: FileMode.append);
  } catch (e) {
    return Error(message: '$e');
  }

  return Success(value: content);
}

String fileHeader() {
  final date = formatToIsoDate(DateTime.now());
  return '; Journal created $date by hledger-connector';
}

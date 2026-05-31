import 'functions.dart';
import 'record.dart';

import 'dart:io';

/// Use Case: Write the transaction to file
Future<Result> writeToFile(Result contentResult, String fileName) async {
  switch (contentResult) {
    case Error _:
      return contentResult;
    case Success _:
      return _writeToFile(contentResult.value, fileName);
  }
}

Future<Result> _writeToFile(String content, String fileName) async {
  if (fileName == '') {
    return Error(message: 'The file name cannot be empty.');
  }

  try {
    final file = File(fileName);

    if (await file.exists() == false || await file.length() == 0) {
      await file.writeAsString(fileHeader());
    }

    await file.writeAsString(content, mode: FileMode.append);
  } catch (e) {
    return Error(message: '$e');
  }

  return Success(value: content);
}

String fileHeader() {
  final date = formatToIsoDate(DateTime.now());
  return '; Journal created $date by hledger-connector';
}

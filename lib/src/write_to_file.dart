import 'functions.dart';
import 'record.dart';

import 'dart:io';

/// Use Case: Write the transaction to file
Future<Result> writeToFile(Result contentResult, JournalFile file) async {
  switch (contentResult) {
    case Error _:
      return contentResult;
    case Success _:
      return _writeToFile(contentResult.value, file);
  }
}

Future<Result> _writeToFile(String content, JournalFile file) async {
  final fileName = _fromFile(file);

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

String _fromFile(JournalFile file) {
  var path = file.path;

  if (path == null) {
    return file.name;
  }

  final pathString = path.fold('', (path, pathElement) => '$pathElement/$path');
  return '$pathString/${file.name}';
}

String fileHeader() {
  final date = formatToIsoDate(DateTime.now());
  return '; Journal created $date by hledger-connector';
}

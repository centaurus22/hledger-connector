import 'record.dart';

import 'dart:io';

Result writeToFile(String content, JournalFile file) {
  final fileName = fromFile(file);

  try {
    final file = File(fileName);
    file.writeAsString(content);
  } catch (e) {
    return Error(message: '$e');
  }

  return Success(value: content);
}

String fromFile(JournalFile file) {
  if (file.path == null) {
    return file.name;
  }

  final filePath = file.path;
  final path = filePath!.fold('', (path, pathElement) => '$pathElement/$path');
  return '$path/${file.name}';
}

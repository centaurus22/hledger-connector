import 'record.dart';

import 'dart:io' as io;

Result writeToFile(String content, File file) {
  final fileName = fromFile(file);

  try {
    final ioFile = io.File(fileName);
    ioFile.writeAsString(content);
  } catch (e) {
    return Error(message: '$e');
  }

  return Success(value: content);
}

String fromFile(File file) {
  if (file.path == null) {
    return file.name;
  }

  final filePath = file.path;
  final path = filePath!.fold('', (path, pathElement) => '$pathElement/$path');
  return '$path/${file.name}';
}

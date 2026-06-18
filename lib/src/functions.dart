import 'record.dart';

String formatToIsoDate(DateTime date) {
  return '${date.year}-${_padLeft(date.month)}-${_padLeft(date.day)}';
}

String _padLeft(int value) {
  return value.toString().padLeft(2, '0');
}

Result<List<T>> check<T>(Iterable<Result<T>> elements) {
  final errorElements = elements.whereType<Error<T>>();
  if (errorElements.isNotEmpty) {
    return Error(message: errorElements.first.message);
  }

  final successElements = (elements.whereType<Success<T>>());
  return Success(value: successElements.map((e) => e.value).toList());
}

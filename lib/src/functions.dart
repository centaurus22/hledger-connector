String formatToIsoDate(DateTime date) {
  return '${date.year}-${_padLeft(date.month)}-${_padLeft(date.day)}';
}

String _padLeft(int value) {
  return value.toString().padLeft(2, '0');
}

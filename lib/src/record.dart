class Transaction {
  /// An optional description
  String? description;

  /// The date of the [Transaction]
  DateTime date;

  /// A list of [Posting]s, this [Transaction] is composed of.
  List<Posting> postings;

  /// Requires a [date], a list of [Posting]s and an optional
  /// description.
  Transaction({this.description, required this.date, required this.postings});
}

/// A [Transaction] is composed of two or more of this.
class Posting {
  /// The [account] the units are transferred from or to.
  String account;

  /// The amount which is transferred.
  Amount amount;

  /// This requires an [Account] and an [Amount].
  Posting({required this.account, required this.amount});
}

/// The amount transferred in a [Posting].
///
/// In this base class the optional unit is written in front of the amount. In
/// the child class [SuffixedAmount], the unit is written behind the amount.
class Amount {
  /// The amount that is transferred.
  double value;

  /// The optional unit.
  String? unit;

  /// The [value] is required. Optionally a [unit] can be added.
  Amount({required this.value, this.unit});
}

/// Child class of the [Amount].
///
/// The difference of this and the base class ist that the unit is written after
/// the amount.
class SuffixedAmount extends Amount {
  /// The [value] is required. Optionally a [unit] can be added.
  SuffixedAmount({required super.value, super.unit});
}

/// A result of a function which can be a [Success] or an [Error].
///
/// This is the sealed base class. Its children are used in functions that can
/// return an [Error] instead of a of an expected value ([Success])
/// or additional [warnings].
sealed class Result<T> {
  /// A list of warnings.
  final List<String> warnings = [];
}

/// This is returned when functions are executed correctly.
///
/// It can contain additional [warnings].
/// The sealed base class is the [Result]. The other [Result] ist a [Error].
class Ok<T> extends Result<T> {
  /// The embedded value.
  final T value;

  /// This requires the embedded [value].
  Ok(this.value);
}

/// This is returned when a parameter is not valid.
///
/// It can contain additional [warnings].
/// The sealed base class ist the [Result]. The other [Result] ist a [Success].
/// when the function executed correctly.
class Error<T> extends Result<T> {
  /// The error message.
  final String message;

  /// This requires the error [message].
  Error(this.message);
}

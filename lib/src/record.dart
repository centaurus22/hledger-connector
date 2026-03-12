class Transaction {
  /// An optional description
  String? description;

  /// The date of the [Transaction]
  DateTime date;

  /// A list of [SubTransaction]s, this [Transaction] is composed of.
  List<SubTransaction> subTransactions;

  /// Requires a [date], a list of [SubTransaction]s and an optional
  /// description.
  Transaction({
    this.description,
    required this.date,
    required this.subTransactions,
  });
}

/// A [Transaction] is composed of two or more of this.
class SubTransaction {
  /// The [Account] the units are transferred from or too.
  Account account;

  /// The amount which is transferred.
  Amount amount;

  /// This requires an [Account] and an [Amount].
  SubTransaction({required this.account, required this.amount});
}

/// The amount transferred in a [SubTransaction].
///
/// In this base class the optional unit is written in front of the amount. In
/// the child class [SuffixedAmount], the unit is written behind the amount.
class Amount {
  /// The amount that is transferred.
  double amount;

  /// The optional unit.
  String? unit;

  /// The [amount] is required. Optionally a [unit] can be added.
  Amount({required this.amount, this.unit});
}

/// Child class of the [Amount].
///
/// The difference of this and the base class ist that the unit is written after
/// the amount.
class SuffixedAmount extends Amount {
  /// The [amount] is required. Optionally a [unit] can be added.
  SuffixedAmount({required super.amount, super.unit});
}

/// This represents an account string in hledger.
///
/// Eg. "assets:bank:savings". The required main account name "assets" is stored
/// in the required String [main]. Optional sub account names are stored in an
/// optional List [sub]. In this case this would be `['bank', 'savings'].
class Account {
  /// The main account name.
  String main;

  /// The sub account as a List.
  List<String>? sub;

  /// This requires the [main] account and the optional [sub] account as a List.
  Account({required this.main, this.sub});
}

/// A result of a function which can be a [Success] or an [Error].
///
/// This is the sealed base class. Its children are used in functions that can
/// return an [Error] instead of a of an expected value ([Success])
/// or additional [warnings].
sealed class Result {
  /// A list of warnings.
  final List<String> warnings = [];
}

/// This is returned when functions are executed correctly.
///
/// It can contain additional [warnings].
/// The sealed base class is the [Result]. The other [Result] ist a [Error].
class Success extends Result {
  /// The embedded value.
  final dynamic value;

  /// This requires the embedded [value].
  Success({required this.value});
}

/// This is returned when a parameter is not valid.
///
/// It can contain additional [warnings].
/// The sealed base class ist the [Result]. The other [Result] ist a [Success].
/// when the function executed correctly.
class Error extends Result {
  /// The error message.
  final String message;

  /// This requires the error [message].
  Error({required this.message});
}

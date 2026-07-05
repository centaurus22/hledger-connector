/// This represents a hledger journal entry
///
/// It contains a [date], optionally a [description] and a list of [postings].
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

  /// The [Amount] which is transferred.
  Amount amount;

  /// This requires an [account] and an [Amount].
  Posting({required this.account, required this.amount});
}

/// The amount transferred in a [Posting].
class Amount {
  /// The amount that is transferred.
  double value;

  /// The optional symbol.
  Symbol? symbol;

  /// The [value] is required. Optionally a [Symbol] can be added.
  Amount({required this.value, this.symbol});
}

/// This can be optionally added to an amount. You probably want to do this.
///
/// I represents a commodity symbol or a currency symbol.
///
/// You cannot initialize this object directly. Instead, use one of the two
/// subclasses: [PrecedingSymbol] where the unit or symbol stands
/// in front of the numerical value, and [FollowingSymbol] where
/// the symbol appears after the number.
sealed class Symbol {
  /// The actual symbol as [String].
  String name;

  /// This requires the [name].
  Symbol(this.name);
}

/// Child class of the [Symbol].
///
/// This represents a symbol that appears after the numerical value with no
/// space between the number and the symbol.
///
/// The other subclass is the [FollowingSymbol].
class PrecedingSymbol extends Symbol {
  /// This requires the [name].
  PrecedingSymbol(super.name);
}

/// Child class of the [Symbol].
///
/// This represents a symbol that appears before the numerical value with one
/// space between the value and the symbol. It is useful for most currency
/// symbols.
///
/// The other subclass is the [FollowingSymbol].
class FollowingSymbol extends Symbol {
  /// This requires the [name].
  FollowingSymbol(super.name);
}

sealed class Result {
  Result();
}

class Valid extends Result {}

class Invalid extends Result {
  final String error;

  Invalid(this.error);
}

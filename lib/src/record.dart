class Transaction {
  String description;
  DateTime date;
  List<SubTransaction> transactions;

  Transaction({
    required this.description,
    required this.date,
    required this.transactions,
  });
}

class SubTransaction {
  Account account;
  Amount amount;

  SubTransaction({required this.account, required this.amount});
}

class Amount {
  double amount;
  String unit;

  Amount({required this.amount, required this.unit});
}

class SuffixedAmount extends Amount {
  SuffixedAmount({required super.amount, required super.unit});
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

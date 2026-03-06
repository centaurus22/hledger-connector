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
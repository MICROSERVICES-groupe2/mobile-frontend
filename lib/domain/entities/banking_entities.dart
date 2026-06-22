// Domain: Transaction
class Transaction {
  final String id;
  final double amount;
  final String type;
  Transaction({required this.id, required this.amount, required this.type});
}

// Domain: Loan
class Loan {
  final String id;
  final double amount;
  final String status;
  Loan({required this.id, required this.amount, required this.status});
}

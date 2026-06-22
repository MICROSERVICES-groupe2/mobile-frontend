import 'package:equatable/equatable.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();
  @override
  List<Object?> get props => [];
}

class LoadLoans extends LoanEvent {}

class SimulateLoanRequested extends LoanEvent {
  final double montant;
  final int dureeMois;
  const SimulateLoanRequested({required this.montant, required this.dureeMois});
  @override
  List<Object?> get props => [montant, dureeMois];
}

class RequestLoanSubmitted extends LoanEvent {
  final double montant;
  final int dureeMois;
  final String accountId;
  const RequestLoanSubmitted({required this.montant, required this.dureeMois, required this.accountId});
  @override
  List<Object?> get props => [montant, dureeMois, accountId];
}

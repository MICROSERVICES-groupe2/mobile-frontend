import 'package:equatable/equatable.dart';
import '../../../domain/entities/loan.dart';

abstract class LoanState extends Equatable {
  const LoanState();
  @override
  List<Object?> get props => [];
}

class LoanInitial extends LoanState {}

class LoanLoading extends LoanState {}

class LoansLoaded extends LoanState {
  final List<Loan> loans;
  const LoansLoaded(this.loans);
  @override
  List<Object?> get props => [loans];
}

class LoanSimulated extends LoanState {
  final Loan simulation;
  const LoanSimulated(this.simulation);
  @override
  List<Object?> get props => [simulation];
}

class LoanRequestSuccess extends LoanState {}

class LoanError extends LoanState {
  final String message;
  const LoanError(this.message);
  @override
  List<Object?> get props => [message];
}

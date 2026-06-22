import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/loan.dart';

abstract class LoanRepository {
  Future<Either<Failure, List<Loan>>> getLoans();
  Future<Either<Failure, Loan>> simulateLoan(double montant, int dureeMois);
  Future<Either<Failure, void>> requestLoan(double montant, int dureeMois, String accountId);
}

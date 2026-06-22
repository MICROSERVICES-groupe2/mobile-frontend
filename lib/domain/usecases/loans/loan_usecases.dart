import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/loan.dart';
import '../../repositories/loan_repository.dart';

class GetLoansUseCase {
  final LoanRepository repository;
  GetLoansUseCase(this.repository);

  Future<Either<Failure, List<Loan>>> execute() async {
    return await repository.getLoans();
  }
}

class SimulateLoanUseCase {
  final LoanRepository repository;
  SimulateLoanUseCase(this.repository);

  Future<Either<Failure, Loan>> execute(double montant, int dureeMois) async {
    return await repository.simulateLoan(montant, dureeMois);
  }
}

class RequestLoanUseCase {
  final LoanRepository repository;
  RequestLoanUseCase(this.repository);

  Future<Either<Failure, void>> execute(double montant, int dureeMois, String accountId) async {
    return await repository.requestLoan(montant, dureeMois, accountId);
  }
}

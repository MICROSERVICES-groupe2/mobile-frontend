import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/transaction_repository.dart';

class CreateTransferUseCase {
  final TransactionRepository repository;

  CreateTransferUseCase(this.repository);

  Future<Either<Failure, void>> execute(String sourceAccountId, String destinationAccountId, double montant, String devise) async {
    return await repository.createTransfer(sourceAccountId, destinationAccountId, montant, devise);
  }
}

class CreateDepositUseCase {
  final TransactionRepository repository;

  CreateDepositUseCase(this.repository);

  Future<Either<Failure, void>> execute(String accountId, double montant, String devise) async {
    return await repository.createDeposit(accountId, montant, devise);
  }
}

class CreateWithdrawalUseCase {
  final TransactionRepository repository;

  CreateWithdrawalUseCase(this.repository);

  Future<Either<Failure, void>> execute(String accountId, double montant, String devise) async {
    return await repository.createWithdrawal(accountId, montant, devise);
  }
}

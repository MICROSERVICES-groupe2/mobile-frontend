import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? accountId,
    String? type,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, void>> createTransfer(String sourceAccountId, String destinationAccountId, double montant, String devise);
  Future<Either<Failure, void>> createDeposit(String accountId, double montant, String devise);
  Future<Either<Failure, void>> createWithdrawal(String accountId, double montant, String devise);
}

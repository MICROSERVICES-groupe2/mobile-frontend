import 'package:dartz/dartz.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    String? accountId,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactions(
        accountId: accountId,
        type: type,
        limit: limit,
        offset: offset,
      );
      return Right(transactions);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé. Veuillez vous reconnecter.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, void>> createTransfer(String sourceAccountId, String destinationAccountId, double montant, String devise) async {
    try {
      await remoteDataSource.createTransfer(sourceAccountId, destinationAccountId, montant, devise);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé. Veuillez vous reconnecter.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, void>> createDeposit(String accountId, double montant, String devise) async {
    try {
      await remoteDataSource.createDeposit(accountId, montant, devise);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé. Veuillez vous reconnecter.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, void>> createWithdrawal(String accountId, double montant, String devise) async {
    try {
      await remoteDataSource.createWithdrawal(accountId, montant, devise);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé. Veuillez vous reconnecter.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }
}

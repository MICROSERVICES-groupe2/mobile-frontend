import 'package:dartz/dartz.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/loan_remote_datasource.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanRemoteDataSource remoteDataSource;

  LoanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Loan>>> getLoans() async {
    try {
      final loans = await remoteDataSource.getLoans();
      return Right(loans);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, Loan>> simulateLoan(double montant, int dureeMois) async {
    try {
      final loan = await remoteDataSource.simulateLoan(montant, dureeMois);
      return Right(loan);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, void>> requestLoan(double montant, int dureeMois, String accountId) async {
    try {
      await remoteDataSource.requestLoan(montant, dureeMois, accountId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }
}

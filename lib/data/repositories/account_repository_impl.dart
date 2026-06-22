import 'package:dartz/dartz.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Account>>> getAccounts({String? clientId}) async {
    try {
      final accounts = await remoteDataSource.getAccounts(clientId: clientId);
      return Right(accounts);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé. Veuillez vous reconnecter.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, Account>> getAccountDetail(String accountId) async {
    try {
      final account = await remoteDataSource.getAccountDetail(accountId);
      return Right(account);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé. Veuillez vous reconnecter.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }
}

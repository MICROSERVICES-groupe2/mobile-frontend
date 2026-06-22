import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/account.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<Account>>> getAccounts({String? clientId});
  Future<Either<Failure, Account>> getAccountDetail(String accountId);
  Future<Either<Failure, Account>> createAccount({
    required String clientId,
    required String type,
    required double solde,
    required String devise,
  });
}

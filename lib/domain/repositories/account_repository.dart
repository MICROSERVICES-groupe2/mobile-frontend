import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/account.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<Account>>> getAccounts({String? clientId});
  Future<Either<Failure, Account>> getAccountDetail(String accountId);
}

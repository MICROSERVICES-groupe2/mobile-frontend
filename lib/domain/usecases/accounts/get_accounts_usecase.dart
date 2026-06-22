import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/account.dart';
import '../../repositories/account_repository.dart';

class GetAccountsUseCase {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  Future<Either<Failure, List<Account>>> execute({String? clientId}) async {
    return await repository.getAccounts(clientId: clientId);
  }
}

class GetAccountDetailUseCase {
  final AccountRepository repository;

  GetAccountDetailUseCase(this.repository);

  Future<Either<Failure, Account>> execute(String accountId) async {
    return await repository.getAccountDetail(accountId);
  }
}

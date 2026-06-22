import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/account.dart';
import '../../repositories/account_repository.dart';

class CreateAccountUseCase {
  final AccountRepository repository;

  CreateAccountUseCase(this.repository);

  Future<Either<Failure, Account>> call({
    required String clientId,
    required String type,
    required double solde,
    required String devise,
  }) {
    return repository.createAccount(
      clientId: clientId,
      type: type,
      solde: solde,
      devise: devise,
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';

abstract class AccountEvent {}
class FetchAccounts extends AccountEvent {
  final String? clientId;
  FetchAccounts({this.clientId});
}

abstract class AccountState {}
class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}
class AccountLoaded extends AccountState {
  final List<Account> accounts;
  AccountLoaded(this.accounts);
}
class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository repository;
  AccountBloc(this.repository) : super(AccountInitial()) {
    on<FetchAccounts>((event, emit) async {
      emit(AccountLoading());
      final result = await repository.getAccounts(clientId: event.clientId);
      result.fold(
        (failure) => emit(AccountError(failure.toString())),
        (accounts) => emit(AccountLoaded(accounts)),
      );
    });
  }
}

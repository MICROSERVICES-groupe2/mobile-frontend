import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';
import '../../../domain/usecases/accounts/create_account_usecase.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class ResetAccounts extends AccountEvent {
  const ResetAccounts();
}

class FetchAccounts extends AccountEvent {
  final String? clientId;
  const FetchAccounts({this.clientId});

  @override
  List<Object?> get props => [clientId];
}

class CreateAccount extends AccountEvent {
  final String clientId;
  final String type;
  final double solde;
  final String devise;

  const CreateAccount({
    required this.clientId,
    required this.type,
    required this.solde,
    required this.devise,
  });

  @override
  List<Object?> get props => [clientId, type, solde, devise];
}

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountLoaded extends AccountState {
  final List<Account> accounts;
  const AccountLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountOperationLoading extends AccountState {
  const AccountOperationLoading();
}

class AccountOperationSuccess extends AccountState {
  final String message;
  const AccountOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountOperationError extends AccountState {
  final String message;
  const AccountOperationError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository repository;
  final CreateAccountUseCase? createAccountUseCase;

  AccountBloc(this.repository, {this.createAccountUseCase})
      : super(const AccountInitial()) {
    on<ResetAccounts>((event, emit) => emit(const AccountInitial()));
    on<FetchAccounts>((event, emit) async {
      emit(const AccountLoading());
      final result = await repository.getAccounts(clientId: event.clientId);
      result.fold(
        (failure) => emit(AccountError(failure.toString())),
        (accounts) => emit(AccountLoaded(accounts)),
      );
    });

    on<CreateAccount>((event, emit) async {
      emit(const AccountOperationLoading());
      final result = await createAccountUseCase!.call(
        clientId: event.clientId,
        type: event.type,
        solde: event.solde,
        devise: event.devise,
      );
      result.fold(
        (failure) => emit(AccountOperationError(failure.toString())),
        (account) {
          emit(const AccountOperationSuccess('Compte créé avec succès'));
          refreshAccounts(emit, event.clientId);
        },
      );
    });
  }

  void refreshAccounts(Emitter<AccountState> emit, String? clientId) {
    repository.getAccounts(clientId: clientId).then((result) {
      result.fold(
        (failure) => emit(AccountError(failure.toString())),
        (accounts) => emit(AccountLoaded(accounts)),
      );
    });
  }
}

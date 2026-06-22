import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/transactions/create_transfer_usecase.dart';
import '../../../domain/usecases/transactions/get_transactions_usecase.dart';

abstract class TransactionEvent {}

class ResetTransactions extends TransactionEvent {}

class FetchTransactions extends TransactionEvent {
  final String? accountId;
  final String? type;
  final int? limit;
  final int? offset;

  FetchTransactions({
    this.accountId,
    this.type,
    this.limit,
    this.offset,
  });
}

class CreateTransfer extends TransactionEvent {
  final String sourceAccountId;
  final String destinationAccountId;
  final double montant;
  final String devise;

  CreateTransfer({
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.montant,
    required this.devise,
  });
}

class CreateDeposit extends TransactionEvent {
  final String accountId;
  final double montant;
  final String devise;

  CreateDeposit({
    required this.accountId,
    required this.montant,
    required this.devise,
  });
}

class CreateWithdrawal extends TransactionEvent {
  final String accountId;
  final double montant;
  final String devise;

  CreateWithdrawal({
    required this.accountId,
    required this.montant,
    required this.devise,
  });
}

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<Transaction> transactions;
  final bool hasMore;

  TransactionsLoaded(this.transactions, {this.hasMore = false});
}

class TransactionOperationSuccess extends TransactionState {
  final String message;
  TransactionOperationSuccess(this.message);
}

class TransactionError extends TransactionState {
  final String message;
  TransactionError(this.message);
}

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final CreateTransferUseCase createTransferUseCase;
  final CreateDepositUseCase createDepositUseCase;
  final CreateWithdrawalUseCase createWithdrawalUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.createTransferUseCase,
    required this.createDepositUseCase,
    required this.createWithdrawalUseCase,
  }) : super(TransactionInitial()) {
    on<ResetTransactions>((event, emit) => emit(TransactionInitial()));
    on<FetchTransactions>(_onFetchTransactions);
    on<CreateTransfer>(_onCreateTransfer);
    on<CreateDeposit>(_onCreateDeposit);
    on<CreateWithdrawal>(_onCreateWithdrawal);
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactionsUseCase.execute(
      accountId: event.accountId,
      type: event.type,
      limit: event.limit,
      offset: event.offset,
    );
    result.fold(
      (failure) => emit(TransactionError(failure.toString())),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }

  Future<void> _onCreateTransfer(
    CreateTransfer event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await createTransferUseCase.execute(
      event.sourceAccountId,
      event.destinationAccountId,
      event.montant,
      event.devise,
    );
    await result.fold(
      (failure) async => emit(TransactionError(failure.toString())),
      (_) async {
        emit(TransactionOperationSuccess('Transfert effectué avec succès'));
        final refreshResult = await getTransactionsUseCase.execute(
          accountId: event.sourceAccountId,
          limit: 20,
        );
        refreshResult.fold(
          (f) => emit(TransactionError(f.toString())),
          (txs) => emit(TransactionsLoaded(txs)),
        );
      },
    );
  }

  Future<void> _onCreateDeposit(
    CreateDeposit event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await createDepositUseCase.execute(
      event.accountId,
      event.montant,
      event.devise,
    );
    await result.fold(
      (failure) async => emit(TransactionError(failure.toString())),
      (_) async {
        emit(TransactionOperationSuccess('Dépôt effectué avec succès'));
        final refreshResult = await getTransactionsUseCase.execute(
          accountId: event.accountId,
          limit: 20,
        );
        refreshResult.fold(
          (f) => emit(TransactionError(f.toString())),
          (txs) => emit(TransactionsLoaded(txs)),
        );
      },
    );
  }

  Future<void> _onCreateWithdrawal(
    CreateWithdrawal event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await createWithdrawalUseCase.execute(
      event.accountId,
      event.montant,
      event.devise,
    );
    await result.fold(
      (failure) async => emit(TransactionError(failure.toString())),
      (_) async {
        emit(TransactionOperationSuccess('Paiement effectué avec succès'));
        final refreshResult = await getTransactionsUseCase.execute(
          accountId: event.accountId,
          limit: 20,
        );
        refreshResult.fold(
          (f) => emit(TransactionError(f.toString())),
          (txs) => emit(TransactionsLoaded(txs)),
        );
      },
    );
  }
}

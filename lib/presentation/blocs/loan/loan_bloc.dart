import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/loans/loan_usecases.dart';
import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final GetLoansUseCase getLoansUseCase;
  final SimulateLoanUseCase simulateLoanUseCase;
  final RequestLoanUseCase requestLoanUseCase;

  LoanBloc({
    required this.getLoansUseCase,
    required this.simulateLoanUseCase,
    required this.requestLoanUseCase,
  }) : super(LoanInitial()) {
    on<LoadLoans>(_onLoadLoans);
    on<SimulateLoanRequested>(_onSimulateLoan);
    on<RequestLoanSubmitted>(_onRequestLoan);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    final result = await getLoansUseCase.execute();
    result.fold(
      (failure) => emit(LoanError(failure.message)),
      (loans) => emit(LoansLoaded(loans)),
    );
  }

  Future<void> _onSimulateLoan(SimulateLoanRequested event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    final result = await simulateLoanUseCase.execute(event.montant, event.dureeMois);
    result.fold(
      (failure) => emit(LoanError(failure.message)),
      (simulation) => emit(LoanSimulated(simulation)),
    );
  }

  Future<void> _onRequestLoan(RequestLoanSubmitted event, Emitter<LoanState> emit) async {
    emit(LoanLoading());
    final result = await requestLoanUseCase.execute(event.montant, event.dureeMois, event.accountId);
    result.fold(
      (failure) => emit(LoanError(failure.message)),
      (_) => emit(LoanRequestSuccess()),
    );
  }
}

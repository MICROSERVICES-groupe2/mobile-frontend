import 'package:get_it/get_it.dart';
import 'core/storage/secure_storage.dart';
import 'core/network/dio_client.dart';
import 'core/notifications/notification_service.dart';
import 'data/services/document_service.dart';

// BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/accounts/account_bloc.dart';
import 'presentation/blocs/loan/loan_bloc.dart';
import 'presentation/blocs/notification/notification_bloc.dart';
import 'presentation/blocs/transactions/transaction_bloc.dart';

// Use cases
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/update_profile_picture_usecase.dart';
import 'domain/usecases/auth/verify_2fa_usecase.dart';
import 'domain/usecases/auth/verify_registration_otp_usecase.dart';
import 'domain/usecases/auth/login_with_biometrics_usecase.dart';
import 'domain/usecases/loans/loan_usecases.dart';
import 'domain/usecases/notifications/notification_usecases.dart';
import 'domain/usecases/transactions/get_transactions_usecase.dart';
import 'domain/usecases/transactions/create_transfer_usecase.dart';

// Repositories
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/loan_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/repositories/transaction_repository.dart';

// Repository Implementations
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/account_repository_impl.dart';
import 'data/repositories/loan_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';

// Data Sources
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/account_remote_datasource.dart';
import 'data/datasources/loan_remote_datasource.dart';
import 'data/datasources/notification_remote_datasource.dart';
import 'data/datasources/transaction_remote_datasource.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // BLoCs
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        verifyRegistrationOtpUseCase: sl(),
        updateProfilePictureUseCase: sl(),
        logoutUseCase: sl(),
        verify2faUseCase: sl(),
        loginWithBiometricsUseCase: sl(),
      ));
  sl.registerFactory(() => AccountBloc(sl()));
  sl.registerFactory(() => TransactionBloc(
        getTransactionsUseCase: sl(),
        createTransferUseCase: sl(),
        createDepositUseCase: sl(),
        createWithdrawalUseCase: sl(),
      ));
  sl.registerFactory(() => LoanBloc(
        getLoansUseCase: sl(),
        simulateLoanUseCase: sl(),
        requestLoanUseCase: sl(),
      ));
  sl.registerFactory(() => NotificationBloc(
        getNotificationsUseCase: sl(),
        markNotificationReadUseCase: sl(),
        getUnreadCountUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePictureUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => Verify2FAUseCase(sl()));
  sl.registerLazySingleton(() => VerifyRegistrationOtpUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithBiometricsUseCase(sl()));
  sl.registerLazySingleton(() => GetLoansUseCase(sl()));
  sl.registerLazySingleton(() => SimulateLoanUseCase(sl()));
  sl.registerLazySingleton(() => RequestLoanUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => CreateTransferUseCase(sl()));
  sl.registerLazySingleton(() => CreateDepositUseCase(sl()));
  sl.registerLazySingleton(() => CreateWithdrawalUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), secureStorage: sl()));
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<LoanRepository>(() => LoanRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(remoteDataSource: sl()));

  // Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<AccountRemoteDataSource>(() => AccountRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<LoanRemoteDataSource>(() => LoanRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<TransactionRemoteDataSource>(() => TransactionRemoteDataSourceImpl(dioClient: sl()));

  // Services
  sl.registerLazySingleton(() => DocumentService(dio: sl()));
  sl.registerLazySingleton(() => NotificationService());

  // External
  sl.registerLazySingleton(() => SecureStorage());
  sl.registerLazySingleton(() => DioClient(secureStorage: sl()));
  sl.registerLazySingleton(() => sl<DioClient>().dio);
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/storage/secure_storage.dart';
import 'injection_container.dart' as di;

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/loan/loan_bloc.dart';
import 'presentation/blocs/notification/notification_bloc.dart';
import 'presentation/blocs/accounts/account_bloc.dart';
import 'presentation/blocs/transactions/transaction_bloc.dart';
import 'domain/entities/transaction.dart';

import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/two_fa_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/register_otp_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/loans/loans_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/transactions/transactions_screen.dart';
import 'presentation/screens/transactions/transaction_detail_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';
import 'presentation/screens/transfer/transfer_screen.dart';
import 'presentation/screens/deposit/deposit_screen.dart';
import 'presentation/screens/payments/payments_screen.dart';
import 'presentation/screens/activity/activity_screen.dart';

class BankPlatformApp extends StatelessWidget {
  const BankPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
          routes: [
            GoRoute(
              path: '2fa',
              builder: (context, state) => const TwoFAScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
          routes: [
            GoRoute(
              path: 'otp',
              builder: (context, state) {
                final extra = state.extra;
                final email = extra is Map<String, dynamic>
                    ? (extra['email'] as String? ?? '')
                    : (extra as String? ?? '');
                final userId = extra is Map<String, dynamic>
                    ? (extra['userId'] as String? ?? '')
                    : '';
                final otp = extra is Map<String, dynamic>
                    ? (extra['otp'] as String?)
                    : null;
                return RegisterOtpScreen(userId: userId, email: email, otp: otp);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/loans',
          builder: (context, state) => BlocProvider(
            create: (_) => di.sl<LoanBloc>(),
            child: const LoansScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const TransactionsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final transactionId = state.pathParameters['id'] ?? '';
                final transaction = state.extra as Transaction?;
                return TransactionDetailScreen(
                  transactionId: transactionId,
                  transaction: transaction,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/transfer',
          builder: (context, state) => const TransferScreen(),
        ),
        GoRoute(
          path: '/deposit',
          builder: (context, state) => const DepositScreen(),
        ),
        GoRoute(
          path: '/payments',
          builder: (context, state) => const PaymentsScreen(),
        ),
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) async {
        final secureStorage = di.sl<SecureStorage>();
        final token = await secureStorage.getToken();
        final isAuth = token != null && token.isNotEmpty;

        final loc = state.matchedLocation;
        final isSplash = loc == '/';
        final isPublic = loc == '/login' ||
            loc == '/login/2fa' ||
            loc == '/register' ||
            loc == '/register/otp';

        if (isSplash) {
          await Future.delayed(const Duration(seconds: 2));
          return isAuth ? '/dashboard' : '/login';
        }

        // Redirect unauthenticated users to login for all protected routes
        if (!isAuth && !isPublic) {
          return '/login';
        }

        // Already logged in → don't stay on login page
        if (isAuth && (loc == '/login' || loc == '/login/2fa')) {
          return '/dashboard';
        }

        return null;
      },
    );

    return ThemeProvider(
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
              BlocProvider<AccountBloc>(create: (_) => di.sl<AccountBloc>()),
              BlocProvider<TransactionBloc>(create: (_) => di.sl<TransactionBloc>()),
              BlocProvider<NotificationBloc>(create: (_) => di.sl<NotificationBloc>()),
            ],
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  router.go('/login');
                }
              },
              child: MaterialApp.router(
                title: 'Bank App',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.dark,
                routerConfig: router,
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        },
      ),
    );
  }
}

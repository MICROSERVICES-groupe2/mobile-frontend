import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/transaction.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../blocs/transactions/transaction_bloc.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/glass_container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final clientId = user?.clientId;
    final userId = user?.id;

    context.read<AccountBloc>().add(FetchAccounts(clientId: clientId));
    context.read<NotificationBloc>().add(LoadNotifications(userId: userId));
  }

  void _refreshDashboardData() {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final clientId = user?.clientId;

    context.read<AccountBloc>().add(FetchAccounts(clientId: clientId));

    final accountState = context.read<AccountBloc>().state;
    if (accountState is AccountLoaded && accountState.accounts.isNotEmpty) {
      context.read<TransactionBloc>().add(
        FetchTransactions(
          accountId: accountState.accounts.first.id,
          limit: 5,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountLoaded && state.accounts.isNotEmpty) {
              context.read<TransactionBloc>().add(
                FetchTransactions(
                  accountId: state.accounts.first.id,
                  limit: 5,
                ),
              );
            }
          },
        ),
        BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionOperationSuccess) {
              _refreshDashboardData();
            }
          },
        ),
      ],
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  String _maskAccountNumber(String accountId) {
    final last4 = accountId.length >= 4 ? accountId.substring(accountId.length - 4) : accountId;
    return '**** $last4';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  IconData _transactionIcon(String type) {
    switch (type) {
      case 'DEPOSIT':
        return Icons.arrow_downward;
      case 'WITHDRAW':
      case 'TRANSFER_OUT':
        return Icons.arrow_upward;
      case 'TRANSFER_IN':
        return Icons.swap_horiz;
      default:
        return Icons.payments;
    }
  }

  Color _transactionColor(String type) {
    switch (type) {
      case 'DEPOSIT':
      case 'TRANSFER_IN':
        return DesignTokens.success;
      case 'WITHDRAW':
      case 'TRANSFER_OUT':
        return DesignTokens.error;
      default:
        return DesignTokens.teal300;
    }
  }

  String _transactionLabel(String type) {
    switch (type) {
      case 'DEPOSIT':
        return 'Dépôt';
      case 'WITHDRAW':
        return 'Retrait';
      case 'TRANSFER_IN':
        return 'Virement reçu';
      case 'TRANSFER_OUT':
        return 'Virement envoyé';
      default:
        return 'Transaction';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppLogo(size: 32, textSize: 0, showText: false),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final user = state is AuthAuthenticated ? state.user : null;
                      final displayName = user != null
                          ? (user.prenom?.isNotEmpty == true ? '${user.prenom} ${user.nom}' : user.nom)
                          : 'Utilisateur';
                      final avatarUrl = user?.avatarUrl;

                      return Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Bienvenue,',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: DesignTokens.teal500,
                            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null || avatarUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.go('/notifications'),
                            child: BlocBuilder<NotificationBloc, NotificationState>(
                              builder: (context, state) {
                                final unreadCount = state is NotificationsLoaded ? state.unreadCount : 0;
                                return Stack(
                                  children: [
                                    Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                    if (unreadCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: DesignTokens.error,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Balance card
              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  Account? account;
                  if (state is AccountLoaded && state.accounts.isNotEmpty) {
                    account = state.accounts.first;
                  }

                  final balanceText = account != null
                      ? '${account.devise} ${account.solde.toStringAsFixed(2)}'
                      : '---';
                  final numero = account != null
                      ? _maskAccountNumber(account.id)
                      : '**** ----';
                  final typeLabel = account != null ? _accountTypeLabel(account.type) : 'Compte';
                  final statusLabel = account != null ? account.statut : '---';

                  return GlassContainer(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              typeLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: DesignTokens.teal300.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusLabel,
                                style: const TextStyle(
                                  color: DesignTokens.teal300,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Solde du compte',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          balanceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Disponible: $balanceText • Mis à jour à l\'instant',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              numero,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '06/27',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Quick actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAction(
                    icon: Icons.swap_horiz,
                    label: 'Transfert',
                    onTap: () => context.go('/transfer'),
                  ),
                  _QuickAction(
                    icon: Icons.receipt_long,
                    label: 'Paiement',
                    onTap: () => context.go('/payments'),
                  ),
                  _QuickAction(
                    icon: Icons.add_circle_outline,
                    label: 'Dépôt',
                    onTap: () => context.go('/deposit'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent transactions
              GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transactions récentes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/transactions'),
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(
                              color: DesignTokens.teal300,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        if (state is TransactionLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is TransactionError) {
                          return Text(
                            'Erreur: ${state.message}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          );
                        }
                        if (state is TransactionsLoaded) {
                          if (state.transactions.isEmpty) {
                            return Text(
                              'Aucune transaction récente',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                            );
                          }
                          return Column(
                            children: state.transactions.asMap().entries.map((entry) {
                              return _TransactionRow(
                                index: entry.key + 1,
                                transaction: entry.value,
                                formatDate: _formatDate,
                                icon: _transactionIcon,
                                color: _transactionColor,
                                label: _transactionLabel,
                              );
                            }).toList(),
                          );
                        }
                        return Text(
                          'Chargement...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: DesignTokens.navy800.withValues(alpha: 0.95),
        selectedItemColor: DesignTokens.teal300,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Activité'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/transactions');
          if (index == 2) context.go('/activity');
          if (index == 3) context.go('/profile');
        },
      ),
    );
  }

  String _accountTypeLabel(String type) {
    switch (type) {
      case 'COURANT':
        return 'Compte courant';
      case 'EPARGNE':
        return 'Compte épargne';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      default:
        return 'Compte';
    }
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: DesignTokens.tealGradient,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.tealGlow.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: DesignTokens.navy900, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final int index;
  final Transaction transaction;
  final String Function(DateTime) formatDate;
  final IconData Function(String) icon;
  final Color Function(String) color;
  final String Function(String) label;

  const _TransactionRow({
    required this.index,
    required this.transaction,
    required this.formatDate,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.type == 'DEPOSIT' || transaction.type == 'TRANSFER_IN';
    final amountText = '${isPositive ? '+' : '-'} ${transaction.devise} ${transaction.montant.abs().toStringAsFixed(2)}';
    final amountColor = isPositive ? DesignTokens.success : DesignTokens.error;
    final iconColor = color(transaction.type);

    return GestureDetector(
      onTap: () => context.push('/transactions/${transaction.id}', extra: transaction),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              '$index.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon(transaction.type), color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label(transaction.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(transaction.timestamp),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                color: amountColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

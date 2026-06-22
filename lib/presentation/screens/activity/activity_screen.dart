import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/transaction.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/transactions/transaction_bloc.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/glass_container.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  Account? _selectedAccount;
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final clientId = user?.clientId;
    context.read<AccountBloc>().add(FetchAccounts(clientId: clientId));
  }

  void _onAccountSelected(Account account) {
    if (account.id != _selectedAccount?.id) {
      setState(() => _selectedAccount = account);
      context.read<TransactionBloc>().add(FetchTransactions(accountId: account.id));
    }
  }

  String _accountTypeLabel(String type) {
    switch (type) {
      case 'COURANT':
        return 'Compte Courant';
      case 'EPARGNE':
        return 'Compte Épargne';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      default:
        return 'Compte';
    }
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'EPARGNE':
        return Icons.savings_outlined;
      case 'MOBILE_MONEY':
        return Icons.phone_android;
      default:
        return Icons.account_balance_outlined;
    }
  }

  Color _accountColor(String type) {
    switch (type) {
      case 'EPARGNE':
        return Colors.blue;
      case 'MOBILE_MONEY':
        return Colors.orange;
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AccountBloc, AccountState>(
            listener: (context, state) {
              if (state is AccountLoaded && state.accounts.isNotEmpty) {
                _accounts = state.accounts;
                if (_selectedAccount == null || !_accounts.any((a) => a.id == _selectedAccount!.id)) {
                  _selectedAccount = _accounts.first;
                  context.read<TransactionBloc>().add(FetchTransactions(accountId: _selectedAccount!.id));
                }
              }
            },
          ),
        ],
        child: Stack(
          children: [
            const AnimatedBackground(child: SizedBox.shrink()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activité & Analyses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Account carousel ──
                    BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, state) {
                        if (state is AccountLoaded && _accounts.isNotEmpty) {
                          return SizedBox(
                            height: 140,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _accounts.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final account = _accounts[index];
                                final isSelected = account.id == _selectedAccount?.id;
                                final accentColor = _accountColor(account.type);
                                return GestureDetector(
                                  onTap: () => _onAccountSelected(account),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 200,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSelected
                                            ? [accentColor.withValues(alpha: 0.25), accentColor.withValues(alpha: 0.08)]
                                            : [DesignTokens.navy700.withValues(alpha: 0.6), DesignTokens.navy700.withValues(alpha: 0.4)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? accentColor.withValues(alpha: 0.7) : DesignTokens.glassBorder,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [BoxShadow(color: accentColor.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
                                          : [],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: accentColor.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(_accountIcon(account.type), color: accentColor, size: 18),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                _accountTypeLabel(account.type),
                                                style: TextStyle(
                                                  color: isSelected ? Colors.white : Colors.white70,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${account.devise} ${account.solde.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSelected ? 22 : 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '•••• ${account.id.length >= 4 ? account.id.substring(account.id.length - 4) : account.id}',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.45),
                                                fontSize: 11,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (isSelected)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: DesignTokens.teal300,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Statistics & Analysis ──
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        double totalIncome = 0.0;
                        double totalExpenses = 0.0;
                        double balance = 0.0;
                        List<Transaction> transactions = [];

                        if (state is TransactionsLoaded) {
                          transactions = state.transactions;
                          for (var tx in transactions) {
                            if (tx.type == 'DEPOSIT' || tx.type == 'TRANSFER_IN') {
                              totalIncome += tx.montant.abs();
                            } else {
                              totalExpenses += tx.montant.abs();
                            }
                          }
                          balance = totalIncome - totalExpenses;
                        }

                        final String currency = _selectedAccount?.devise ?? 'XAF';

                        if (state is TransactionLoading && transactions.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.0),
                              child: CircularProgressIndicator(color: DesignTokens.teal300),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header: selected account info ──
                            if (_selectedAccount != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _accountColor(_selectedAccount!.type).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_accountIcon(_selectedAccount!.type), size: 14, color: _accountColor(_selectedAccount!.type)),
                                          const SizedBox(width: 6),
                                          Text(
                                            _accountTypeLabel(_selectedAccount!.type),
                                            style: TextStyle(
                                              color: _accountColor(_selectedAccount!.type),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Solde: $currency ${_selectedAccount!.solde.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ── Income / Expenses Stats ──
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'Revenus',
                                    amount: totalIncome,
                                    currency: currency,
                                    color: DesignTokens.success,
                                    icon: Icons.arrow_downward,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Dépenses',
                                    amount: totalExpenses,
                                    currency: currency,
                                    color: DesignTokens.error,
                                    icon: Icons.arrow_upward,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Résultat net',
                                    amount: balance,
                                    currency: currency,
                                    color: balance >= 0 ? DesignTokens.success : DesignTokens.error,
                                    icon: balance >= 0 ? Icons.trending_up : Icons.trending_down,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ── Monthly ratio ──
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Ratio mensuel',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (totalIncome > 0 || totalExpenses > 0)
                                        Text(
                                          '${balance >= 0 ? '+' : ''}${balance.toStringAsFixed(0)} $currency',
                                          style: TextStyle(
                                            color: balance >= 0 ? DesignTokens.success : DesignTokens.error,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _ProgressBarChart(income: totalIncome, expenses: totalExpenses),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Analysis details ──
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Analyse par compte',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildAnalysisRow('Total revenus', totalIncome, currency, DesignTokens.success),
                                  const SizedBox(height: 10),
                                  _buildAnalysisRow('Total dépenses', totalExpenses, currency, DesignTokens.error),
                                  const SizedBox(height: 10),
                                  _buildAnalysisRow('Transactions', transactions.length.toDouble(), '', null,
                                      isCount: true),
                                  if (totalIncome > 0) ...[
                                    const SizedBox(height: 10),
                                    _buildAnalysisRow(
                                      "Taux d'épargne",
                                      totalIncome > 0 ? (balance / totalIncome * 100) : 0,
                                      '%',
                                      DesignTokens.teal300,
                                      isPercent: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Transaction list ──
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Historique de la période',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (transactions.isEmpty)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24.0),
                                        child: Text(
                                          'Aucune transaction sur ce compte',
                                          style: TextStyle(color: Colors.white60, fontSize: 13),
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: transactions.length,
                                      separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.08)),
                                      itemBuilder: (context, index) {
                                        final tx = transactions[index];
                                        final isIncome = tx.type == 'DEPOSIT' || tx.type == 'TRANSFER_IN';

                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: (isIncome ? DesignTokens.success : DesignTokens.error).withValues(alpha: 0.15),
                                            child: Icon(
                                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                              color: isIncome ? DesignTokens.success : DesignTokens.error,
                                              size: 18,
                                            ),
                                          ),
                                          title: Text(
                                            _transactionLabel(tx.type),
                                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            _formatDate(tx.timestamp),
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                          ),
                                          trailing: Text(
                                            '${isIncome ? '+' : '-'} ${tx.montant.abs().toStringAsFixed(2)} ${tx.devise}',
                                            style: TextStyle(
                                              color: isIncome ? DesignTokens.success : DesignTokens.error,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: DesignTokens.navy800.withValues(alpha: 0.95),
        selectedItemColor: DesignTokens.teal300,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Prêts'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Activité'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/transactions');
          if (index == 2) context.go('/loans');
          if (index == 3) context.go('/activity');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildAnalysisRow(String label, double value, String suffix, Color? color, {bool isCount = false, bool isPercent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        Text(
          isCount ? value.toInt().toString()
              : isPercent ? '${value.toStringAsFixed(1)}$suffix'
              : '${value.toStringAsFixed(2)} $suffix',
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 12),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${amount.toStringAsFixed(0)} $currency',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProgressBarChart extends StatelessWidget {
  final double income;
  final double expenses;

  const _ProgressBarChart({
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expenses;
    final double incomePercent = total > 0 ? income / total : 0.5;
    final double expensesPercent = total > 0 ? expenses / total : 0.5;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (incomePercent > 0)
                  Expanded(
                    flex: (incomePercent * 100).round().clamp(1, 100),
                    child: Container(color: DesignTokens.success),
                  ),
                if (expensesPercent > 0)
                  Expanded(
                    flex: (expensesPercent * 100).round().clamp(1, 100),
                    child: Container(color: DesignTokens.error),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Revenus (${(incomePercent * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(color: DesignTokens.success, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              'Dépenses (${(expensesPercent * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(color: DesignTokens.error, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

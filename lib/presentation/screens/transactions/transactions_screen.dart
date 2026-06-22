import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/transactions/transaction_bloc.dart';
import '../../widgets/transaction_tile.dart';
import '../../../domain/entities/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    final clientId = authState is AuthAuthenticated ? authState.user.clientId : null;
    context.read<AccountBloc>().add(FetchAccounts(clientId: clientId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _filterTransactions(List<Transaction> all) {
    return all.where((tx) {
      final matchesFilter = _selectedFilter == 'ALL' || tx.type == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          (tx.description ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.type.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Transactions'),
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AccountBloc, AccountState>(
            listener: (context, accountState) {
              if (accountState is AccountLoaded && accountState.accounts.isNotEmpty) {
                context.read<TransactionBloc>().add(
                  FetchTransactions(accountId: accountState.accounts.first.id),
                );
              }
            },
          ),
          BlocListener<TransactionBloc, TransactionState>(
            listener: (context, txState) {
              if (txState is TransactionOperationSuccess) {
                _loadData();
              }
            },
          ),
        ],
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, accountState) {
            if (accountState is AccountInitial || accountState is AccountLoading) {
              return const Center(
                child: CircularProgressIndicator(color: DesignTokens.teal300),
              );
            }

            if (accountState is AccountError) {
              return _buildError(accountState.message);
            }

            if (accountState is AccountLoaded && accountState.accounts.isEmpty) {
              return _buildEmpty('Aucun compte trouvé.');
            }

            return BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, txState) {
                if (txState is TransactionInitial || txState is TransactionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: DesignTokens.teal300),
                  );
                }

                if (txState is TransactionError) {
                  return _buildError(txState.message, onRetry: () {
                    final accounts = (accountState as AccountLoaded).accounts;
                    if (accounts.isNotEmpty) {
                      context.read<TransactionBloc>().add(
                        FetchTransactions(accountId: accounts.first.id),
                      );
                    }
                  });
                }

                final allTx =
                    txState is TransactionsLoaded ? txState.transactions : <Transaction>[];
                final filtered = _filterTransactions(allTx);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une transaction...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }),
                                )
                              : null,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          filled: true,
                          fillColor: DesignTokens.glassWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: DesignTokens.glassBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: DesignTokens.glassBorder),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(color: DesignTokens.teal300, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _buildFilterChip('Tous', 'ALL'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Transferts', 'TRANSFER'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Dépôts', 'DEPOSIT'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Retraits', 'WITHDRAWAL'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmpty('Aucune transaction trouvée')
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return TransactionTile(
                                  transaction: filtered[index],
                                  onTap: () =>
                                      _showTransactionDetails(context, filtered[index]),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

  Widget _buildError(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = value);
      },
      selectedColor: DesignTokens.teal500.withValues(alpha: 0.2),
      disabledColor: Colors.transparent,
      backgroundColor: DesignTokens.glassWhite,
      checkmarkColor: DesignTokens.teal300,
      labelStyle: TextStyle(
        color: isSelected ? DesignTokens.teal300 : Colors.white.withValues(alpha: 0.7),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? DesignTokens.teal300 : DesignTokens.glassBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DesignTokens.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Détail de la transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _detailRow('Description', transaction.description ?? '-'),
              _detailRow('Type', transaction.type),
              _detailRow('Montant', '${transaction.montant} ${transaction.devise}'),
              _detailRow('Statut', transaction.statut, isStatus: true),
              _detailRow(
                  'Date', transaction.timestamp.toLocal().toString().split('.')[0]),
              _detailRow('ID', transaction.id),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {bool isStatus = false}) {
    Color? valueColor;
    if (isStatus) {
      valueColor = value == 'COMPLETED' ? DesignTokens.success : Colors.orange;
    } else {
      valueColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: valueColor, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

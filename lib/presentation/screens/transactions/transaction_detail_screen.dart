import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../../domain/entities/transaction.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/common/glass_container.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;
  final Transaction? transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    this.transaction,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
  }

  String _transactionTypeLabel(String type) {
    switch (type) {
      case 'DEPOSIT':
        return 'Dépôt effectué';
      case 'WITHDRAW':
        return 'Paiement effectué';
      case 'TRANSFER_IN':
        return 'Virement reçu';
      case 'TRANSFER_OUT':
        return 'Virement envoyé';
      default:
        return 'Transaction';
    }
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

  @override
  Widget build(BuildContext context) {
    // If transaction is null, we can build a fallback default transaction for presentation purposes
    final tx = transaction ??
        Transaction(
          id: transactionId,
          accountId: 'ACC-XXXX',
          type: 'TRANSFER_OUT',
          montant: 0.0,
          devise: '€',
          statut: 'COMPLETED',
          timestamp: DateTime.now(),
          description: 'Détails non chargés',
        );

    final isPositive = tx.type == 'DEPOSIT' || tx.type == 'TRANSFER_IN';
    final amountText = '${isPositive ? '+' : '-'} ${tx.devise} ${tx.montant.abs().toStringAsFixed(2)}';
    final themeColor = _transactionColor(tx.type);

    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      body: Stack(
        children: [
          const AnimatedBackground(child: SizedBox.shrink()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/transactions');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reçu de transaction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Glass receipt container
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: themeColor.withValues(alpha: 0.15),
                          child: Icon(
                            _transactionIcon(tx.type),
                            color: themeColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _transactionTypeLabel(tx.type),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Amount
                        Text(
                          amountText,
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: DesignTokens.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline, color: DesignTokens.success, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Succès',
                                style: TextStyle(
                                  color: DesignTokens.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Details list
                        _ReceiptRow(
                          label: 'Compte ID',
                          value: tx.accountId,
                        ),
                        _ReceiptRow(
                          label: 'Date & Heure',
                          value: _formatDate(tx.timestamp),
                        ),
                        _ReceiptRow(
                          label: 'Description / Motif',
                          value: tx.description?.isNotEmpty == true ? tx.description! : 'Aucun motif renseigné',
                        ),
                        _ReceiptRow(
                          label: 'Référence transaction',
                          value: tx.id,
                          isReference: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  GlassButton(
                    text: 'Partager le reçu',
                    icon: const Icon(Icons.share, size: 18),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Partage simulé avec succès !'),
                          backgroundColor: DesignTokens.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  GlassButton(
                    text: 'Retour aux transactions',
                    isSecondary: true,
                    onPressed: () => context.go('/transactions'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isReference;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isReference = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isReference)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID transaction copié !'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.copy, color: DesignTokens.teal300, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Copier',
                        style: TextStyle(
                          color: DesignTokens.teal300,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
        ],
      ),
    );
  }
}

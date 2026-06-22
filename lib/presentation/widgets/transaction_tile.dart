import 'package:flutter/material.dart';
import '../../../domain/entities/transaction.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../design_tokens/design_tokens.dart';
import '../../../core/theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData iconData;
    Color iconColor;
    Color amountColor;
    String prefix;

    switch (transaction.type) {
      case 'DEPOSIT':
        iconData = Icons.arrow_downward;
        iconColor = AppTheme.secondaryColor;
        amountColor = AppTheme.secondaryColor;
        prefix = '+';
        break;
      case 'WITHDRAWAL':
        iconData = Icons.arrow_upward;
        iconColor = AppTheme.errorColor;
        amountColor = AppTheme.errorColor;
        prefix = '-';
        break;
      case 'TRANSFER':
      default:
        iconData = Icons.swap_horiz;
        iconColor = isDark ? DesignTokens.primary : Colors.blue;
        amountColor = isDark ? AppTheme.errorColor : Colors.black87;
        prefix = '-';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: isDark
          ? BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.darkBorder.withValues(alpha: 0.5)),
            )
          : null,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.12 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: isDark
                ? Border.all(color: iconColor.withValues(alpha: 0.2))
                : null,
          ),
          child: Icon(iconData, color: iconColor, size: 22),
        ),
        title: Text(
          transaction.description ?? transaction.type,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormatter.formatRelative(transaction.timestamp),
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$prefix${CurrencyFormatter.format(transaction.montant, symbol: transaction.devise)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: amountColor,
                fontSize: 15,
              ),
            ),
            if (transaction.statut != 'COMPLETED')
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: transaction.statut == 'FAILED'
                      ? AppTheme.errorColor.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  transaction.statut,
                  style: TextStyle(
                    color: transaction.statut == 'FAILED' ? AppTheme.errorColor : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

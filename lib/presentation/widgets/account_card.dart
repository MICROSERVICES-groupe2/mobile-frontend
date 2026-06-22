import 'package:flutter/material.dart';
import '../../../domain/entities/account.dart';
import '../../../core/utils/currency_formatter.dart';

import '../../design_tokens/design_tokens.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Gradient colors per account type ──
    Color gradientStart;
    Color gradientEnd;
    Color borderAccent;

    if (isDark) {
      // Dark theme: navy cards with emerald accent borders (matching mockup)
      switch (account.type) {
        case 'EPARGNE':
          gradientStart = DesignTokens.surfaceDark;
          gradientEnd = DesignTokens.surfaceDark;
          borderAccent = DesignTokens.primary; // Primary accent
          break;
        case 'MOBILE_MONEY':
          gradientStart = DesignTokens.surfaceDark;
          gradientEnd = DesignTokens.surfaceDark;
          borderAccent = DesignTokens.warning; // Warning accent
          break;
        case 'COURANT':
        default:
          gradientStart = DesignTokens.surfaceDark;
          gradientEnd = DesignTokens.surfaceDark;
          borderAccent = DesignTokens.success; // Success accent
          break;
      }
    } else {
      // Light theme: vibrant gradients
      switch (account.type) {
        case 'EPARGNE':
          gradientStart = Colors.blue.shade700;
          gradientEnd = Colors.blue.shade400;
          borderAccent = Colors.blue.shade300;
          break;
        case 'MOBILE_MONEY':
          gradientStart = Colors.orange.shade700;
          gradientEnd = Colors.orange.shade400;
          borderAccent = Colors.orange.shade300;
          break;
        case 'COURANT':
        default:
          gradientStart = Colors.green.shade700;
          gradientEnd = Colors.green.shade400;
          borderAccent = Colors.green.shade300;
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isDark
            ? BorderSide(color: borderAccent.withValues(alpha: 0.4), width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: isDark ? 0 : 4,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Type + Status badge ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getAccountLabel(account.type),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? borderAccent.withValues(alpha: 0.15)
                          : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark
                          ? Border.all(color: borderAccent.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Text(
                      account.statut,
                      style: TextStyle(
                        color: isDark ? borderAccent : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Sub-label ──
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 6),

              // ── Balance ──
              Text(
                CurrencyFormatter.format(account.solde, symbol: account.devise),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              // ── Bottom info row ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Disponible',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    account.numero ?? account.id.substring(account.id.length - 4),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAccountLabel(String type) {
    switch (type) {
      case 'COURANT':
        return 'Compte Principal';
      case 'EPARGNE':
        return 'Compte Épargne';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      default:
        return type;
    }
  }
}

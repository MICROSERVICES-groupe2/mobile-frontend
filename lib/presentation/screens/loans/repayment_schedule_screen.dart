import 'package:flutter/material.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../../domain/entities/loan.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/common/glass_container.dart';

class RepaymentScheduleScreen extends StatelessWidget {
  final Loan loan;

  const RepaymentScheduleScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final schedule = _calculateSchedule(loan);

    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Échéancier',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                children: [
                  _summaryRow('Montant initial', CurrencyFormatter.format(loan.montantInitial), context),
                  const SizedBox(height: 12),
                  _summaryRow('Mensualité', CurrencyFormatter.format(loan.montantMensualite), context),
                  const SizedBox(height: 12),
                  _summaryRow('Taux d\'intérêt', '${loan.tauxInteret}%', context),
                  const SizedBox(height: 12),
                  _summaryRow('Durée', '${loan.dureeMois} mois', context),
                  const SizedBox(height: 12),
                  _summaryRow('Reste à payer', CurrencyFormatter.format(loan.resteAPayer), context),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Plan d\'amortissement',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                children: [
                  _headerRow(),
                  const Divider(color: DesignTokens.navy600, height: 1),
                  ...schedule.asMap().entries.map((entry) {
                    return _scheduleRow(entry.key + 1, entry.value);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _headerCell('Mois', 0.08),
          _headerCell('Principal', 0.28),
          _headerCell('Intérêts', 0.24),
          _headerCell('Solde restant', 0.4),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double flex) {
    return Expanded(
      flex: (flex * 100).toInt(),
      child: Text(
        label,
        style: TextStyle(
          color: DesignTokens.teal300.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _scheduleRow(int index, _RepaymentRow row) {
    final isPaid = index <= _paidMonths(loan);
    final color = isPaid ? DesignTokens.success.withValues(alpha: 0.7) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          _cell('$index', color, 0.08),
          _cell(CurrencyFormatter.format(row.principal, symbol: ''), color, 0.28),
          _cell(CurrencyFormatter.format(row.interet, symbol: ''), color, 0.24),
          _cell(CurrencyFormatter.format(row.soldeRestant), color, 0.4),
        ],
      ),
    );
  }

  Widget _cell(String text, Color color, double flex) {
    return Expanded(
      flex: (flex * 100).toInt(),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  int _paidMonths(Loan loan) {
    final totalPaid = loan.montantInitial - loan.resteAPayer;
    return (totalPaid / loan.montantMensualite).floor();
  }

  List<_RepaymentRow> _calculateSchedule(Loan loan) {
    final r = (loan.tauxInteret / 100) / 12;
    final n = loan.dureeMois;
    final p = loan.montantInitial;

    final schedule = <_RepaymentRow>[];
    double remaining = p;

    for (int i = 0; i < n; i++) {
      final interet = remaining * r;
      final principal = loan.montantMensualite - interet;
      remaining = (remaining - principal).clamp(0, p);

      schedule.add(_RepaymentRow(
        principal: principal,
        interet: interet,
        soldeRestant: remaining,
      ));

      if (remaining <= 0) break;
    }

    return schedule;
  }
}

class _RepaymentRow {
  final double principal;
  final double interet;
  final double soldeRestant;

  const _RepaymentRow({
    required this.principal,
    required this.interet,
    required this.soldeRestant,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bank_platform_mobile/domain/entities/account.dart';
import 'package:bank_platform_mobile/presentation/widgets/account_card.dart';

void main() {
  const tAccount = Account(
    id: '123456789',
    type: 'COURANT',
    solde: 150000.0,
    devise: 'XAF',
    statut: 'ACTIVE',
    numero: '1234 5678 9012',
  );

  testWidgets('should render AccountCard with correct account info', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountCard(account: tAccount),
        ),
      ),
    );

    // Assert
    expect(find.text('Compte Principal'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('1234 5678 9012'), findsOneWidget);
    // 150 000 XAF with French locale formatting
    expect(find.textContaining('150'), findsOneWidget);
    expect(find.textContaining('XAF'), findsOneWidget);
  });

  testWidgets('should trigger onTap callback when tapped', (WidgetTester tester) async {
    bool isTapped = false;

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountCard(
            account: tAccount,
            onTap: () {
              isTapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    // Assert
    expect(isTapped, isTrue);
  });
}

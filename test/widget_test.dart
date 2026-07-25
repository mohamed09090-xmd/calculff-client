import 'package:calculff_client/features/auth/presentation/auth_screens.dart';
import 'package:calculff_client/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bootstrap screen provides an accessible loading state',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BootstrapScreen(),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

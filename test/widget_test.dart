import 'package:calculff_client/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the CalculFF Client bootstrap name', (tester) async {
    await tester.pumpWidget(const CalculFFClientBootstrapApp());

    expect(find.text('CalculFF Client'), findsOneWidget);
  });
}

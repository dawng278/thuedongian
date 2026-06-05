import 'package:flutter_test/flutter_test.dart';
import 'package:taxeasy_app/main.dart';

void main() {
  testWidgets('TaxEasyApp loads without crash', (tester) async {
    await tester.pumpWidget(const TaxEasyApp());
    expect(find.byType(TaxEasyApp), findsOneWidget);
  });
}

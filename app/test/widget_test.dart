import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxeasy_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen loads without crash', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}

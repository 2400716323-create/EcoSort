import 'package:ecosort/screens/login_screen.dart';
import 'package:ecosort/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Login screen renders fields and button', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: AppState(),
      child: const MaterialApp(home: LoginScreen()),
    ));
    expect(find.text('EcoSort'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Create account switches to the sign-up form', (tester) async {
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: AppState(),
      child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
  });
}

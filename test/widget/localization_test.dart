import 'package:astailors/core/utils/utils_exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<String> pumpAndReadSignIn(WidgetTester tester, Locale locale) async {
    late String signInLabel;

    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            signInLabel = context.l10n.signIn;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pump();

    return signInLabel;
  }

  testWidgets('resolves English strings for the en locale', (tester) async {
    final label = await pumpAndReadSignIn(tester, const Locale('en'));
    expect(label, 'Sign In');
  });

  testWidgets('resolves Spanish strings for the es locale', (tester) async {
    final label = await pumpAndReadSignIn(tester, const Locale('es'));
    expect(label, 'Iniciar sesión');
  });
}

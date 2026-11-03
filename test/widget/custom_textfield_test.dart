import 'package:astailors/core/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Form(child: child)),
  );

  testWidgets('runs asyncValidator after the debounce and shows the error', (tester) async {
    await tester.pumpWidget(
      wrap(
        CustomTextFormField(
          asyncValidatorDebounce: const Duration(milliseconds: 50),
          asyncValidator: (value) async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            return value == 'taken' ? 'Username already taken' : null;
          },
        ),
      ),
    );

    final formFieldState = tester.state<FormFieldState<String>>(find.byType(TextFormField));

    await tester.enterText(find.byType(TextFormField), 'taken');
    // Debounce hasn't fired yet.
    await tester.pump(const Duration(milliseconds: 20));
    formFieldState.validate();
    await tester.pump();
    expect(find.text('Username already taken'), findsNothing);

    // Let the debounce + async validator resolve.
    await tester.pump(const Duration(milliseconds: 60));
    formFieldState.validate();
    await tester.pump();

    expect(find.text('Username already taken'), findsOneWidget);
  });

  testWidgets('sync validator wins over a pending async error', (tester) async {
    await tester.pumpWidget(
      wrap(
        CustomTextFormField(
          asyncValidatorDebounce: const Duration(milliseconds: 10),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          asyncValidator: (value) async => 'Async error',
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '');
    await tester.pump(const Duration(milliseconds: 30));

    final formFieldState = tester.state<FormFieldState<String>>(find.byType(TextFormField));
    formFieldState.validate();
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Async error'), findsNothing);
  });

  testWidgets('external errorText overrides validator and is shown immediately', (tester) async {
    await tester.pumpWidget(
      wrap(CustomTextFormField(errorText: 'Email already registered', validator: (_) => null)),
    );

    final formFieldState = tester.state<FormFieldState<String>>(find.byType(TextFormField));
    formFieldState.validate();
    await tester.pump();

    expect(find.text('Email already registered'), findsOneWidget);
  });
}

import 'package:astailors/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  testWidgets('CustomButton shows its label and reports taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            label: 'Submit',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Submit'), findsOneWidget);

    await tester.tap(find.byType(CustomButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('CustomButton shows a loading indicator instead of its label when isLoading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            label: 'Submit',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.text('Submit'), findsNothing);
    expect(find.byType(LoadingIndicator), findsOneWidget);
  });
}

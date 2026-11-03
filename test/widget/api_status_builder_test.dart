import 'package:flutter/material.dart';
import 'package:flutter_template/core/constants/app_enums.dart';
import 'package:flutter_template/core/shared/domain/failures/failure.dart';
import 'package:flutter_template/core/widgets/api_status_builder.dart';
import 'package:flutter_template/core/widgets/empty_state_widget.dart';
import 'package:flutter_template/core/widgets/error_state_widget.dart';
import 'package:flutter_template/core/widgets/loading_indicator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget pumpableTree({
    required ApiStatus status,
    String? data,
    Failure? failure,
    VoidCallback? onRetry,
    bool Function(String)? isEmpty,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ApiStatusBuilder<String>(
          status: status,
          data: data,
          failure: failure,
          onRetry: onRetry,
          isEmpty: isEmpty,
          builder: (context, value) => Text(value),
        ),
      ),
    );
  }

  testWidgets('shows LoadingIndicator while loading', (tester) async {
    await tester.pumpWidget(pumpableTree(status: ApiStatus.LOADING));
    expect(find.byType(LoadingIndicator), findsOneWidget);
  });

  testWidgets('shows the builder content on success with data', (tester) async {
    await tester.pumpWidget(pumpableTree(status: ApiStatus.SUCCESS, data: 'hello'));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('shows EmptyStateWidget on success with null data', (tester) async {
    await tester.pumpWidget(pumpableTree(status: ApiStatus.SUCCESS, data: null));
    expect(find.byType(EmptyStateWidget), findsOneWidget);
  });

  testWidgets('shows EmptyStateWidget when isEmpty callback says so', (tester) async {
    await tester.pumpWidget(
      pumpableTree(status: ApiStatus.SUCCESS, data: '', isEmpty: (v) => v.isEmpty),
    );
    expect(find.byType(EmptyStateWidget), findsOneWidget);
  });

  testWidgets('shows ErrorStateWidget with mapped message on failure', (tester) async {
    await tester.pumpWidget(
      pumpableTree(status: ApiStatus.FAILURE, failure: const ServerFailure('boom')),
    );
    expect(find.byType(ErrorStateWidget), findsOneWidget);
    // ServerFailure maps to a fixed generic message, not the raw failure text.
    expect(find.text('Something went wrong on our end. Please try again.'), findsOneWidget);
  });
}

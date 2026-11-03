import 'dart:async';

import 'package:astailors/core/services/connectivity_cubit.dart';
import 'package:astailors/core/services/services_exports.dart';
import 'package:astailors/core/widgets/connectivity_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class _FakeConnectivityService implements ConnectivityService {
  final _controller = StreamController<InternetStatus>.broadcast();
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<InternetStatus> get onStatusChange => _controller.stream;

  void emit(InternetStatus status) => _controller.add(status);

  void dispose() => _controller.close();
}

void main() {
  testWidgets('hides the banner when online and shows it when offline', (tester) async {
    final fakeService = _FakeConnectivityService();
    final cubit = ConnectivityCubit(connectivityService: fakeService);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const ConnectivityBanner(child: Scaffold(body: Text('content'))),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No internet connection'), findsNothing);

    fakeService.emit(InternetStatus.disconnected);
    await tester.pumpAndSettle();

    expect(find.text('No internet connection'), findsOneWidget);

    fakeService.emit(InternetStatus.connected);
    await tester.pumpAndSettle();

    expect(find.text('No internet connection'), findsNothing);

    await cubit.close();
    fakeService.dispose();
  });
}

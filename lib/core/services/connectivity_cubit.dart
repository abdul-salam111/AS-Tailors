import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'connectivity_service.dart';

/// App-wide connectivity state — `true` while the device has no internet
/// access. Provided once at the app root (see [MyApp]) so any screen can
/// react to it without wiring its own listener.
class ConnectivityCubit extends Cubit<bool> {
  final ConnectivityService _connectivityService;
  StreamSubscription<InternetStatus>? _subscription;

  ConnectivityCubit({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService,
        super(false) {
    _checkInitialStatus();
    _subscription = _connectivityService.onStatusChange.listen((status) {
      emit(status == InternetStatus.disconnected);
    });
  }

  Future<void> _checkInitialStatus() async {
    final connected = await _connectivityService.isConnected;
    if (!isClosed) emit(!connected);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

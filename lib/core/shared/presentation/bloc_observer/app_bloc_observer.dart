import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<Object?> bloc) {
    super.onCreate(bloc);
    if (kDebugMode) debugPrint('BLoC created  → ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<Object?, Object?> bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) debugPrint('Event         → ${bloc.runtimeType}: $event');
  }

  @override
  void onChange(BlocBase<Object?> bloc, Change<Object?> change) {
    super.onChange(bloc, change);
    if (kDebugMode) debugPrint('State changed → ${bloc.runtimeType}');
  }

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) debugPrint('BLoC error    → ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<Object?> bloc) {
    super.onClose(bloc);
    if (kDebugMode) debugPrint('BLoC closed   → ${bloc.runtimeType}');
  }
}

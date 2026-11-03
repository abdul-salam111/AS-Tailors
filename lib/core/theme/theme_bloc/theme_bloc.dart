import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_events.dart';
import 'theme_states.dart';
import '../../local_storage/storage.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final LocalStorage localStorage;

  ThemeBloc({required this.localStorage}) : super(const ThemeState(isDarkMode: false)) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final value = await localStorage.readValues(StorageKeys.isDarkMode);
    final isDark = value == 'true';
    emit(state.copyWith(isDarkMode: isDark));
    _updateSystemUIOverlay(isDark);
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    final newValue = !state.isDarkMode;
    await localStorage.setValues(StorageKeys.isDarkMode, newValue.toString());
    emit(state.copyWith(isDarkMode: newValue));
    _updateSystemUIOverlay(newValue);
  }

  Future<void> _onSetTheme(SetTheme event, Emitter<ThemeState> emit) async {
    await localStorage.setValues(StorageKeys.isDarkMode, event.isDark.toString());
    emit(state.copyWith(isDarkMode: event.isDark));
    _updateSystemUIOverlay(event.isDark);
  }

  void _updateSystemUIOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}

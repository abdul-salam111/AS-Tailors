import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../local_storage/storage.dart';

/// App-wide language selection. `state == null` means "follow the device
/// locale" (falls back to the first supported locale — see
/// `AppLocalizations.supportedLocales`); a non-null [Locale] pins the app
/// to that language regardless of device settings, same persistence
/// pattern as `ThemeBloc`.
class LocaleCubit extends Cubit<Locale?> {
  final LocalStorage localStorage;

  LocaleCubit({required this.localStorage}) : super(null);

  Future<void> loadLocale() async {
    final code = await localStorage.readValues(StorageKeys.locale);
    if (code != null && code.isNotEmpty) {
      emit(Locale(code));
    }
  }

  Future<void> setLocale(Locale locale) async {
    await localStorage.setValues(StorageKeys.locale, locale.languageCode);
    emit(locale);
  }
}

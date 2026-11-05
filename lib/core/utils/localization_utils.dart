import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart' show AppLocalizations;

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// The locale actually in effect (resolved by `MaterialApp.router` from
  /// `LocaleCubit`'s pinned choice, or the device locale when it's
  /// following-device/`null`) — use this, not `LocaleCubit`'s raw state,
  /// to decide which language of a bilingual value (e.g. a seeded
  /// measurement field's `labelEn`/`labelUr`) to display.
  Locale get appLocale => Localizations.localeOf(this);

  bool get isUrdu => appLocale.languageCode == 'ur';
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/env.dart';
import 'core/di/di_exports.dart';
import 'core/localization/locale_cubit.dart';
import 'core/services/connectivity_cubit.dart';
import 'core/services/connectivity_service.dart';
import 'core/shared/presentation/bloc_observer/app_bloc_observer.dart';
import 'core/shared/shared_exports.dart';
import 'core/theme/theme_exports.dart';
import 'core/widgets/connectivity_banner.dart';
import 'l10n/generated/app_localizations.dart';
import 'routes/routes_exports.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Errors caught by the Flutter framework (build/layout/paint).
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _reportError(details.exception, details.stack);
      };

      // Errors from outside the Flutter framework (platform channels, etc).
      PlatformDispatcher.instance.onError = (error, stack) {
        _reportError(error, stack);
        return true;
      };

      if (!kDebugMode) {
        // Release builds: show a generic message instead of the red
        // "Error" screen when a widget fails to build.
        ErrorWidget.builder = (details) =>
            const Material(child: Center(child: Text('Something went wrong.')));
      }

      Bloc.observer = AppBlocObserver();
      await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabasePublishableKey);
      await setupLocator();
      runApp(const MyApp());
    },
    // Errors from anything outside the two handlers above — e.g. an
    // un-awaited Future that throws.
    (error, stack) => _reportError(error, stack),
  );
}

/// Single funnel for uncaught errors. Wire a crash reporting service
/// (Firebase Crashlytics, Sentry, ...) here later — right now it only
/// logs, and only in debug builds.
void _reportError(Object error, StackTrace? stack) {
  if (kDebugMode) {
    debugPrint('Uncaught error: $error');
    if (stack != null) debugPrint('$stack');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc(localStorage: sl())..add(const LoadTheme())),
        BlocProvider(create: (context) => LocaleCubit(localStorage: sl())..loadLocale()),
        BlocProvider(
          create: (context) => ConnectivityCubit(connectivityService: sl<ConnectivityService>()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                onGenerateTitle: (context) => AppLocalizations.of(context).appName,
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: themeState.themeMode,
                locale: locale,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: AppRoutes.router,
                builder: (context, child) =>
                    ConnectivityBanner(child: child ?? const SizedBox.shrink()),
              );
            },
          );
        },
      ),
    );
  }
}

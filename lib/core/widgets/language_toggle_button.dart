import 'package:flutter/material.dart';
import '../localization/locale_cubit.dart';
import '../shared/shared_exports.dart';

/// English/Urdu toggle — drop into any `CustomAppBar(actions: [...])`.
/// Only two locales are supported today, so this is a direct swap rather
/// than a picker; revisit if a third locale is ever added.
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleCubit>().state?.languageCode ?? 'en';
    final isUrdu = current == 'ur';
    return IconButton(
      icon: Text(
        isUrdu ? 'EN' : 'اردو',
        style: TextStyle(color: IconTheme.of(context).color, fontWeight: FontWeight.bold),
      ),
      onPressed: () => context.read<LocaleCubit>().setLocale(Locale(isUrdu ? 'en' : 'ur')),
    );
  }
}

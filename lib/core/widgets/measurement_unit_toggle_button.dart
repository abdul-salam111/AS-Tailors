import 'package:flutter/material.dart';
import '../services/measurement_unit_cubit.dart';
import '../shared/shared_exports.dart';

/// Inches/centimeters toggle for the measurement-unit preference — drop
/// into Account → Settings (`ProfileView`'s `_SettingsSection`), same
/// shape as `LanguageToggleButton`.
class MeasurementUnitToggleButton extends StatelessWidget {
  const MeasurementUnitToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isCm = context.watch<MeasurementUnitCubit>().state == 'cm';
    return IconButton(
      icon: Text(
        isCm ? 'CM' : 'IN',
        style: TextStyle(color: IconTheme.of(context).color, fontWeight: FontWeight.bold),
      ),
      onPressed: () => context.read<MeasurementUnitCubit>().setUnit(isCm ? 'in' : 'cm'),
    );
  }
}

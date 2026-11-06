import 'package:flutter_bloc/flutter_bloc.dart';
import '../local_storage/storage.dart';

/// App-wide default unit ('in'/'cm') for new measurement profiles — a
/// shop-level preference set once in Account → Settings (a shop
/// overwhelmingly uses one unit system) instead of toggled per
/// measurement form. Defaults to 'in', same persistence pattern as
/// `ThemeBloc`/`LocaleCubit`.
class MeasurementUnitCubit extends Cubit<String> {
  final LocalStorage localStorage;

  MeasurementUnitCubit({required this.localStorage}) : super('in');

  Future<void> loadUnit() async {
    final unit = await localStorage.readValues(StorageKeys.measurementUnit);
    if (unit != null && unit.isNotEmpty) emit(unit);
  }

  Future<void> setUnit(String unit) async {
    await localStorage.setValues(StorageKeys.measurementUnit, unit);
    emit(unit);
  }
}

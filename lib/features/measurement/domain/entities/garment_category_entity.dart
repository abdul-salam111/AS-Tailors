import 'package:equatable/equatable.dart';

/// A garment category (SRS §9.4) — e.g. Shalwar Kameez, Shirt. Reference
/// data seeded by migration, not user-editable in the app yet.
class GarmentCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? nameUr;
  final String slug;

  const GarmentCategoryEntity({
    required this.id,
    required this.name,
    this.nameUr,
    required this.slug,
  });

  @override
  List<Object?> get props => [id, name, nameUr, slug];
}

/// Fixed display order for launch's two garment categories (Shalwar Kameez
/// before Shirt, per product preference, rather than the alphabetical order
/// the backend query returns) — any category outside this list (future
/// additions) sorts after both, alphabetically by name.
const _categoryDisplayPriority = {'shalwar_kameez': 0, 'shirt': 1};

extension GarmentCategoryOrdering on List<GarmentCategoryEntity> {
  List<GarmentCategoryEntity> sortedByDisplayPriority() {
    final sorted = [...this];
    sorted.sort((a, b) {
      final priorityA = _categoryDisplayPriority[a.slug] ?? 99;
      final priorityB = _categoryDisplayPriority[b.slug] ?? 99;
      if (priorityA != priorityB) return priorityA.compareTo(priorityB);
      return a.name.compareTo(b.name);
    });
    return sorted;
  }
}

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

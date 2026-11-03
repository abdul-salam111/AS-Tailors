import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String currency;
  final String timezone;

  const ShopEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.currency,
    required this.timezone,
  });

  @override
  List<Object?> get props => [id, ownerId, name, currency, timezone];
}

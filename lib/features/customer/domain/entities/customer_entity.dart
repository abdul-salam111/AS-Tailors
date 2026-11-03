import 'package:equatable/equatable.dart';

/// A shop's customer record (SRS §9.3, §23.4). `profileId` is null for a
/// walk-in who has no Supabase Auth account — the common case in Phase 1,
/// since online customer registration is deferred (SRS §1.2).
class CustomerEntity extends Equatable {
  final String id;
  final String shopId;
  final String? profileId;
  final String fullName;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerEntity({
    required this.id,
    required this.shopId,
    this.profileId,
    required this.fullName,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    shopId,
    profileId,
    fullName,
    phone,
    whatsapp,
    email,
    address,
    notes,
    isActive,
    createdAt,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';

class UpdateCustomerParams extends Equatable {
  final String id;
  final String fullName;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String? notes;

  const UpdateCustomerParams({
    required this.id,
    required this.fullName,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.notes,
  });

  @override
  List<Object?> get props => [id, fullName, phone, whatsapp, email, address, notes];
}

import 'package:equatable/equatable.dart';

class CreateCustomerParams extends Equatable {
  final String fullName;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String? notes;

  const CreateCustomerParams({
    required this.fullName,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.notes,
  });

  @override
  List<Object?> get props => [fullName, phone, whatsapp, email, address, notes];
}

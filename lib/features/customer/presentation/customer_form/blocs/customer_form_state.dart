import '../../../../../core/constants/app_enums.dart';
import '../../../../../core/shared/shared_exports.dart';
import '../../../domain/entities/customer_entity.dart';

class CustomerFormState extends Equatable {
  final String? editingId;
  final String fullName;
  final String phone;
  final String whatsapp;
  final String email;
  final String address;
  final String notes;
  final ApiStatus apiStatus;
  final CustomerEntity? customer;
  final String? message;
  final Failure? failure;

  const CustomerFormState({
    this.editingId,
    this.fullName = '',
    this.phone = '',
    this.whatsapp = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.apiStatus = ApiStatus.INITIAL,
    this.customer,
    this.message,
    this.failure,
  });

  bool get isEditing => editingId != null;

  CustomerFormState copyWith({
    String? editingId,
    String? fullName,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    String? notes,
    ApiStatus? apiStatus,
    CustomerEntity? customer,
    String? message,
    Failure? failure,
  }) {
    return CustomerFormState(
      editingId: editingId ?? this.editingId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      apiStatus: apiStatus ?? this.apiStatus,
      customer: customer ?? this.customer,
      message: message ?? this.message,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    editingId,
    fullName,
    phone,
    whatsapp,
    email,
    address,
    notes,
    apiStatus,
    customer,
    message,
    failure,
  ];
}

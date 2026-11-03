import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

/// Maps a `customers` row (SRS §9.3). `normalizedPhone` is populated by the
/// `customers_normalize_phone` trigger (see
/// `supabase/migrations/0002_customers.sql`) — never set it from Dart.
@freezed
abstract class CustomerModel with _$CustomerModel {
  const factory CustomerModel({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    @JsonKey(name: 'profile_id') String? profileId,
    @JsonKey(name: 'full_name') required String fullName,
    String? phone,
    @JsonKey(name: 'normalized_phone') String? normalizedPhone,
    String? whatsapp,
    String? email,
    String? address,
    String? notes,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
}

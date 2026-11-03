import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_model.freezed.dart';
part 'shop_model.g.dart';

/// Maps a `shops` row as returned by the `bootstrap_shop` RPC. Only the
/// columns the app currently needs are modeled — `fromJson` ignores the
/// rest (logo_url, address, ...) until a feature actually needs them.
@freezed
abstract class ShopModel with _$ShopModel {
  const factory ShopModel({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    required String currency,
    required String timezone,
  }) = _ShopModel;

  factory ShopModel.fromJson(Map<String, dynamic> json) => _$ShopModelFromJson(json);
}

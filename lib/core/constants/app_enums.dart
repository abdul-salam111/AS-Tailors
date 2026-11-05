// ignore_for_file: constant_identifier_names

enum ApiStatus { INITIAL, LOADING, SUCCESS, FAILURE }

/// Shop membership role (SRS §3, §9 `shop_role` enum). Values are
/// lower-case to match the Postgres enum 1:1 — `json_serializable`'s
/// default enum handling (`.name`) round-trips through Supabase rows with
/// no converter needed.
enum ShopRole { owner, admin, tailor, staff }

/// How a measurement template field is captured — matches
/// `measurement_template_fields.input_type`'s check constraint 1:1 (same
/// lower-case-member-name convention as [ShopRole]).
enum MeasurementFieldInputType { number, counter, dropdown, checkbox }

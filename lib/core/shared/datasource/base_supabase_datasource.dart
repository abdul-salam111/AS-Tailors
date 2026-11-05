import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../networks/exceptions/app_exceptions.dart';
import '../../networks/exceptions/supabase_exception_mapper.dart';

/// Base class for datasources backed directly by Supabase (Postgres via
/// postgrest, RPC functions, Auth or Storage) — the Supabase analogue of
/// `BaseRemoteDatasource`. Extend this instead of hand-rolling try/catch
/// around `client.from(...)`/`client.rpc(...)` calls; every method here
/// (and [guard] for anything they don't cover) funnels Supabase-side
/// exceptions through [mapSupabaseException], so the rest of the error
/// chain — `BaseRepository.execute` → `Failure` → `AppFailureMapper` —
/// stays identical regardless of which backend a feature talks to.
///
/// Typical datasource:
/// ```dart
/// class CustomerRemoteDatasourceImpl extends BaseSupabaseDatasource
///     implements ICustomerRemoteDatasource {
///   const CustomerRemoteDatasourceImpl({required super.client});
///
///   @override
///   Future<CustomerModel> getCustomer(String id) => single(
///         query: () => client.from('customers').select().eq('id', id).single(),
///         parser: CustomerModel.fromJson,
///       );
///
///   @override
///   Future<List<CustomerModel>> getCustomers() => list(
///         query: () => client.from('customers').select(),
///         parser: CustomerModel.fromJson,
///       );
/// }
/// ```
abstract class BaseSupabaseDatasource {
  final SupabaseClient client;

  const BaseSupabaseDatasource({required this.client});

  /// A query returning exactly one row — end the chain with `.single()`.
  Future<T> single<T>({
    required Future<Map<String, dynamic>> Function() query,
    required T Function(Map<String, dynamic> row) parser,
  }) => guard(() async => parser(await query()));

  /// A query returning zero or one row — end the chain with
  /// `.maybeSingle()`. Returns `null` when no row matched.
  Future<T?> maybeSingle<T>({
    required Future<Map<String, dynamic>?> Function() query,
    required T Function(Map<String, dynamic> row) parser,
  }) => guard(() async {
    final row = await query();
    return row == null ? null : parser(row);
  });

  /// A query returning a list of rows, each mapped through [parser].
  Future<List<T>> list<T>({
    required Future<List<Map<String, dynamic>>> Function() query,
    required T Function(Map<String, dynamic> row) parser,
  }) => guard(() async => (await query()).map(parser).toList());

  /// Calls a Postgres function via `client.rpc(...)`, mapping its result
  /// through [parser]. Prefer this over composing an atomic/multi-step
  /// business operation (`record_payment`, `create_order`, ...) from
  /// several separate table calls on the client.
  Future<T> rpc<T>({
    required String function,
    Map<String, dynamic>? params,
    required T Function(dynamic data) parser,
  }) => guard(() async => parser(await client.rpc(function, params: params)));

  /// A write with no meaningful return value (e.g. `.update()`/`.delete()`
  /// without a trailing `.select()`).
  Future<void> mutate(Future<void> Function() query) => guard(query);

  /// Uploads bytes to a Storage bucket and returns the storage path on
  /// success (the same [path] passed in — callers persist it, e.g. onto a
  /// `*_reference_images` row, rather than a public URL, since buckets in
  /// this app are private; resolve a usable URL later via [createSignedUrl]).
  Future<String> uploadToStorage({
    required String bucket,
    required String path,
    required Uint8List bytes,
  }) => guard(() async {
    await client.storage.from(bucket).uploadBinary(path, bytes);
    return path;
  });

  /// A time-limited URL for a private bucket object — never use
  /// `getPublicUrl()` on a non-public bucket, it returns an unusable link.
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    int expiresInSeconds = 3600,
  }) => guard(() => client.storage.from(bucket).createSignedUrl(path, expiresInSeconds));

  /// Exception-mapping wrapper for anything the helpers above don't cover
  /// — `client.auth.*`, `client.storage.*`, or any call shaped
  /// differently than a plain row/list/rpc result.
  Future<T> guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AppException {
      rethrow;
    } catch (e) {
      throw mapSupabaseException(e);
    }
  }
}

// Creates a fully-provisioned AS Tailors account: a pre-confirmed
// Supabase Auth user (no email/OTP step) plus shop membership. This is
// the replacement for public self-signup — this deployment is closed
// (one shop, accounts handed out directly), see CLAUDE.md and
// lib/features/auth/presentation/signin/views/signin_view.dart.
//
// The FIRST account you create becomes the shop's owner and provisions
// "AS Tailors" itself. Every account after that joins the existing shop
// in whatever --role you pass (default: staff).
//
// Run with plain `dart run` (not `flutter run`) — this never ships with
// the app and must never import package:flutter.
//
// Usage:
//   SUPABASE_SERVICE_ROLE_KEY=... dart run scripts/create_user.dart \
//     --email brother@example.com --name "Brother's Name" \
//     [--password "temp-password"] [--role owner|admin|tailor|staff]
//
// If --password is omitted, a random one is generated and printed once —
// write it down, it is not stored anywhere.
//
// SUPABASE_SERVICE_ROLE_KEY is NOT the same as SUPABASE_PUBLISHABLE_KEY in
// .env. Find it in Supabase Dashboard > Project Settings > API > service_role
// secret. It bypasses every RLS policy — never put it in .env, never commit
// it, never ship it in the app. Export it in your shell only for as long as
// you're running this script.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _supabaseUrl = 'https://mohqnslgkasfftzodbkk.supabase.co';
const _validRoles = {'owner', 'admin', 'tailor', 'staff'};
const _defaultShopName = 'AS Tailors';

Future<void> main(List<String> args) async {
  final Map<String, String> options;
  try {
    options = _parseArgs(args);
  } on ArgumentError catch (e) {
    stderr.writeln('${e.message}\n');
    _printUsage();
    exit(64);
  }

  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (serviceRoleKey == null || serviceRoleKey.isEmpty) {
    stderr.writeln(
      'Set SUPABASE_SERVICE_ROLE_KEY in your shell first\n'
      '(Supabase Dashboard > Project Settings > API > service_role secret).',
    );
    exit(1);
  }

  final email = options['email']!;
  final name = options['name']!;
  final password = options['password'] ?? _generatePassword();
  final requestedRole = options['role'] ?? 'staff';
  if (!_validRoles.contains(requestedRole)) {
    stderr.writeln('--role must be one of: ${_validRoles.join(', ')}');
    exit(64);
  }

  final client = HttpClient();
  try {
    final api = _SupabaseAdmin(client: client, baseUrl: _supabaseUrl, serviceRoleKey: serviceRoleKey);

    stdout.writeln('Creating auth user for $email...');
    final userId = await api.createUser(email: email, password: password, fullName: name);
    stdout.writeln('  user id: $userId');

    final existingShopId = await api.findExistingShopId();
    if (existingShopId == null) {
      stdout.writeln('No shop exists yet — provisioning "$_defaultShopName" with this account as owner.');
      final shopId = await api.createShop(name: _defaultShopName, ownerId: userId);
      await api.addShopMember(shopId: shopId, userId: userId, role: 'owner');
      await api.logAudit(
        actorId: userId,
        action: 'shop.bootstrap',
        entityType: 'shops',
        entityId: shopId,
      );
      stdout.writeln('  shop id: $shopId (role: owner)');
    } else {
      stdout.writeln('Shop already exists — joining as $requestedRole.');
      await api.addShopMember(shopId: existingShopId, userId: userId, role: requestedRole);
      await api.logAudit(
        actorId: userId,
        action: 'shop_member.auto_join',
        entityType: 'shop_members',
        entityId: existingShopId,
      );
      stdout.writeln('  shop id: $existingShopId (role: $requestedRole)');
    }

    stdout.writeln('\nDone. Hand these credentials to the user:');
    stdout.writeln('  email:    $email');
    stdout.writeln('  password: $password');
    if (options['password'] == null) {
      stdout.writeln('  (generated — this is the only time it is shown, write it down now)');
    }
  } on _ApiException catch (e) {
    stderr.writeln('\nFailed: ${e.message}');
    exit(1);
  } finally {
    client.close(force: true);
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) {
      throw ArgumentError('Unexpected argument: $arg');
    }
    final key = arg.substring(2);
    if (i + 1 >= args.length) {
      throw ArgumentError('Missing value for --$key');
    }
    result[key] = args[++i];
  }
  if (result['email'] == null || result['email']!.isEmpty) {
    throw ArgumentError('--email is required');
  }
  if (result['name'] == null || result['name']!.isEmpty) {
    throw ArgumentError('--name is required');
  }
  return result;
}

void _printUsage() {
  stderr.writeln(
    'Usage: SUPABASE_SERVICE_ROLE_KEY=... dart run scripts/create_user.dart '
    '--email <email> --name <full name> [--password <password>] '
    '[--role owner|admin|tailor|staff]',
  );
}

const _passwordCharset = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#%&*';

String _generatePassword([int length = 16]) {
  final random = Random.secure();
  return List.generate(length, (_) => _passwordCharset[random.nextInt(_passwordCharset.length)]).join();
}

class _ApiException implements Exception {
  final String message;
  _ApiException(this.message);
}

/// Thin wrapper over the Supabase Admin Auth API and the PostgREST data
/// API, both called with the service_role key — which bypasses RLS
/// entirely, so this intentionally talks to the tables directly rather
/// than through bootstrap_shop()/join_existing_shop() (those RPCs rely on
/// auth.uid() from a live user session, which an admin script doesn't
/// have).
class _SupabaseAdmin {
  final HttpClient client;
  final String baseUrl;
  final String serviceRoleKey;

  _SupabaseAdmin({required this.client, required this.baseUrl, required this.serviceRoleKey});

  Future<String> createUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final body = await _send(
      method: 'POST',
      path: '/auth/v1/admin/users',
      body: {
        'email': email,
        'password': password,
        'email_confirm': true,
        'user_metadata': {'full_name': fullName},
      },
    );
    final id = (body as Map<String, dynamic>)['id'] as String?;
    if (id == null) throw _ApiException('Admin user creation did not return an id: $body');
    return id;
  }

  Future<String?> findExistingShopId() async {
    final body = await _send(method: 'GET', path: '/rest/v1/shops?select=id&limit=1');
    final rows = body as List;
    if (rows.isEmpty) return null;
    return (rows.first as Map<String, dynamic>)['id'] as String;
  }

  Future<String> createShop({required String name, required String ownerId}) async {
    final body = await _send(
      method: 'POST',
      path: '/rest/v1/shops',
      body: {'owner_id': ownerId, 'name': name, 'currency': 'PKR', 'timezone': 'Asia/Karachi'},
      preferReturnRepresentation: true,
    );
    final rows = body as List;
    return (rows.first as Map<String, dynamic>)['id'] as String;
  }

  Future<void> addShopMember({required String shopId, required String userId, required String role}) =>
      _send(
        method: 'POST',
        path: '/rest/v1/shop_members',
        body: {'shop_id': shopId, 'user_id': userId, 'role': role},
      );

  Future<void> logAudit({
    required String actorId,
    required String action,
    required String entityType,
    required String entityId,
  }) => _send(
    method: 'POST',
    path: '/rest/v1/audit_logs',
    body: {'actor_id': actorId, 'action': action, 'entity_type': entityType, 'entity_id': entityId},
  );

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool preferReturnRepresentation = false,
  }) async {
    final request = await client.openUrl(method, Uri.parse('$baseUrl$path'));
    request.headers
      ..set('apikey', serviceRoleKey)
      ..set('Authorization', 'Bearer $serviceRoleKey')
      ..set('Content-Type', 'application/json');
    if (preferReturnRepresentation) {
      request.headers.set('Prefer', 'return=representation');
    }
    if (body != null) {
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 400) {
      throw _ApiException('$method $path -> ${response.statusCode}: $responseBody');
    }
    if (responseBody.isEmpty) return null;
    return jsonDecode(responseBody);
  }
}

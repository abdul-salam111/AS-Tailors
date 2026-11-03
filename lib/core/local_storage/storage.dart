import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_template/core/constants/const_exports.dart';

class LocalStorage {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  static const _androidOptions = AndroidOptions(
    resetOnError: true,
    encryptedSharedPreferences: true,
    migrateOnAlgorithmChange: true,
  );

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  // ─── Storage Instance ─────────────────────────────────────────────────────
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<void> init() async {
    try {
      await _storage
          .containsKey(key: '__health_check__')
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint(
                '[LocalStorage] init() health-check timed out — resetting storage.',
              );
              return false;
            },
          );
    } on PlatformException catch (e) {
      debugPrint(
        '[LocalStorage] init() Keystore corrupt on launch: $e — clearing all.',
      );
      await clearAll();
    } catch (e) {
      debugPrint('[LocalStorage] init() unexpected error: $e');
    }
  }

  // ─── WRITE ────────────────────────────────────────────────────────────────
  Future<bool> setValues(String key, String value) async {
    try {
      await _storage
          .write(key: key, value: value)
          .timeout(const Duration(seconds: 5));
      return true;
    } on PlatformException catch (e) {
      debugPrint('[LocalStorage] Write PlatformException for "$key": $e');
      // Keystore corrupted — reset everything then retry once
      await clearAll();
      try {
        await _storage.write(key: key, value: value);
        debugPrint('[LocalStorage] Write retry succeeded for "$key".');
        return true;
      } catch (retryError) {
        debugPrint(
          '[LocalStorage] Write retry also failed for "$key": $retryError',
        );
        return false;
      }
    } on TimeoutException {
      debugPrint(
        '[LocalStorage] Write timed out for "$key" — likely Keystore deadlock.',
      );
      return false;
    } catch (e) {
      debugPrint('[LocalStorage] Write error for "$key": $e');
      return false;
    }
  }

  // ─── READ ─────────────────────────────────────────────────────────────────
  Future<String?> readValues(String key) async {
    try {
      return await _storage
          .read(key: key)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint(
                '[LocalStorage] Read timed out for "$key" — Keystore hang avoided.',
              );
              return null;
            },
          );
    } on PlatformException catch (e) {
      debugPrint('[LocalStorage] Read PlatformException for "$key": $e');
      // Delete only the corrupted key — don't wipe everything on a read
      try {
        await _storage.delete(key: key);
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('[LocalStorage] Read error for "$key": $e');
      return null;
    }
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  Future<bool> clearValues(String key) async {
    try {
      await _storage.delete(key: key).timeout(const Duration(seconds: 5));
      return true;
    } on TimeoutException {
      debugPrint('[LocalStorage] Delete timed out for "$key".');
      return false;
    } catch (e) {
      debugPrint('[LocalStorage] Delete error for "$key": $e');
      return false;
    }
  }

  // ─── CONTAINS KEY ─────────────────────────────────────────────────────────
  Future<bool> hasValue(String key) async {
    try {
      return await _storage
          .containsKey(key: key)
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
    } catch (e) {
      debugPrint('[LocalStorage] ContainsKey error for "$key": $e');
      return false;
    }
  }

  // ─── CLEAR ALL ────────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll().timeout(const Duration(seconds: 5));
      debugPrint('[LocalStorage] All storage cleared.');
    } catch (e) {
      debugPrint('[LocalStorage] ClearAll error: $e');
    }
  }
}

class StorageKeys {
  static const String loggedIn     = AppConstants.keyLoggedIn;
  static const String token        = AppConstants.keyToken;
  static const String refreshToken = AppConstants.keyRefreshToken;
  static const String userId       = AppConstants.keyUserId;
  static const String userDetails  = AppConstants.keyUserDetails;
  static const String isDarkMode   = AppConstants.keyIsDarkMode;
}

extension LocalStorageGetters on LocalStorage {
  Future<String?> get userId async => readValues(StorageKeys.userId);
  Future<String?> get userToken async => readValues(StorageKeys.token);
}

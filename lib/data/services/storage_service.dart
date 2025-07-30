import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // Temporarily disabled
import 'package:star_frontend/core/constants/app_constants.dart';
import 'package:star_frontend/core/errors/app_exceptions.dart';
import 'package:star_frontend/core/utils/logger.dart';

/// Storage service for managing local data persistence
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  // Temporarily using SharedPreferences instead of FlutterSecureStorage
  // static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(...);

  /// Initialize storage service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('StorageService initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize StorageService', e);
      throw StorageException('Failed to initialize storage: $e');
    }
  }

  /// Get SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StorageException('StorageService not initialized');
    }
    return _prefs!;
  }

  // === String Operations ===

  /// Save string value
  Future<void> setString(String key, String value) async {
    try {
      await prefs.setString(key, value);
      AppLogger.debug('Saved string: $key');
    } catch (e) {
      AppLogger.error('Failed to save string: $key', e);
      throw StorageException('Failed to save string: $e');
    }
  }

  /// Get string value
  String? getString(String key) {
    try {
      return prefs.getString(key);
    } catch (e) {
      AppLogger.error('Failed to get string: $key', e);
      return null;
    }
  }

  // === Integer Operations ===

  /// Save integer value
  Future<void> setInt(String key, int value) async {
    try {
      await prefs.setInt(key, value);
      AppLogger.debug('Saved int: $key');
    } catch (e) {
      AppLogger.error('Failed to save int: $key', e);
      throw StorageException('Failed to save int: $e');
    }
  }

  /// Get integer value
  int? getInt(String key) {
    try {
      return prefs.getInt(key);
    } catch (e) {
      AppLogger.error('Failed to get int: $key', e);
      return null;
    }
  }

  // === Boolean Operations ===

  /// Save boolean value
  Future<void> setBool(String key, bool value) async {
    try {
      await prefs.setBool(key, value);
      AppLogger.debug('Saved bool: $key');
    } catch (e) {
      AppLogger.error('Failed to save bool: $key', e);
      throw StorageException('Failed to save bool: $e');
    }
  }

  /// Get boolean value
  bool? getBool(String key) {
    try {
      return prefs.getBool(key);
    } catch (e) {
      AppLogger.error('Failed to get bool: $key', e);
      return null;
    }
  }

  // === Double Operations ===

  /// Save double value
  Future<void> setDouble(String key, double value) async {
    try {
      await prefs.setDouble(key, value);
      AppLogger.debug('Saved double: $key');
    } catch (e) {
      AppLogger.error('Failed to save double: $key', e);
      throw StorageException('Failed to save double: $e');
    }
  }

  /// Get double value
  double? getDouble(String key) {
    try {
      return prefs.getDouble(key);
    } catch (e) {
      AppLogger.error('Failed to get double: $key', e);
      return null;
    }
  }

  // === List Operations ===

  /// Save string list
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await prefs.setStringList(key, value);
      AppLogger.debug('Saved string list: $key');
    } catch (e) {
      AppLogger.error('Failed to save string list: $key', e);
      throw StorageException('Failed to save string list: $e');
    }
  }

  /// Get string list
  List<String>? getStringList(String key) {
    try {
      return prefs.getStringList(key);
    } catch (e) {
      AppLogger.error('Failed to get string list: $key', e);
      return null;
    }
  }

  // === JSON Operations ===

  /// Save object as JSON
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      await setString(key, jsonString);
      AppLogger.debug('Saved JSON: $key');
    } catch (e) {
      AppLogger.error('Failed to save JSON: $key', e);
      throw StorageException('Failed to save JSON: $e');
    }
  }

  /// Get object from JSON
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to get JSON: $key', e);
      return null;
    }
  }

  // === Secure Storage Operations ===

  /// Save secure string (using SharedPreferences temporarily)
  Future<void> setSecureString(String key, String value) async {
    try {
      // Temporarily using SharedPreferences instead of secure storage
      await prefs.setString('secure_$key', value);
      AppLogger.debug('Saved secure string: $key');
    } catch (e) {
      AppLogger.error('Failed to save secure string: $key', e);
      throw StorageException('Failed to save secure string: $e');
    }
  }

  /// Get secure string (using SharedPreferences temporarily)
  Future<String?> getSecureString(String key) async {
    try {
      // Temporarily using SharedPreferences instead of secure storage
      return prefs.getString('secure_$key');
    } catch (e) {
      AppLogger.error('Failed to get secure string: $key', e);
      return null;
    }
  }

  /// Delete secure string (using SharedPreferences temporarily)
  Future<void> deleteSecureString(String key) async {
    try {
      // Temporarily using SharedPreferences instead of secure storage
      await prefs.remove('secure_$key');
      AppLogger.debug('Deleted secure string: $key');
    } catch (e) {
      AppLogger.error('Failed to delete secure string: $key', e);
      throw StorageException('Failed to delete secure string: $e');
    }
  }

  // === Authentication Storage ===

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    await setSecureString(AppConstants.tokenKey, token);
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    return await getSecureString(AppConstants.tokenKey);
  }

  /// Delete authentication token
  Future<void> deleteAuthToken() async {
    await deleteSecureString(AppConstants.tokenKey);
  }

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await setJson(AppConstants.userKey, userData);
  }

  /// Get user data
  Map<String, dynamic>? getUserData() {
    return getJson(AppConstants.userKey);
  }

  /// Delete user data
  Future<void> deleteUserData() async {
    await remove(AppConstants.userKey);
  }

  // === General Operations ===

  /// Check if key exists
  bool containsKey(String key) {
    try {
      return prefs.containsKey(key);
    } catch (e) {
      AppLogger.error('Failed to check key: $key', e);
      return false;
    }
  }

  /// Remove key
  Future<void> remove(String key) async {
    try {
      await prefs.remove(key);
      AppLogger.debug('Removed key: $key');
    } catch (e) {
      AppLogger.error('Failed to remove key: $key', e);
      throw StorageException('Failed to remove key: $e');
    }
  }

  /// Clear all data
  Future<void> clear() async {
    try {
      await prefs.clear();
      // Temporarily using SharedPreferences only
      // await _secureStorage.deleteAll();
      AppLogger.info('Cleared all storage');
    } catch (e) {
      AppLogger.error('Failed to clear storage', e);
      throw StorageException('Failed to clear storage: $e');
    }
  }

  /// Get all keys
  Set<String> getAllKeys() {
    try {
      return prefs.getKeys();
    } catch (e) {
      AppLogger.error('Failed to get all keys', e);
      return <String>{};
    }
  }

  /// Get storage size (approximate)
  int getStorageSize() {
    try {
      int size = 0;
      for (final key in getAllKeys()) {
        final value = getString(key);
        if (value != null) {
          size += value.length;
        }
      }
      return size;
    } catch (e) {
      AppLogger.error('Failed to calculate storage size', e);
      return 0;
    }
  }

  /// Export all data (for backup)
  Map<String, dynamic> exportData() {
    try {
      final data = <String, dynamic>{};
      for (final key in getAllKeys()) {
        data[key] = prefs.get(key);
      }
      return data;
    } catch (e) {
      AppLogger.error('Failed to export data', e);
      return {};
    }
  }
}

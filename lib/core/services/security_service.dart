import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _pinKey = 'user_app_lock_pin';
  static const String _lockEnabledKey = 'is_app_lock_enabled';
  static const String _biometricEnabledKey = 'is_biometric_enabled';

  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockEnabledKey) ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? true;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<void> savePin(String pin) async {
    try {
      await _secureStorage.write(key: _pinKey, value: pin);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinKey, pin);
    }
    await setAppLockEnabled(true);
  }

  Future<bool> verifyPin(String pin) async {
    String? savedPin;
    try {
      savedPin = await _secureStorage.read(key: _pinKey);
    } catch (_) {}
    if (savedPin == null) {
      final prefs = await SharedPreferences.getInstance();
      savedPin = prefs.getString(_pinKey);
    }
    return savedPin != null && savedPin == pin;
  }

  Future<bool> hasPinSet() async {
    String? savedPin;
    try {
      savedPin = await _secureStorage.read(key: _pinKey);
    } catch (_) {}
    if (savedPin == null) {
      final prefs = await SharedPreferences.getInstance();
      savedPin = prefs.getString(_pinKey);
    }
    return savedPin != null && savedPin.isNotEmpty;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!canCheck && !isDeviceSupported) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Scan fingerprint or Face to access your medical records',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../core/services/security_service.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService = SecurityService();

  bool _isLocked = false;
  bool _isAppLockEnabled = false;
  bool _isBiometricEnabled = true;
  bool _hasPin = false;

  bool get isLocked => _isLocked;
  bool get isAppLockEnabled => _isAppLockEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get hasPin => _hasPin;

  Future<void> initialize() async {
    _isAppLockEnabled = await _securityService.isAppLockEnabled();
    _isBiometricEnabled = await _securityService.isBiometricEnabled();
    _hasPin = await _securityService.hasPinSet();

    if (_isAppLockEnabled && _hasPin) {
      _isLocked = true;
    } else {
      _isLocked = false;
    }
    notifyListeners();
  }

  Future<bool> unlockWithPin(String pin) async {
    final valid = await _securityService.verifyPin(pin);
    if (valid) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> unlockWithBiometrics() async {
    final success = await _securityService.authenticateWithBiometrics();
    if (success) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    await _securityService.savePin(pin);
    _hasPin = true;
    _isAppLockEnabled = true;
    notifyListeners();
  }

  Future<void> toggleAppLock(bool enable) async {
    await _securityService.setAppLockEnabled(enable);
    _isAppLockEnabled = enable;
    notifyListeners();
  }

  Future<void> toggleBiometric(bool enable) async {
    await _securityService.setBiometricEnabled(enable);
    _isBiometricEnabled = enable;
    notifyListeners();
  }

  void lockApp() {
    if (_isAppLockEnabled && _hasPin) {
      _isLocked = true;
      notifyListeners();
    }
  }
}

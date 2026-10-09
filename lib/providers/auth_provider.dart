import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';
import '../core/services/google_drive_service.dart';
import '../models/user_profile_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleDriveService _driveService = GoogleDriveService();

  UserProfileModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkInitialAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInSilently();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        // Verify or create Google Drive backup directory
        await _driveService.getOrCreateBackupFolder();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

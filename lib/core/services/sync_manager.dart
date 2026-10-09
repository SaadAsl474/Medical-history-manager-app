import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_helper.dart';
import 'google_drive_service.dart';

enum SyncStatus {
  idle,
  syncing,
  synced,
  offline,
  error,
}

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Connectivity _connectivity = Connectivity();
  final GoogleDriveService _driveService = GoogleDriveService();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  final StreamController<SyncStatus> _statusController = StreamController<SyncStatus>.broadcast();

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;
  Stream<SyncStatus> get statusStream => _statusController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> initialize() async {
    _lastSyncTime = await _driveService.getLastSyncTime();

    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);

    // Listen for future network state changes
    _connectivitySub = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasInternet = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);

    _isOnline = hasInternet;

    if (!_isOnline) {
      _setStatus(SyncStatus.offline);
    } else {
      // Automatically synchronize when connection is restored
      triggerSync();
    }
  }

  void _setStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Trigger full sync to Google Drive
  Future<bool> triggerSync() async {
    if (!_isOnline) {
      _setStatus(SyncStatus.offline);
      return false;
    }

    _setStatus(SyncStatus.syncing);
    try {
      final exportData = await _dbHelper.exportAllData();
      final success = await _driveService.uploadBackup(exportData);

      if (success) {
        _lastSyncTime = DateTime.now();
        _setStatus(SyncStatus.synced);
        return true;
      } else {
        _setStatus(SyncStatus.error);
        return false;
      }
    } catch (e) {
      _setStatus(SyncStatus.error);
      return false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _statusController.close();
  }
}

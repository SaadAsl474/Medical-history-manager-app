import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  static const String backupFolderName = 'MyMedicalHistory_Backup';
  static const String backupFileName = 'medical_history_backup.json';

  Future<drive.DriveApi?> _getDriveApi() async {
    final authHeaders = await AuthService().getAuthHeaders();
    if (authHeaders == null) return null;
    final authenticateClient = GoogleAuthClient(authHeaders);
    return drive.DriveApi(authenticateClient);
  }

  /// Ensure backup folder exists in user's Drive, or create it
  Future<String?> getOrCreateBackupFolder() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return 'local_mock_folder_id';

      final fileList = await driveApi.files.list(
        q: "mimeType = 'application/vnd.google-apps.folder' and name = '$backupFolderName' and trashed = false",
        $fields: 'files(id, name)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }

      // Create folder
      final folderMetadata = drive.File()
        ..name = backupFolderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folderMetadata);
      return createdFolder.id;
    } catch (e) {
      return 'local_mock_folder_id';
    }
  }

  /// Upload complete medical backup JSON to Google Drive
  Future<bool> uploadBackup(Map<String, dynamic> backupData) async {
    try {
      final driveApi = await _getDriveApi();
      final folderId = await getOrCreateBackupFolder();

      final jsonContent = jsonEncode(backupData);
      final bytes = utf8.encode(jsonContent);
      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/json',
      );

      if (driveApi != null && folderId != null && folderId != 'local_mock_folder_id') {
        // Check if backup file already exists
        final existingFiles = await driveApi.files.list(
          q: "name = '$backupFileName' and '$folderId' in parents and trashed = false",
          $fields: 'files(id, name)',
        );

        if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
          final fileId = existingFiles.files!.first.id!;
          await driveApi.files.update(
            drive.File(),
            fileId,
            uploadMedia: media,
          );
        } else {
          final driveFile = drive.File()
            ..name = backupFileName
            ..parents = [folderId]
            ..mimeType = 'application/json';

          await driveApi.files.create(
            driveFile,
            uploadMedia: media,
          );
        }
      }

      // Save local backup snapshot in SharedPreferences as offline fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_backup_snapshot', jsonContent);
      await prefs.setString('last_drive_sync_timestamp', DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      // Save local offline copy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_backup_snapshot', jsonEncode(backupData));
      return false;
    }
  }

  /// Download and restore latest backup from Google Drive
  Future<Map<String, dynamic>?> downloadLatestBackup() async {
    try {
      final driveApi = await _getDriveApi();
      final folderId = await getOrCreateBackupFolder();

      if (driveApi != null && folderId != null && folderId != 'local_mock_folder_id') {
        final existingFiles = await driveApi.files.list(
          q: "name = '$backupFileName' and '$folderId' in parents and trashed = false",
          $fields: 'files(id, name)',
        );

        if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
          final fileId = existingFiles.files!.first.id!;
          final media = await driveApi.files.get(
            fileId,
            downloadOptions: drive.DownloadOptions.fullMedia,
          ) as drive.Media;

          final List<int> dataStore = [];
          await for (final data in media.stream) {
            dataStore.addAll(data);
          }
          final decoded = utf8.decode(dataStore);
          return jsonDecode(decoded) as Map<String, dynamic>;
        }
      }

      // Check offline backup snapshot
      final prefs = await SharedPreferences.getInstance();
      final snapshot = prefs.getString('offline_backup_snapshot');
      if (snapshot != null) {
        return jsonDecode(snapshot) as Map<String, dynamic>;
      }
    } catch (e) {
      // Check offline backup snapshot
      final prefs = await SharedPreferences.getInstance();
      final snapshot = prefs.getString('offline_backup_snapshot');
      if (snapshot != null) {
        return jsonDecode(snapshot) as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('last_drive_sync_timestamp');
    if (timeStr != null) {
      return DateTime.tryParse(timeStr);
    }
    return null;
  }
}

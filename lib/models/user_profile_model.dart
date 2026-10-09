import 'dart:convert';

class UserProfileModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isDriveBackupEnabled;
  final String? driveFolderId;
  final DateTime? lastSyncedAt;

  UserProfileModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.isDriveBackupEnabled = true,
    this.driveFolderId,
    this.lastSyncedAt,
  });

  UserProfileModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isDriveBackupEnabled,
    String? driveFolderId,
    DateTime? lastSyncedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isDriveBackupEnabled: isDriveBackupEnabled ?? this.isDriveBackupEnabled,
      driveFolderId: driveFolderId ?? this.driveFolderId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'photo_url': photoUrl,
      'is_drive_backup_enabled': isDriveBackupEnabled ? 1 : 0,
      'drive_folder_id': driveFolderId,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      photoUrl: map['photo_url'] as String?,
      isDriveBackupEnabled: (map['is_drive_backup_enabled'] == 1 || map['is_drive_backup_enabled'] == true),
      driveFolderId: map['drive_folder_id'] as String?,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromJson(String source) =>
      UserProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

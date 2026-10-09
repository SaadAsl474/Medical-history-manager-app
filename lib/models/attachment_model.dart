import 'dart:convert';

class AttachmentModel {
  final String id;
  final String visitId;
  final String title;
  final String type; // 'prescription', 'lab_report', 'pdf', 'photo'
  final String localPath;
  final String? driveFileId;
  final DateTime createdAt;

  AttachmentModel({
    required this.id,
    required this.visitId,
    required this.title,
    required this.type,
    required this.localPath,
    this.driveFileId,
    required this.createdAt,
  });

  AttachmentModel copyWith({
    String? id,
    String? visitId,
    String? title,
    String? type,
    String? localPath,
    String? driveFileId,
    DateTime? createdAt,
  }) {
    return AttachmentModel(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      title: title ?? this.title,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      driveFileId: driveFileId ?? this.driveFileId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visit_id': visitId,
      'title': title,
      'type': type,
      'local_path': localPath,
      'drive_file_id': driveFileId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      id: map['id'] as String,
      visitId: map['visit_id'] as String,
      title: map['title'] as String? ?? 'Medical Document',
      type: map['type'] as String? ?? 'photo',
      localPath: map['local_path'] as String? ?? '',
      driveFileId: map['drive_file_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AttachmentModel.fromJson(String source) =>
      AttachmentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

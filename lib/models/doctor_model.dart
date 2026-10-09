import 'dart:convert';

class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String phone;
  final String? doctorPhoto;
  final String hospitalName;
  final String? hospitalPhoto;
  final String hospitalAddress;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    this.doctorPhoto,
    required this.hospitalName,
    this.hospitalPhoto,
    required this.hospitalAddress,
    this.latitude,
    this.longitude,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialization,
    String? phone,
    String? doctorPhoto,
    String? hospitalName,
    String? hospitalPhoto,
    String? hospitalAddress,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      phone: phone ?? this.phone,
      doctorPhoto: doctorPhoto ?? this.doctorPhoto,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalPhoto: hospitalPhoto ?? this.hospitalPhoto,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'phone': phone,
      'doctor_photo': doctorPhoto,
      'hospital_name': hospitalName,
      'hospital_photo': hospitalPhoto,
      'hospital_address': hospitalAddress,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] as String,
      name: map['name'] as String,
      specialization: map['specialization'] as String? ?? 'General Physician',
      phone: map['phone'] as String? ?? '',
      doctorPhoto: map['doctor_photo'] as String?,
      hospitalName: map['hospital_name'] as String? ?? '',
      hospitalPhoto: map['hospital_photo'] as String?,
      hospitalAddress: map['hospital_address'] as String? ?? '',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DoctorModel.fromJson(String source) =>
      DoctorModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

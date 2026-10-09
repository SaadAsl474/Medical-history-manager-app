
import 'doctor_model.dart';
import 'medicine_model.dart';
import 'medical_test_model.dart';
import 'attachment_model.dart';

class VisitModel {
  final String id;
  final String doctorId;
  final DateTime visitDate;
  final String visitTime;
  final String symptoms;
  final String diagnosis;
  final String? doctorNotes;
  final DateTime? followUpDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined / Relational entities
  final DoctorModel? doctor;
  final List<MedicineModel> medicines;
  final List<MedicalTestModel> tests;
  final List<AttachmentModel> attachments;

  VisitModel({
    required this.id,
    required this.doctorId,
    required this.visitDate,
    required this.visitTime,
    required this.symptoms,
    required this.diagnosis,
    this.doctorNotes,
    this.followUpDate,
    required this.createdAt,
    required this.updatedAt,
    this.doctor,
    this.medicines = const [],
    this.tests = const [],
    this.attachments = const [],
  });

  VisitModel copyWith({
    String? id,
    String? doctorId,
    DateTime? visitDate,
    String? visitTime,
    String? symptoms,
    String? diagnosis,
    String? doctorNotes,
    DateTime? followUpDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DoctorModel? doctor,
    List<MedicineModel>? medicines,
    List<MedicalTestModel>? tests,
    List<AttachmentModel>? attachments,
  }) {
    return VisitModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      visitDate: visitDate ?? this.visitDate,
      visitTime: visitTime ?? this.visitTime,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      followUpDate: followUpDate ?? this.followUpDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      doctor: doctor ?? this.doctor,
      medicines: medicines ?? this.medicines,
      tests: tests ?? this.tests,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'visit_date': visitDate.toIso8601String(),
      'visit_time': visitTime,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'doctor_notes': doctorNotes,
      'follow_up_date': followUpDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VisitModel.fromMap(
    Map<String, dynamic> map, {
    DoctorModel? doctor,
    List<MedicineModel> medicines = const [],
    List<MedicalTestModel> tests = const [],
    List<AttachmentModel> attachments = const [],
  }) {
    return VisitModel(
      id: map['id'] as String,
      doctorId: map['doctor_id'] as String,
      visitDate: map['visit_date'] != null
          ? DateTime.parse(map['visit_date'] as String)
          : DateTime.now(),
      visitTime: map['visit_time'] as String? ?? '10:00 AM',
      symptoms: map['symptoms'] as String? ?? '',
      diagnosis: map['diagnosis'] as String? ?? '',
      doctorNotes: map['doctor_notes'] as String?,
      followUpDate: map['follow_up_date'] != null
          ? DateTime.parse(map['follow_up_date'] as String)
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
      doctor: doctor,
      medicines: medicines,
      tests: tests,
      attachments: attachments,
    );
  }

  Map<String, dynamic> toFullJsonMap() {
    return {
      'visit': toMap(),
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'tests': tests.map((t) => t.toMap()).toList(),
      'attachments': attachments.map((a) => a.toMap()).toList(),
    };
  }
}

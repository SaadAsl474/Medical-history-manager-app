import 'dart:convert';

class MedicineModel {
  final String id;
  final String visitId;
  final String name;
  final String dosage;
  final String frequency; // e.g. "Twice a day", "Every 8 hours", "1-0-1"
  final String duration;  // e.g. "5 days", "1 month"
  final String? instructions; // e.g. "After meals"

  MedicineModel({
    required this.id,
    required this.visitId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  MedicineModel copyWith({
    String? id,
    String? visitId,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visit_id': visitId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] as String,
      visitId: map['visit_id'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      instructions: map['instructions'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicineModel.fromJson(String source) =>
      MedicineModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

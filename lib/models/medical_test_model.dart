import 'dart:convert';

class MedicalTestModel {
  final String id;
  final String visitId;
  final String testName;
  final DateTime? testDate;
  final String? resultNotes;
  final bool isCompleted;

  MedicalTestModel({
    required this.id,
    required this.visitId,
    required this.testName,
    this.testDate,
    this.resultNotes,
    this.isCompleted = false,
  });

  MedicalTestModel copyWith({
    String? id,
    String? visitId,
    String? testName,
    DateTime? testDate,
    String? resultNotes,
    bool? isCompleted,
  }) {
    return MedicalTestModel(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      testName: testName ?? this.testName,
      testDate: testDate ?? this.testDate,
      resultNotes: resultNotes ?? this.resultNotes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visit_id': visitId,
      'test_name': testName,
      'test_date': testDate?.toIso8601String(),
      'result_notes': resultNotes,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory MedicalTestModel.fromMap(Map<String, dynamic> map) {
    return MedicalTestModel(
      id: map['id'] as String,
      visitId: map['visit_id'] as String,
      testName: map['test_name'] as String,
      testDate: map['test_date'] != null
          ? DateTime.parse(map['test_date'] as String)
          : null,
      resultNotes: map['result_notes'] as String?,
      isCompleted: (map['is_completed'] == 1 || map['is_completed'] == true),
    );
  }

  String toJson() => json.encode(toMap());

  factory MedicalTestModel.fromJson(String source) =>
      MedicalTestModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

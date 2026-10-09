import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../models/doctor_model.dart';
import '../../models/visit_model.dart';
import '../../models/medicine_model.dart';
import '../../models/medical_test_model.dart';
import '../../models/attachment_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('my_medical_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Doctors table (Doctor is created once and holds unlimited visits)
    await db.execute('''
      CREATE TABLE doctors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        specialization TEXT NOT NULL,
        phone TEXT,
        doctor_photo TEXT,
        hospital_name TEXT NOT NULL,
        hospital_photo TEXT,
        hospital_address TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Visits table (Linked to Doctor)
    await db.execute('''
      CREATE TABLE visits (
        id TEXT PRIMARY KEY,
        doctor_id TEXT NOT NULL,
        visit_date TEXT NOT NULL,
        visit_time TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        doctor_notes TEXT,
        follow_up_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (doctor_id) REFERENCES doctors (id) ON DELETE RESTRICT
      )
    ''');

    // 3. Medicines table (Linked to Visit)
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        visit_id TEXT NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT,
        frequency TEXT,
        duration TEXT,
        instructions TEXT,
        FOREIGN KEY (visit_id) REFERENCES visits (id) ON DELETE CASCADE
      )
    ''');

    // 4. Medical Tests table (Linked to Visit)
    await db.execute('''
      CREATE TABLE medical_tests (
        id TEXT PRIMARY KEY,
        visit_id TEXT NOT NULL,
        test_name TEXT NOT NULL,
        test_date TEXT,
        result_notes TEXT,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY (visit_id) REFERENCES visits (id) ON DELETE CASCADE
      )
    ''');

    // 5. Attachments table (Prescriptions, Lab Reports, PDFs, Photos)
    await db.execute('''
      CREATE TABLE attachments (
        id TEXT PRIMARY KEY,
        visit_id TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        local_path TEXT NOT NULL,
        drive_file_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (visit_id) REFERENCES visits (id) ON DELETE CASCADE
      )
    ''');

    // 6. Offline Sync Queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ==========================================
  // DOCTOR OPERATIONS
  // ==========================================

  Future<int> insertDoctor(DoctorModel doctor) async {
    final db = await instance.database;
    return await db.insert('doctors', doctor.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateDoctor(DoctorModel doctor) async {
    final db = await instance.database;
    return await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return DoctorModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DoctorModel>> getAllDoctors() async {
    final db = await instance.database;
    final result = await db.query('doctors', orderBy: 'name ASC');
    return result.map((json) => DoctorModel.fromMap(json)).toList();
  }

  Future<int> deleteDoctor(String id) async {
    final db = await instance.database;
    // Check if any visits exist
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM visits WHERE doctor_id = ?',
      [id],
    ));
    if ((count ?? 0) > 0) {
      throw Exception('Cannot delete doctor with existing visits.');
    }
    return await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // VISIT OPERATIONS (Relational with Cascade)
  // ==========================================

  Future<void> insertVisit(VisitModel visit) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert('visits', visit.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      for (final med in visit.medicines) {
        await txn.insert('medicines', med.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (final test in visit.tests) {
        await txn.insert('medical_tests', test.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (final att in visit.attachments) {
        await txn.insert('attachments', att.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> updateVisit(VisitModel visit) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'visits',
        visit.toMap(),
        where: 'id = ?',
        whereArgs: [visit.id],
      );

      // Refresh medicines
      await txn.delete('medicines', where: 'visit_id = ?', whereArgs: [visit.id]);
      for (final med in visit.medicines) {
        await txn.insert('medicines', med.toMap());
      }

      // Refresh tests
      await txn.delete('medical_tests', where: 'visit_id = ?', whereArgs: [visit.id]);
      for (final test in visit.tests) {
        await txn.insert('medical_tests', test.toMap());
      }

      // Refresh attachments
      await txn.delete('attachments', where: 'visit_id = ?', whereArgs: [visit.id]);
      for (final att in visit.attachments) {
        await txn.insert('attachments', att.toMap());
      }
    });
  }

  Future<int> deleteVisit(String visitId) async {
    final db = await instance.database;
    // Medicines, tests, attachments will delete via ON DELETE CASCADE
    return await db.delete('visits', where: 'id = ?', whereArgs: [visitId]);
  }

  Future<VisitModel?> getVisitById(String id) async {
    final db = await instance.database;
    final visitRows = await db.query('visits', where: 'id = ?', whereArgs: [id]);
    if (visitRows.isEmpty) return null;

    final visitMap = visitRows.first;
    final doctorId = visitMap['doctor_id'] as String;
    final doctor = await getDoctorById(doctorId);

    final medicinesRows = await db.query('medicines', where: 'visit_id = ?', whereArgs: [id]);
    final medicines = medicinesRows.map((m) => MedicineModel.fromMap(m)).toList();

    final testRows = await db.query('medical_tests', where: 'visit_id = ?', whereArgs: [id]);
    final tests = testRows.map((t) => MedicalTestModel.fromMap(t)).toList();

    final attachRows = await db.query('attachments', where: 'visit_id = ?', whereArgs: [id]);
    final attachments = attachRows.map((a) => AttachmentModel.fromMap(a)).toList();

    return VisitModel.fromMap(
      visitMap,
      doctor: doctor,
      medicines: medicines,
      tests: tests,
      attachments: attachments,
    );
  }

  Future<List<VisitModel>> getAllVisits() async {
    final db = await instance.database;
    final visitRows = await db.query('visits', orderBy: 'visit_date DESC, created_at DESC');
    return await _populateVisits(visitRows);
  }

  Future<List<VisitModel>> getVisitsByDoctor(String doctorId) async {
    final db = await instance.database;
    final visitRows = await db.query(
      'visits',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'visit_date DESC',
    );
    return await _populateVisits(visitRows);
  }

  Future<List<VisitModel>> getUpcomingFollowUps() async {
    final db = await instance.database;
    final nowStr = DateTime.now().toIso8601String().substring(0, 10);
    final visitRows = await db.rawQuery('''
      SELECT * FROM visits 
      WHERE follow_up_date IS NOT NULL AND follow_up_date >= ?
      ORDER BY follow_up_date ASC
      LIMIT 5
    ''', [nowStr]);
    return await _populateVisits(visitRows);
  }

  // ==========================================
  // GLOBAL SEARCH & FILTER
  // ==========================================

  /// Global Search across Doctor, Hospital, Diagnosis, Symptoms, Medicine, and Test Name
  Future<List<VisitModel>> searchVisits(String query) async {
    final db = await instance.database;
    final cleanQuery = '%${query.trim()}%';

    final result = await db.rawQuery('''
      SELECT DISTINCT v.* FROM visits v
      LEFT JOIN doctors d ON v.doctor_id = d.id
      LEFT JOIN medicines m ON v.id = m.visit_id
      LEFT JOIN medical_tests t ON v.id = t.visit_id
      WHERE d.name LIKE ?
         OR d.hospital_name LIKE ?
         OR v.diagnosis LIKE ?
         OR v.symptoms LIKE ?
         OR m.name LIKE ?
         OR t.test_name LIKE ?
         OR v.visit_date LIKE ?
      ORDER BY v.visit_date DESC
    ''', [
      cleanQuery,
      cleanQuery,
      cleanQuery,
      cleanQuery,
      cleanQuery,
      cleanQuery,
      cleanQuery,
    ]);

    return await _populateVisits(result);
  }

  /// Advanced Filtering by Date Range, Doctor, Hospital, Diagnosis, Medicine, Test
  Future<List<VisitModel>> filterVisits({
    DateTime? startDate,
    DateTime? endDate,
    String? doctorId,
    String? hospitalName,
    String? diagnosis,
    String? medicineName,
    String? testName,
  }) async {
    final db = await instance.database;
    List<String> conditions = [];
    List<dynamic> args = [];

    if (startDate != null) {
      conditions.add('v.visit_date >= ?');
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      conditions.add('v.visit_date <= ?');
      args.add(endDate.toIso8601String());
    }
    if (doctorId != null && doctorId.isNotEmpty) {
      conditions.add('v.doctor_id = ?');
      args.add(doctorId);
    }
    if (hospitalName != null && hospitalName.isNotEmpty) {
      conditions.add('d.hospital_name LIKE ?');
      args.add('%$hospitalName%');
    }
    if (diagnosis != null && diagnosis.isNotEmpty) {
      conditions.add('v.diagnosis LIKE ?');
      args.add('%$diagnosis%');
    }
    if (medicineName != null && medicineName.isNotEmpty) {
      conditions.add('m.name LIKE ?');
      args.add('%$medicineName%');
    }
    if (testName != null && testName.isNotEmpty) {
      conditions.add('t.test_name LIKE ?');
      args.add('%$testName%');
    }

    String whereClause = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final result = await db.rawQuery('''
      SELECT DISTINCT v.* FROM visits v
      LEFT JOIN doctors d ON v.doctor_id = d.id
      LEFT JOIN medicines m ON v.id = m.visit_id
      LEFT JOIN medical_tests t ON v.id = t.visit_id
      $whereClause
      ORDER BY v.visit_date DESC
    ''', args);

    return await _populateVisits(result);
  }

  // ==========================================
  // DASHBOARD AGGREGATE STATS
  // ==========================================

  Future<Map<String, int>> getDashboardStats() async {
    final db = await instance.database;
    final totalDoctors = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM doctors')) ?? 0;
    final totalVisits = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM visits')) ?? 0;
    final totalMedicines = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM medicines')) ?? 0;
    final totalReports = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM attachments')) ?? 0;

    return {
      'totalDoctors': totalDoctors,
      'totalVisits': totalVisits,
      'totalMedicines': totalMedicines,
      'totalReports': totalReports,
    };
  }

  // ==========================================
  // EXPORT & RESTORE BACKUP
  // ==========================================

  Future<Map<String, dynamic>> exportAllData() async {
    final db = await instance.database;
    final doctors = await db.query('doctors');
    final visits = await db.query('visits');
    final medicines = await db.query('medicines');
    final tests = await db.query('medical_tests');
    final attachments = await db.query('attachments');

    return {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'doctors': doctors,
      'visits': visits,
      'medicines': medicines,
      'tests': tests,
      'attachments': attachments,
    };
  }

  Future<void> restoreFromData(Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      if (data['doctors'] != null) {
        for (final doc in data['doctors']) {
          await txn.insert('doctors', doc, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['visits'] != null) {
        for (final v in data['visits']) {
          await txn.insert('visits', v, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['medicines'] != null) {
        for (final m in data['medicines']) {
          await txn.insert('medicines', m, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['tests'] != null) {
        for (final t in data['tests']) {
          await txn.insert('medical_tests', t, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      if (data['attachments'] != null) {
        for (final a in data['attachments']) {
          await txn.insert('attachments', a, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  // ==========================================
  // HELPERS
  // ==========================================

  Future<List<VisitModel>> _populateVisits(List<Map<String, dynamic>> visitRows) async {
    final db = await instance.database;
    List<VisitModel> list = [];

    // Pre-cache doctors to avoid N+1 queries
    final allDoctors = await getAllDoctors();
    final doctorMap = {for (var d in allDoctors) d.id: d};

    for (final row in visitRows) {
      final vId = row['id'] as String;
      final docId = row['doctor_id'] as String;

      final medRows = await db.query('medicines', where: 'visit_id = ?', whereArgs: [vId]);
      final meds = medRows.map((m) => MedicineModel.fromMap(m)).toList();

      final tRows = await db.query('medical_tests', where: 'visit_id = ?', whereArgs: [vId]);
      final tests = tRows.map((t) => MedicalTestModel.fromMap(t)).toList();

      final aRows = await db.query('attachments', where: 'visit_id = ?', whereArgs: [vId]);
      final attachments = aRows.map((a) => AttachmentModel.fromMap(a)).toList();

      list.add(VisitModel.fromMap(
        row,
        doctor: doctorMap[docId],
        medicines: meds,
        tests: tests,
        attachments: attachments,
      ));
    }

    return list;
  }
}

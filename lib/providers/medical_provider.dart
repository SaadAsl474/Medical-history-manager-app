import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../core/services/sync_manager.dart';
import '../models/doctor_model.dart';
import '../models/visit_model.dart';
import '../models/medicine_model.dart';
import '../models/medical_test_model.dart';
import '../models/attachment_model.dart';

class MedicalProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SyncManager _syncManager = SyncManager();
  final Uuid _uuid = const Uuid();

  List<DoctorModel> _doctors = [];
  List<VisitModel> _visits = [];
  List<VisitModel> _upcomingFollowUps = [];
  List<VisitModel> _searchResults = [];
  Map<String, int> _dashboardStats = {
    'totalDoctors': 0,
    'totalVisits': 0,
    'totalMedicines': 0,
    'totalReports': 0,
  };

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _isSearching = false;

  // Filter criteria
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterDoctorId;
  String? _filterHospital;
  String? _filterDiagnosis;
  String? _filterMedicine;
  String? _filterTest;

  List<DoctorModel> get doctors => _doctors;
  List<VisitModel> get visits => _visits;
  List<VisitModel> get upcomingFollowUps => _upcomingFollowUps;
  List<VisitModel> get searchResults => _searchResults;
  Map<String, int> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  String? get filterDoctorId => _filterDoctorId;
  String? get filterHospital => _filterHospital;
  String? get filterDiagnosis => _filterDiagnosis;
  String? get filterMedicine => _filterMedicine;
  String? get filterTest => _filterTest;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _syncManager.initialize();
      final existingDocs = await _dbHelper.getAllDoctors();
      if (existingDocs.isEmpty) {
        await _seedInitialData();
      }
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _doctors = await _dbHelper.getAllDoctors();
    _visits = await _dbHelper.getAllVisits();
    _upcomingFollowUps = await _dbHelper.getUpcomingFollowUps();
    _dashboardStats = await _dbHelper.getDashboardStats();
    notifyListeners();
  }

  // ==========================================
  // DOCTOR OPERATIONS
  // ==========================================

  Future<bool> addDoctor(DoctorModel doctor) async {
    try {
      await _dbHelper.insertDoctor(doctor);
      await refreshAll();
      _syncManager.triggerSync();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDoctor(DoctorModel doctor) async {
    try {
      await _dbHelper.updateDoctor(doctor);
      await refreshAll();
      _syncManager.triggerSync();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDoctor(String id) async {
    try {
      await _dbHelper.deleteDoctor(id);
      await refreshAll();
      _syncManager.triggerSync();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  DoctorModel? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // VISIT OPERATIONS (Relational with Cascade)
  // ==========================================

  Future<bool> addVisit(VisitModel visit) async {
    try {
      await _dbHelper.insertVisit(visit);
      await refreshAll();
      _syncManager.triggerSync();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVisit(VisitModel visit) async {
    try {
      await _dbHelper.updateVisit(visit);
      await refreshAll();
      _syncManager.triggerSync();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVisit(String visitId) async {
    try {
      await _dbHelper.deleteVisit(visitId);
      await refreshAll();
      _syncManager.triggerSync();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<VisitModel>> getVisitsForDoctor(String doctorId) async {
    return await _dbHelper.getVisitsByDoctor(doctorId);
  }

  // ==========================================
  // SEARCH & FILTER
  // ==========================================

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _dbHelper.searchVisits(_searchQuery);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? doctorId,
    String? hospital,
    String? diagnosis,
    String? medicine,
    String? test,
  }) async {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _filterDoctorId = doctorId;
    _filterHospital = hospital;
    _filterDiagnosis = diagnosis;
    _filterMedicine = medicine;
    _filterTest = test;

    _isSearching = true;
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _dbHelper.filterVisits(
        startDate: startDate,
        endDate: endDate,
        doctorId: doctorId,
        hospitalName: hospital,
        diagnosis: diagnosis,
        medicineName: medicine,
        testName: test,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearFilters() {
    _filterStartDate = null;
    _filterEndDate = null;
    _filterDoctorId = null;
    _filterHospital = null;
    _filterDiagnosis = null;
    _filterMedicine = null;
    _filterTest = null;
    _searchQuery = '';
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }

  // ==========================================
  // EXPORT & RESTORE
  // ==========================================

  Future<Map<String, dynamic>> exportData() async {
    return await _dbHelper.exportAllData();
  }

  Future<bool> restoreData(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbHelper.restoreFromData(data);
      await refreshAll();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==========================================
  // INITIAL SEED DATA
  // ==========================================

  Future<void> _seedInitialData() async {
    final doc1Id = _uuid.v4();
    final doc2Id = _uuid.v4();
    final doc3Id = _uuid.v4();

    final doc1 = DoctorModel(
      id: doc1Id,
      name: 'Dr. Ahmed Khan',
      specialization: 'Cardiologist',
      phone: '+1 415 555 0192',
      hospitalName: 'St. Jude Heart Institute',
      hospitalAddress: '742 Evergreen Terrace, Medical District',
      latitude: 37.7749,
      longitude: -122.4194,
      notes: 'Consultation for hypertension & routine ECG assessment.',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 90)),
    );

    final doc2 = DoctorModel(
      id: doc2Id,
      name: 'Dr. Sarah Jenkins',
      specialization: 'Internal Medicine',
      phone: '+1 415 555 0148',
      hospitalName: 'City General Care Hospital',
      hospitalAddress: '100 Medical Center Blvd, Suite 400',
      latitude: 37.7833,
      longitude: -122.4167,
      notes: 'Primary care physician for seasonal checkups.',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 120)),
    );

    final doc3 = DoctorModel(
      id: doc3Id,
      name: 'Dr. Michael Chen',
      specialization: 'Pulmonologist',
      phone: '+1 415 555 0183',
      hospitalName: 'Metro Pulmonary Clinic',
      hospitalAddress: '250 Bay Area Health Plaza',
      latitude: 37.7699,
      longitude: -122.4469,
      notes: 'Asthma and seasonal allergy management.',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 60)),
    );

    await _dbHelper.insertDoctor(doc1);
    await _dbHelper.insertDoctor(doc2);
    await _dbHelper.insertDoctor(doc3);

    // Seed Visit 1 for Dr. Ahmed Khan
    final v1Id = _uuid.v4();
    final visit1 = VisitModel(
      id: v1Id,
      doctorId: doc1Id,
      visitDate: DateTime.now().subtract(const Duration(days: 14)),
      visitTime: '10:30 AM',
      symptoms: 'Mild chest tightness after exercise, elevated resting blood pressure.',
      diagnosis: 'Stage 1 Hypertension & Mild Fatigue',
      doctorNotes: 'Monitor salt intake. Recommended 30 mins aerobic walking daily.',
      followUpDate: DateTime.now().add(const Duration(days: 16)),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      medicines: [
        MedicineModel(
          id: _uuid.v4(),
          visitId: v1Id,
          name: 'Amlodipine',
          dosage: '5mg',
          frequency: 'Once daily (morning)',
          duration: '30 days',
          instructions: 'Take after breakfast',
        ),
        MedicineModel(
          id: _uuid.v4(),
          visitId: v1Id,
          name: 'Panadol',
          dosage: '500mg',
          frequency: 'As needed',
          duration: '5 days',
          instructions: 'For occasional tension headache',
        ),
      ],
      tests: [
        MedicalTestModel(
          id: _uuid.v4(),
          visitId: v1Id,
          testName: 'Lipid Profile & Serum Electrolytes',
          testDate: DateTime.now().subtract(const Duration(days: 13)),
          resultNotes: 'Cholesterol slightly elevated at 210 mg/dL.',
          isCompleted: true,
        ),
        MedicalTestModel(
          id: _uuid.v4(),
          visitId: v1Id,
          testName: '12-Lead Electrocardiogram (ECG)',
          testDate: DateTime.now().subtract(const Duration(days: 14)),
          resultNotes: 'Normal sinus rhythm, no ischemic ST changes.',
          isCompleted: true,
        ),
      ],
      attachments: [
        AttachmentModel(
          id: _uuid.v4(),
          visitId: v1Id,
          title: 'Dr. Ahmed Khan Prescription',
          type: 'prescription',
          localPath: 'assets/sample_prescription.jpg',
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        AttachmentModel(
          id: _uuid.v4(),
          visitId: v1Id,
          title: 'ECG Report PDF',
          type: 'pdf',
          localPath: 'assets/sample_ecg.pdf',
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ],
    );

    // Seed Visit 2 for Dr. Sarah Jenkins
    final v2Id = _uuid.v4();
    final visit2 = VisitModel(
      id: v2Id,
      doctorId: doc2Id,
      visitDate: DateTime.now().subtract(const Duration(days: 45)),
      visitTime: '02:15 PM',
      symptoms: 'Sore throat, fever (101°F), persistent dry cough.',
      diagnosis: 'Acute Viral Pharyngitis',
      doctorNotes: 'Keep hydrated, warm saline gargles 3 times a day.',
      followUpDate: null,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      medicines: [
        MedicineModel(
          id: _uuid.v4(),
          visitId: v2Id,
          name: 'Panadol Extra',
          dosage: '500mg/65mg',
          frequency: 'Every 8 hours',
          duration: '3 days',
          instructions: 'Take after food for fever control',
        ),
        MedicineModel(
          id: _uuid.v4(),
          visitId: v2Id,
          name: 'Cetirizine',
          dosage: '10mg',
          frequency: 'Once at night',
          duration: '5 days',
          instructions: 'Night time only',
        ),
      ],
      tests: [
        MedicalTestModel(
          id: _uuid.v4(),
          visitId: v2Id,
          testName: 'Complete Blood Count (CBC)',
          testDate: DateTime.now().subtract(const Duration(days: 44)),
          resultNotes: 'Normal leukocyte count, viral etiology confirmed.',
          isCompleted: true,
        ),
      ],
      attachments: [
        AttachmentModel(
          id: _uuid.v4(),
          visitId: v2Id,
          title: 'Lab Blood Work Report',
          type: 'lab_report',
          localPath: 'assets/sample_lab.pdf',
          createdAt: DateTime.now().subtract(const Duration(days: 44)),
        ),
      ],
    );

    await _dbHelper.insertVisit(visit1);
    await _dbHelper.insertVisit(visit2);
  }
}

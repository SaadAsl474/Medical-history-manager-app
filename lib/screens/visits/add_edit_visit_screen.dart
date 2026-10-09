import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/visit_model.dart';
import '../../models/medicine_model.dart';
import '../../models/medical_test_model.dart';
import '../../models/attachment_model.dart';
import '../../providers/medical_provider.dart';
import '../doctors/add_edit_doctor_screen.dart';

class AddEditVisitScreen extends StatefulWidget {
  final VisitModel? visitToEdit;
  final String? preselectedDoctorId;

  const AddEditVisitScreen({
    super.key,
    this.visitToEdit,
    this.preselectedDoctorId,
  });

  @override
  State<AddEditVisitScreen> createState() => _AddEditVisitScreenState();
}

class _AddEditVisitScreenState extends State<AddEditVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  String? _selectedDoctorId;
  DateTime _visitDate = DateTime.now();
  TimeOfDay _visitTime = TimeOfDay.now();
  DateTime? _followUpDate;

  late TextEditingController _symptomsController;
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;

  final List<MedicineModel> _medicines = [];
  final List<MedicalTestModel> _tests = [];
  final List<AttachmentModel> _attachments = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.visitToEdit;

    _selectedDoctorId = v?.doctorId ?? widget.preselectedDoctorId;
    if (v != null) {
      _visitDate = v.visitDate;
      _followUpDate = v.followUpDate;
      _symptomsController = TextEditingController(text: v.symptoms);
      _diagnosisController = TextEditingController(text: v.diagnosis);
      _notesController = TextEditingController(text: v.doctorNotes ?? '');
      _medicines.addAll(v.medicines);
      _tests.addAll(v.tests);
      _attachments.addAll(v.attachments);
    } else {
      _symptomsController = TextEditingController();
      _diagnosisController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(1980),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _pickVisitTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _visitTime,
    );
    if (picked != null) {
      setState(() => _visitTime = picked);
    }
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _followUpDate = picked);
    }
  }

  void _addMedicineDialog([MedicineModel? existing, int? index]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final dosageCtrl = TextEditingController(text: existing?.dosage ?? '');
    final freqCtrl = TextEditingController(text: existing?.frequency ?? '1-0-1');
    final durationCtrl = TextEditingController(text: existing?.duration ?? '5 days');
    final instructCtrl = TextEditingController(text: existing?.instructions ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Medicine' : 'Edit Medicine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Medicine Name *', hintText: 'e.g. Panadol'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dosageCtrl,
                decoration: const InputDecoration(labelText: 'Dosage', hintText: 'e.g. 500mg'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: freqCtrl,
                decoration: const InputDecoration(labelText: 'Frequency', hintText: 'e.g. Twice daily, 1-0-1'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: durationCtrl,
                decoration: const InputDecoration(labelText: 'Duration', hintText: 'e.g. 5 days'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: instructCtrl,
                decoration: const InputDecoration(labelText: 'Instructions', hintText: 'e.g. After meals'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final med = MedicineModel(
                id: existing?.id ?? _uuid.v4(),
                visitId: widget.visitToEdit?.id ?? '',
                name: nameCtrl.text.trim(),
                dosage: dosageCtrl.text.trim(),
                frequency: freqCtrl.text.trim(),
                duration: durationCtrl.text.trim(),
                instructions: instructCtrl.text.trim(),
              );
              setState(() {
                if (index != null) {
                  _medicines[index] = med;
                } else {
                  _medicines.add(med);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addTestDialog([MedicalTestModel? existing, int? index]) {
    final testNameCtrl = TextEditingController(text: existing?.testName ?? '');
    final notesCtrl = TextEditingController(text: existing?.resultNotes ?? '');
    bool isDone = existing?.isCompleted ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text(existing == null ? 'Add Medical Test' : 'Edit Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: testNameCtrl,
                decoration: const InputDecoration(labelText: 'Test Name *', hintText: 'e.g. CBC, Lipid Profile, ECG'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Result / Notes', hintText: 'e.g. Normal, or pending'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Test Completed'),
                value: isDone,
                onChanged: (val) => setDlgState(() => isDone = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (testNameCtrl.text.trim().isEmpty) return;
                final test = MedicalTestModel(
                  id: existing?.id ?? _uuid.v4(),
                  visitId: widget.visitToEdit?.id ?? '',
                  testName: testNameCtrl.text.trim(),
                  resultNotes: notesCtrl.text.trim(),
                  isCompleted: isDone,
                  testDate: DateTime.now(),
                );
                setState(() {
                  if (index != null) {
                    _tests[index] = test;
                  } else {
                    _tests.add(test);
                  }
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureWithCamera() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _attachments.add(AttachmentModel(
            id: _uuid.v4(),
            visitId: widget.visitToEdit?.id ?? '',
            title: 'Prescription Photo',
            type: 'prescription',
            localPath: photo.path,
            createdAt: DateTime.now(),
          ));
        });
      }
    } catch (_) {}
  }

  Future<void> _pickDocumentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;
        final isPdf = name.toLowerCase().endsWith('.pdf');
        setState(() {
          _attachments.add(AttachmentModel(
            id: _uuid.v4(),
            visitId: widget.visitToEdit?.id ?? '',
            title: name,
            type: isPdf ? 'pdf' : 'lab_report',
            localPath: path,
            createdAt: DateTime.now(),
          ));
        });
      }
    } catch (_) {}
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor for this visit')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final medical = Provider.of<MedicalProvider>(context, listen: false);

    final visitId = widget.visitToEdit?.id ?? _uuid.v4();
    final timeStr = _visitTime.format(context);

    // Update visitId across relational entities
    final updatedMeds = _medicines.map((m) => m.copyWith(visitId: visitId)).toList();
    final updatedTests = _tests.map((t) => t.copyWith(visitId: visitId)).toList();
    final updatedAttachments = _attachments.map((a) => a.copyWith(visitId: visitId)).toList();

    final visit = VisitModel(
      id: visitId,
      doctorId: _selectedDoctorId!,
      visitDate: _visitDate,
      visitTime: timeStr,
      symptoms: _symptomsController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      doctorNotes: _notesController.text.trim(),
      followUpDate: _followUpDate,
      createdAt: widget.visitToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      medicines: updatedMeds,
      tests: updatedTests,
      attachments: updatedAttachments,
    );

    bool success;
    if (widget.visitToEdit == null) {
      success = await medical.addVisit(visit);
    } else {
      success = await medical.updateVisit(visit);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medical visit saved and queued for Drive sync!'),
          backgroundColor: AppColors.syncActive,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medical = Provider.of<MedicalProvider>(context);
    final isEditing = widget.visitToEdit != null;
    final dateStr = DateFormat('dd MMM yyyy').format(_visitDate);
    final followUpStr = _followUpDate != null ? DateFormat('dd MMM yyyy').format(_followUpDate!) : 'None';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medical Visit' : 'Log Medical Visit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Doctor Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Doctor *',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditDoctorScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('+ New Doctor'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedDoctorId,
                hint: const Text('Choose Doctor'),
                items: medical.doctors.map((d) {
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text('${d.name} (${d.specialization})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDoctorId = val),
                validator: (val) => val == null ? 'Please select a doctor' : null,
              ),
              const SizedBox(height: 20),

              // 2. Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickVisitDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.surfaceContainer),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Visit Date', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                                Text(dateStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickVisitTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.surfaceContainer),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Visit Time', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                                Text(_visitTime.format(context),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Symptoms & Diagnosis
              const Text(
                'Clinical Details',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis *',
                  hintText: 'e.g. Viral Infection, Stage 1 Hypertension',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter diagnosis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _symptomsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Symptoms *',
                  hintText: 'e.g. High fever, persistent cough, chest tightness',
                  prefixIcon: Icon(Icons.sick_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter symptoms' : null,
              ),
              const SizedBox(height: 24),

              // 4. Prescribed Medicines (Dynamic List)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medication_outlined, size: 20, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'Medicines (${_medicines.length})',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _addMedicineDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+ Add Medicine'),
                  ),
                ],
              ),
              if (_medicines.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No medicines added yet. Tap "+ Add Medicine" to log prescribed drugs.',
                    style: TextStyle(fontSize: 12, color: AppColors.outline),
                  ),
                )
              else
                ..._medicines.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final med = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${med.name} ${med.dosage}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              Text(
                                '${med.frequency} • ${med.duration} • ${med.instructions ?? ""}',
                                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _addMedicineDialog(med, idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () => setState(() => _medicines.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),

              // 5. Medical Tests (Dynamic List)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science_outlined, size: 20, color: AppColors.tertiaryContainer),
                      const SizedBox(width: 6),
                      Text(
                        'Medical Tests (${_tests.length})',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _addTestDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+ Add Test'),
                  ),
                ],
              ),
              if (_tests.isNotEmpty)
                ..._tests.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final test = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          test.isCompleted ? Icons.check_circle : Icons.pending_outlined,
                          color: test.isCompleted ? AppColors.tertiaryContainer : AppColors.outline,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(test.testName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              if (test.resultNotes != null && test.resultNotes!.isNotEmpty)
                                Text(test.resultNotes!, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () => setState(() => _tests.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),

              // 6. Documents & Attachments (Camera, PDF, Reports)
              const Text(
                'Attachments (Prescriptions, PDFs & Reports)',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _captureWithCamera,
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLowest,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _pickDocumentFile,
                    icon: const Icon(Icons.upload_file_outlined, size: 16),
                    label: const Text('PDF / File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerLowest,
                      foregroundColor: AppColors.secondary,
                      elevation: 0,
                      side: const BorderSide(color: AppColors.secondary),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _attachments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final att = entry.value;
                    return Chip(
                      avatar: Icon(
                        att.type == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(att.title, style: const TextStyle(fontSize: 12)),
                      onDeleted: () => setState(() => _attachments.removeAt(idx)),
                      deleteIconColor: AppColors.error,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // 7. Follow-up & Doctor Notes
              InkWell(
                onTap: _pickFollowUpDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceContainer),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_repeat_rounded, color: AppColors.tertiaryContainer),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Next Follow-Up Date', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                              Text(followUpStr, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      if (_followUpDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _followUpDate = null),
                        )
                      else
                        const Icon(Icons.calendar_month, size: 18, color: AppColors.outline),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Doctor Advice & General Notes',
                  hintText: 'e.g. Diet restrictions, exercises, next steps...',
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveVisit,
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white))
                      : Text(
                          isEditing ? 'Save Visit Changes' : 'Record Medical Visit',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

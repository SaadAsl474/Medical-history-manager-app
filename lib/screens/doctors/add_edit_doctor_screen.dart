import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../models/doctor_model.dart';
import '../../providers/medical_provider.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final DoctorModel? doctorToEdit;

  const AddEditDoctorScreen({super.key, this.doctorToEdit});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _specController;
  late TextEditingController _phoneController;
  late TextEditingController _hospitalNameController;
  late TextEditingController _hospitalAddressController;
  late TextEditingController _notesController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  bool _isFetchingGps = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.doctorToEdit;
    _nameController = TextEditingController(text: d?.name ?? '');
    _specController = TextEditingController(text: d?.specialization ?? 'General Physician');
    _phoneController = TextEditingController(text: d?.phone ?? '');
    _hospitalNameController = TextEditingController(text: d?.hospitalName ?? '');
    _hospitalAddressController = TextEditingController(text: d?.hospitalAddress ?? '');
    _notesController = TextEditingController(text: d?.notes ?? '');
    _latController = TextEditingController(text: d?.latitude != null ? d!.latitude.toString() : '');
    _lngController = TextEditingController(text: d?.longitude != null ? d!.longitude.toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specController.dispose();
    _phoneController.dispose();
    _hospitalNameController.dispose();
    _hospitalAddressController.dispose();
    _notesController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingGps = true);
    final pos = await LocationService().getCurrentLocation();
    setState(() => _isFetchingGps = false);

    if (pos != null) {
      _latController.text = pos.latitude.toStringAsFixed(6);
      _lngController.text = pos.longitude.toStringAsFixed(6);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS Coordinates captured successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not fetch GPS. Please check location permissions.')),
      );
    }
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final medical = Provider.of<MedicalProvider>(context, listen: false);

    final double? lat = double.tryParse(_latController.text.trim());
    final double? lng = double.tryParse(_lngController.text.trim());

    if (widget.doctorToEdit == null) {
      // Create new doctor profile (created once)
      final newDoctor = DoctorModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        specialization: _specController.text.trim(),
        phone: _phoneController.text.trim(),
        hospitalName: _hospitalNameController.text.trim(),
        hospitalAddress: _hospitalAddressController.text.trim(),
        latitude: lat,
        longitude: lng,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await medical.addDoctor(newDoctor);
      setState(() => _isSaving = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor profile created successfully!'),
            backgroundColor: AppColors.syncActive,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      // Edit existing doctor profile
      final updated = widget.doctorToEdit!.copyWith(
        name: _nameController.text.trim(),
        specialization: _specController.text.trim(),
        phone: _phoneController.text.trim(),
        hospitalName: _hospitalNameController.text.trim(),
        hospitalAddress: _hospitalAddressController.text.trim(),
        latitude: lat,
        longitude: lng,
        notes: _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final success = await medical.updateDoctor(updated);
      setState(() => _isSaving = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor profile updated!'),
            backgroundColor: AppColors.syncActive,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.doctorToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Doctor Profile' : 'New Doctor Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'A Doctor profile is created once and can hold unlimited visits over many years.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section: Doctor Details
              const Text(
                'Doctor Information',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name *',
                  hintText: 'e.g. Dr. Ahmed Khan',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter doctor name' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _specController,
                decoration: const InputDecoration(
                  labelText: 'Specialization *',
                  hintText: 'e.g. Cardiologist, Dermatologist',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter specialization' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. +1 415 555 0192',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Section: Hospital Details
              const Text(
                'Hospital / Clinic Information',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _hospitalNameController,
                decoration: const InputDecoration(
                  labelText: 'Hospital or Clinic Name *',
                  hintText: 'e.g. St. Jude Heart Institute',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter hospital name' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _hospitalAddressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Hospital Address *',
                  hintText: 'e.g. 742 Evergreen Terrace, Medical District',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter address' : null,
              ),
              const SizedBox(height: 14),

              // GPS Coordinates Row & Fetch Button
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '37.7749',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '-122.4194',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _isFetchingGps ? null : _fetchCurrentLocation,
                    icon: _isFetchingGps
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location),
                    tooltip: 'Pin Current GPS',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Section: Notes
              const Text(
                'Personal Notes',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add consultation schedule, operating days, fee details, etc.',
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDoctor,
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white))
                      : Text(
                          isEditing ? 'Save Changes' : 'Create Doctor Profile',
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

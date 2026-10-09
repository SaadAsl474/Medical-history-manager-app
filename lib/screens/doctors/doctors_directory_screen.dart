import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/medical_provider.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state_view.dart';
import 'add_edit_doctor_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorsDirectoryScreen extends StatefulWidget {
  const DoctorsDirectoryScreen({super.key});

  @override
  State<DoctorsDirectoryScreen> createState() => _DoctorsDirectoryScreenState();
}

class _DoctorsDirectoryScreenState extends State<DoctorsDirectoryScreen> {
  String _searchFilter = '';
  String _selectedSpecialty = 'All';

  final List<String> _specialties = [
    'All',
    'Cardiologist',
    'Internal Medicine',
    'Pulmonologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic',
  ];

  @override
  Widget build(BuildContext context) {
    final medical = Provider.of<MedicalProvider>(context);

    final filteredDoctors = medical.doctors.where((doc) {
      final matchesSearch = doc.name.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          doc.specialization.toLowerCase().contains(_searchFilter.toLowerCase()) ||
          doc.hospitalName.toLowerCase().contains(_searchFilter.toLowerCase());

      final matchesSpecialty = _selectedSpecialty == 'All' ||
          doc.specialization.toLowerCase().contains(_selectedSpecialty.toLowerCase());

      return matchesSearch && matchesSpecialty;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Doctors Directory'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditDoctorScreen()),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            tooltip: 'Add Doctor Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchFilter = val),
              decoration: InputDecoration(
                hintText: 'Search doctors, clinic, or specialty...',
                prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
                suffixIcon: _searchFilter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchFilter = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Specialty Filter Pills
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final specialty = _specialties[index];
                final isSelected = specialty == _selectedSpecialty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedSpecialty = specialty);
                    },
                    backgroundColor: AppColors.surfaceContainerLowest,
                    selectedColor: AppColors.primaryFixed,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Doctor List
          Expanded(
            child: filteredDoctors.isEmpty
                ? EmptyStateView(
                    icon: Icons.person_off_outlined,
                    title: 'No Doctors Found',
                    subtitle: 'Add a doctor profile once and record multiple visits under them.',
                    buttonText: 'Add Doctor',
                    onButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditDoctorScreen()),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDoctors[index];
                      final docVisits = medical.visits.where((v) => v.doctorId == doc.id).length;
                      return DoctorCard(
                        doctor: doc,
                        totalVisits: docVisits,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorProfileScreen(doctorId: doc.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDoctorScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Doctor',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

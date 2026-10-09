import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/medical_provider.dart';
import '../../widgets/visit_card.dart';
import '../../widgets/empty_state_view.dart';
import 'add_edit_visit_screen.dart';
import 'visit_detail_screen.dart';

class VisitTimelineScreen extends StatefulWidget {
  const VisitTimelineScreen({super.key});

  @override
  State<VisitTimelineScreen> createState() => _VisitTimelineScreenState();
}

class _VisitTimelineScreenState extends State<VisitTimelineScreen> {
  String _selectedDoctorId = 'ALL';

  @override
  Widget build(BuildContext context) {
    final medical = Provider.of<MedicalProvider>(context);

    final filteredVisits = _selectedDoctorId == 'ALL'
        ? medical.visits
        : medical.visits.where((v) => v.doctorId == _selectedDoctorId).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Medical History Timeline'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditVisitScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            tooltip: 'Add Medical Visit',
          ),
        ],
      ),
      body: Column(
        children: [
          // Doctor Filter Selector
          if (medical.doctors.isNotEmpty) ...[
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All Doctors'),
                      selected: _selectedDoctorId == 'ALL',
                      onSelected: (val) => setState(() => _selectedDoctorId = 'ALL'),
                      selectedColor: AppColors.primaryFixed,
                      labelStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: _selectedDoctorId == 'ALL' ? FontWeight.w700 : FontWeight.w500,
                        color: _selectedDoctorId == 'ALL' ? AppColors.onPrimaryFixed : AppColors.onSurface,
                      ),
                    ),
                  ),
                  ...medical.doctors.map((doc) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(doc.name),
                          selected: _selectedDoctorId == doc.id,
                          onSelected: (val) => setState(() => _selectedDoctorId = doc.id),
                          selectedColor: AppColors.primaryFixed,
                          labelStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: _selectedDoctorId == doc.id ? FontWeight.w700 : FontWeight.w500,
                            color: _selectedDoctorId == doc.id ? AppColors.onPrimaryFixed : AppColors.onSurface,
                          ),
                        ),
                      )),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceContainer),
          ],

          // Visits List
          Expanded(
            child: filteredVisits.isEmpty
                ? EmptyStateView(
                    icon: Icons.history_edu_outlined,
                    title: 'No Medical Visits Logged',
                    subtitle: 'Keep a lifelong timeline of your diagnoses, prescriptions, and lab tests.',
                    buttonText: 'Log Medical Visit',
                    onButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditVisitScreen()),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredVisits.length,
                    itemBuilder: (context, index) {
                      final visit = filteredVisits[index];
                      return VisitCard(
                        visit: visit,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VisitDetailScreen(visitId: visit.id),
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
            MaterialPageRoute(builder: (_) => const AddEditVisitScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Log Visit',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

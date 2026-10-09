import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/visit_model.dart';
import '../../providers/medical_provider.dart';
import '../doctors/doctor_profile_screen.dart';
import 'add_edit_visit_screen.dart';

class VisitDetailScreen extends StatelessWidget {
  final String visitId;

  const VisitDetailScreen({super.key, required this.visitId});

  @override
  Widget build(BuildContext context) {
    final medical = Provider.of<MedicalProvider>(context);

    VisitModel? visit;
    try {
      visit = medical.visits.firstWhere((v) => v.id == visitId);
    } catch (_) {
      // Look in search results
      try {
        visit = medical.searchResults.firstWhere((v) => v.id == visitId);
      } catch (_) {}
    }

    if (visit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit Details')),
        body: const Center(child: Text('Visit record not found')),
      );
    }

    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(visit.visitDate);
    final followUpStr = visit.followUpDate != null
        ? DateFormat('dd MMM yyyy').format(visit.followUpDate!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Medical Visit Record'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditVisitScreen(visitToEdit: visit),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Visit',
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Medical Visit?'),
                  content: const Text(
                    'This visit and its prescription records will be permanently deleted.\n\nNote: The doctor\'s profile will NOT be deleted.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Delete Visit'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await medical.deleteVisit(visit!.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visit deleted (doctor profile preserved)')),
                  );
                  Navigator.pop(context);
                }
              }
            },
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Visit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor & Hospital Header Banner
            InkWell(
              onTap: () {
                if (visit?.doctorId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorProfileScreen(doctorId: visit!.doctorId),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryContainer,
                      child: const Icon(Icons.person, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.doctor?.name ?? 'Dr. Specialist',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            visit.doctor?.hospitalName ?? 'Medical Center',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.outline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Time Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '$dateStr at ${visit.visitTime}',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Diagnosis & Symptoms Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DIAGNOSIS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 1.1)),
                  const SizedBox(height: 4),
                  Text(
                    visit.diagnosis,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.surfaceContainer, height: 1),
                  const SizedBox(height: 12),
                  const Text('REPORTED SYMPTOMS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.outline, letterSpacing: 1.1)),
                  const SizedBox(height: 4),
                  Text(
                    visit.symptoms,
                    style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Prescribed Medicines Section
            const Text(
              'Prescribed Medicines',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (visit.medicines.isEmpty)
              const Text('No medicines prescribed during this visit.', style: TextStyle(color: AppColors.outline))
            else
              ...visit.medicines.map((m) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.medication_rounded, size: 20, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${m.name} ${m.dosage}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dosage: ${m.frequency} (${m.duration})',
                                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              ),
                              if (m.instructions != null && m.instructions!.isNotEmpty)
                                Text(
                                  'Note: ${m.instructions}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 18),

            // Medical Tests Section
            if (visit.tests.isNotEmpty) ...[
              const Text(
                'Diagnostic Tests & Labs',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...visit.tests.map((t) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceContainer),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          t.isCompleted ? Icons.check_circle_outline : Icons.pending_outlined,
                          color: t.isCompleted ? AppColors.tertiaryContainer : AppColors.outline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.testName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              if (t.resultNotes != null && t.resultNotes!.isNotEmpty)
                                Text('Result: ${t.resultNotes}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 18),
            ],

            // Attachments Section
            if (visit.attachments.isNotEmpty) ...[
              const Text(
                'Prescription Photos & Reports',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: visit.attachments.map((att) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          att.type == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          att.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            // Follow-up Date Banner
            if (followUpStr != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.tertiaryContainer.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_on_rounded, color: AppColors.tertiaryContainer),
                    const SizedBox(width: 10),
                    Text(
                      'Scheduled Follow-Up: $followUpStr',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.tertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Doctor Notes
            if (visit.doctorNotes != null && visit.doctorNotes!.isNotEmpty) ...[
              const Text(
                'Doctor Advice & Notes',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceContainer),
                ),
                child: Text(
                  visit.doctorNotes!,
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

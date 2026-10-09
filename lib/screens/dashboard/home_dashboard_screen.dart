import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/sync_manager.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/sync_status_badge.dart';
import '../../widgets/visit_card.dart';
import '../../widgets/doctor_card.dart';
import '../search/global_search_screen.dart';
import '../visits/add_edit_visit_screen.dart';
import '../visits/visit_detail_screen.dart';
import '../doctors/doctor_profile_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToVisits;
  final VoidCallback onNavigateToDoctors;

  const HomeDashboardScreen({
    super.key,
    required this.onNavigateToVisits,
    required this.onNavigateToDoctors,
  });

  @override
  Widget build(BuildContext context) {
    final medical = Provider.of<MedicalProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final syncManager = SyncManager();

    final userName = auth.currentUser?.displayName.split(' ').first ?? 'Michael';
    final stats = medical.dashboardStats;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.surface.withOpacity(0.9),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MY MEDICAL HISTORY',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  'Home',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.onSurfaceVariant),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primaryFixed,
              backgroundImage: auth.currentUser?.photoUrl != null
                  ? NetworkImage(auth.currentUser!.photoUrl!)
                  : null,
              child: auth.currentUser?.photoUrl == null
                  ? Text(
                      userName.characters.first,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await medical.refreshAll();
          await syncManager.triggerSync();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Sync status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning, $userName',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Here is your health snapshot',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<SyncStatus>(
                    stream: syncManager.statusStream,
                    initialData: syncManager.currentStatus,
                    builder: (context, snapshot) {
                      return SyncStatusBadge(
                        status: snapshot.data ?? SyncStatus.idle,
                        lastSyncTime: syncManager.lastSyncTime,
                        onTap: () async {
                          final ok = await syncManager.triggerSync();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? 'Google Drive synchronized!' : 'Sync offline / saved locally'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar Trigger
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
                  );
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: AppColors.secondary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search doctors, medicines (e.g. Panadol)...',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: AppColors.outline,
                          ),
                        ),
                      ),
                      Icon(Icons.mic_none_rounded, color: AppColors.outline, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fast Log Action Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FAST LOG',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add Medical Visit',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Save doctor notes, tests & prescriptions',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              color: AppColors.primaryFixedDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddEditVisitScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        '+ Log Visit',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4 Stat Cards Grid
              Row(
                children: [
                  StatCard(
                    label: 'Doctors',
                    count: stats['totalDoctors'] ?? 0,
                    icon: Icons.person_search_outlined,
                    accentColor: AppColors.primary,
                    onTap: onNavigateToDoctors,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    label: 'Visits',
                    count: stats['totalVisits'] ?? 0,
                    icon: Icons.history_edu_outlined,
                    accentColor: AppColors.secondary,
                    onTap: onNavigateToVisits,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    label: 'Medicines',
                    count: stats['totalMedicines'] ?? 0,
                    icon: Icons.medication_outlined,
                    accentColor: AppColors.tertiaryContainer,
                  ),
                  const SizedBox(width: 10),
                  StatCard(
                    label: 'Reports',
                    count: stats['totalReports'] ?? 0,
                    icon: Icons.file_present_outlined,
                    accentColor: const Color(0xFFE65100),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upcoming Follow-ups Section
              if (medical.upcomingFollowUps.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.event_repeat_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Upcoming Follow-Ups',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: medical.upcomingFollowUps.length,
                    itemBuilder: (context, index) {
                      final item = medical.upcomingFollowUps[index];
                      final fDate = DateFormat('dd MMM yyyy').format(item.followUpDate!);
                      return Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceContainerHigh),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fDate,
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.tertiaryContainer,
                                  ),
                                ),
                                const Icon(Icons.alarm, size: 16, color: AppColors.tertiaryContainer),
                              ],
                            ),
                            Text(
                              item.doctor?.name ?? 'Doctor',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.diagnosis,
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent Visits Header & List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Visits',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToVisits,
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (medical.visits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'No visits recorded yet. Tap "+ Log Visit" to add your first visit.',
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...medical.visits.take(3).map((v) => VisitCard(
                      visit: v,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VisitDetailScreen(visitId: v.id),
                          ),
                        );
                      },
                    )),

              const SizedBox(height: 20),

              // Recent Doctors Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Doctors',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToDoctors,
                    child: const Text('Directory', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ...medical.doctors.take(2).map((doc) {
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
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

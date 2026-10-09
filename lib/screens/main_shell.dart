import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'dashboard/home_dashboard_screen.dart';
import 'visits/visit_timeline_screen.dart';
import 'doctors/doctors_directory_screen.dart';
import 'backup/backup_sync_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboardScreen(
        onNavigateToVisits: () => _onTabTapped(1),
        onNavigateToDoctors: () => _onTabTapped(2),
      ),
      const VisitTimelineScreen(),
      const DoctorsDirectoryScreen(),
      const BackupSyncScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppColors.surfaceContainerLowest,
          indicatorColor: AppColors.primaryFixed,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded, color: AppColors.primary),
              label: 'Timeline',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services_rounded, color: AppColors.primary),
              label: 'Doctors',
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud_sync_outlined),
              selectedIcon: Icon(Icons.cloud_sync_rounded, color: AppColors.primary),
              label: 'Backup',
            ),
          ],
        ),
      ),
    );
  }
}

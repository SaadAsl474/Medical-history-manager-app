import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/visit_model.dart';
import '../../providers/medical_provider.dart';
import '../../widgets/visit_card.dart';
import '../../widgets/empty_state_view.dart';
import '../visits/visit_detail_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedDoctorId;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    final medical = Provider.of<MedicalProvider>(context, listen: false);
    medical.search(val);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      final medical = Provider.of<MedicalProvider>(context, listen: false);
      medical.applyFilters(
        startDate: picked.start,
        endDate: picked.end,
        doctorId: _selectedDoctorId,
      );
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedDoctorId = null;
      _selectedDateRange = null;
    });
    final medical = Provider.of<MedicalProvider>(context, listen: false);
    medical.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final medical = Provider.of<MedicalProvider>(context);

    final List<VisitModel> displayedVisits =
        medical.isSearching ? medical.searchResults : medical.visits;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Global Medical Search'),
        actions: [
          if (medical.isSearching || _selectedDateRange != null || _selectedDoctorId != null)
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text('Clear Filters', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search medicines (e.g. Panadol), doctors, symptoms...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter Chips Row
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Quick chip: Panadol example
                ActionChip(
                  avatar: const Icon(Icons.medication, size: 14, color: AppColors.secondary),
                  label: const Text('"Panadol"'),
                  onPressed: () {
                    _searchController.text = 'Panadol';
                    _onSearchChanged('Panadol');
                  },
                ),
                const SizedBox(width: 8),

                // Date Range Filter Chip
                FilterChip(
                  avatar: const Icon(Icons.date_range, size: 14),
                  label: Text(_selectedDateRange != null
                      ? '${DateFormat("dd MMM").format(_selectedDateRange!.start)} - ${DateFormat("dd MMM").format(_selectedDateRange!.end)}'
                      : 'Date Range'),
                  selected: _selectedDateRange != null,
                  onSelected: (val) => _selectDateRange(),
                ),
                const SizedBox(width: 8),

                // Doctor Filter Menu
                ...medical.doctors.map((doc) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(doc.name),
                        selected: _selectedDoctorId == doc.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDoctorId = selected ? doc.id : null;
                          });
                          medical.applyFilters(
                            doctorId: _selectedDoctorId,
                            startDate: _selectedDateRange?.start,
                            endDate: _selectedDateRange?.end,
                          );
                        },
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medical.isSearching
                      ? 'Found ${displayedVisits.length} record(s)'
                      : 'All Records (${displayedVisits.length})',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: medical.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedVisits.isEmpty
                    ? EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Records',
                        subtitle: 'Try searching by doctor name, symptom, medicine (like Panadol), or test.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: displayedVisits.length,
                        itemBuilder: (context, index) {
                          final visit = displayedVisits[index];
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
    );
  }
}

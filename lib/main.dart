import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.open();
  runApp(MyMedicalHistoryApp(db: db));
}

// ─── Database ──────────────────────────────────────────────────────────────

class AppDatabase {
  static Future<Database> open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'medical_history.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE doctors (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            specialization TEXT NOT NULL,
            phone TEXT,
            hospital TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE visits (
            id TEXT PRIMARY KEY,
            doctor_id TEXT NOT NULL,
            visit_date TEXT NOT NULL,
            symptoms TEXT,
            diagnosis TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (doctor_id) REFERENCES doctors (id)
          )
        ''');
      },
    );
  }
}

// ─── App ───────────────────────────────────────────────────────────────────

class MyMedicalHistoryApp extends StatelessWidget {
  final Database db;
  const MyMedicalHistoryApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Medical History',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF003178),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: HomeScreen(db: db),
    );
  }
}

// ─── Home Screen ───────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final Database db;
  const HomeScreen({super.key, required this.db});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [
      DoctorsScreen(db: widget.db),
      VisitsScreen(db: widget.db),
    ];
    return Scaffold(
      body: screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services), label: 'Doctors'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Visits'),
        ],
      ),
    );
  }
}

// ─── Doctors Screen ────────────────────────────────────────────────────────

class DoctorsScreen extends StatefulWidget {
  final Database db;
  const DoctorsScreen({super.key, required this.db});
  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Map<String, dynamic>> _doctors = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await widget.db.query('doctors', orderBy: 'created_at DESC');
    if (mounted) setState(() => _doctors = rows);
  }

  Future<void> _addDoctor() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _DoctorDialog(),
    );
    if (result != null) {
      await widget.db.insert('doctors', {
        'id': const Uuid().v4(),
        'name': result['name']!,
        'specialization': result['spec']!,
        'phone': result['phone'] ?? '',
        'hospital': result['hospital'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });
      _load();
    }
  }

  Future<void> _delete(String id) async {
    await widget.db.delete('doctors', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('My Doctors', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDoctor,
        icon: const Icon(Icons.add),
        label: const Text('Add Doctor'),
      ),
      body: _doctors.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 64, color: cs.primary.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text('No doctors yet', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Tap + to add your first doctor', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _doctors.length,
              itemBuilder: (_, i) {
                final d = _doctors[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Text(d['name'].toString().substring(0, 1).toUpperCase(),
                          style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(d['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${d['specialization']}${d['hospital'] != '' ? ' • ${d['hospital']}' : ''}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(d['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Doctor Dialog ─────────────────────────────────────────────────────────

class _DoctorDialog extends StatefulWidget {
  const _DoctorDialog();
  @override
  State<_DoctorDialog> createState() => _DoctorDialogState();
}

class _DoctorDialogState extends State<_DoctorDialog> {
  final _name = TextEditingController();
  final _spec = TextEditingController();
  final _phone = TextEditingController();
  final _hospital = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Doctor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Doctor Name *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _spec, decoration: const InputDecoration(labelText: 'Specialization *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _hospital, decoration: const InputDecoration(labelText: 'Hospital', border: OutlineInputBorder())),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_name.text.trim().isEmpty || _spec.text.trim().isEmpty) return;
            Navigator.pop(context, {'name': _name.text.trim(), 'spec': _spec.text.trim(), 'phone': _phone.text.trim(), 'hospital': _hospital.text.trim()});
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ─── Visits Screen ─────────────────────────────────────────────────────────

class VisitsScreen extends StatefulWidget {
  final Database db;
  const VisitsScreen({super.key, required this.db});
  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Map<String, dynamic>> _visits = [];
  List<Map<String, dynamic>> _doctors = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final visits = await widget.db.rawQuery('''
      SELECT v.*, d.name as doctor_name, d.specialization
      FROM visits v JOIN doctors d ON v.doctor_id = d.id
      ORDER BY v.visit_date DESC
    ''');
    final doctors = await widget.db.query('doctors', orderBy: 'name ASC');
    if (mounted) setState(() { _visits = visits; _doctors = doctors; });
  }

  Future<void> _addVisit() async {
    if (_doctors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a doctor first!')));
      return;
    }
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _VisitDialog(doctors: _doctors),
    );
    if (result != null) {
      await widget.db.insert('visits', {
        'id': const Uuid().v4(),
        'doctor_id': result['doctor_id']!,
        'visit_date': result['date']!,
        'symptoms': result['symptoms'] ?? '',
        'diagnosis': result['diagnosis'] ?? '',
        'notes': result['notes'] ?? '',
        'created_at': DateTime.now().toIso8601String(),
      });
      _load();
    }
  }

  Future<void> _delete(String id) async {
    await widget.db.delete('visits', where: 'id = ?', whereArgs: [id]);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d, yyyy');
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Visit History', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVisit,
        icon: const Icon(Icons.add),
        label: const Text('Log Visit'),
      ),
      body: _visits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: cs.primary.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text('No visits recorded', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Tap + to log a visit', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visits.length,
              itemBuilder: (_, i) {
                final v = _visits[i];
                final date = DateTime.tryParse(v['visit_date'] ?? '') ?? DateTime.now();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.secondaryContainer,
                      child: Icon(Icons.calendar_today, size: 20, color: cs.onSecondaryContainer),
                    ),
                    title: Text(fmt.format(date), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. ${v['doctor_name']} (${v['specialization']})'),
                        if ((v['diagnosis'] ?? '').isNotEmpty) Text('Dx: ${v['diagnosis']}', style: TextStyle(color: cs.primary)),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(v['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Visit Dialog ──────────────────────────────────────────────────────────

class _VisitDialog extends StatefulWidget {
  final List<Map<String, dynamic>> doctors;
  const _VisitDialog({required this.doctors});
  @override
  State<_VisitDialog> createState() => _VisitDialogState();
}

class _VisitDialogState extends State<_VisitDialog> {
  late String _selectedDoctorId;
  DateTime _date = DateTime.now();
  final _symptoms = TextEditingController();
  final _diagnosis = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDoctorId = widget.doctors.first['id'] as String;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return AlertDialog(
      title: const Text('Log Visit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedDoctorId,
              decoration: const InputDecoration(labelText: 'Doctor', border: OutlineInputBorder()),
              items: widget.doctors.map((d) => DropdownMenuItem(value: d['id'] as String, child: Text(d['name'] as String))).toList(),
              onChanged: (v) => setState(() => _selectedDoctorId = v!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date: ${fmt.format(_date)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (d != null) setState(() => _date = d);
              },
            ),
            const SizedBox(height: 8),
            TextField(controller: _symptoms, decoration: const InputDecoration(labelText: 'Symptoms', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _diagnosis, decoration: const InputDecoration(labelText: 'Diagnosis', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _notes, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, {
            'doctor_id': _selectedDoctorId,
            'date': _date.toIso8601String(),
            'symptoms': _symptoms.text.trim(),
            'diagnosis': _diagnosis.text.trim(),
            'notes': _notes.text.trim(),
          }),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

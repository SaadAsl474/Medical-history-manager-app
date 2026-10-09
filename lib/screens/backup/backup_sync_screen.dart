import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/services/sync_manager.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medical_provider.dart';
import '../../providers/security_provider.dart';

class BackupSyncScreen extends StatefulWidget {
  const BackupSyncScreen({super.key});

  @override
  State<BackupSyncScreen> createState() => _BackupSyncScreenState();
}

class _BackupSyncScreenState extends State<BackupSyncScreen> {
  bool _isExporting = false;
  bool _isRestoring = false;

  void _showSetPinDialog() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set 4-Digit Security PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter 4 digits',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                final sec = Provider.of<SecurityProvider>(context, listen: false);
                await sec.setPin(pin);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App Lock PIN enabled!')),
                  );
                }
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportData() async {
    setState(() => _isExporting = true);
    final medical = Provider.of<MedicalProvider>(context, listen: false);
    final export = await medical.exportData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(export);

    setState(() => _isExporting = false);

    await Share.share(
      jsonStr,
      subject: 'My_Medical_History_Backup_${DateFormat("yyyyMMdd").format(DateTime.now())}.json',
    );
  }

  Future<void> _handleRestoreData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isRestoring = true);
      try {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);

        final medical = Provider.of<MedicalProvider>(context, listen: false);
        final success = await medical.restoreData(data);

        setState(() => _isRestoring = false);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medical history successfully restored!'),
              backgroundColor: AppColors.syncActive,
            ),
          );
        }
      } catch (e) {
        setState(() => _isRestoring = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Restore error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final security = Provider.of<SecurityProvider>(context);
    final syncManager = SyncManager();

    final lastSync = syncManager.lastSyncTime;
    final lastSyncStr = lastSync != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(lastSync)
        : 'Never synced';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Backup, Sync & Security'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google Drive Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceContainer),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Google Drive Cloud Sync',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              auth.currentUser?.email ?? 'michael.green@healthmail.com',
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.surfaceContainer, height: 1),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Backup Folder:', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                      const Text(
                        'MyMedicalHistory_Backup',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Last Synced:', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                      Text(
                        lastSyncStr,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final ok = await syncManager.triggerSync();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Google Drive synchronized!' : 'Sync queued offline'),
                              backgroundColor: ok ? AppColors.syncActive : AppColors.offlineWarning,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Synchronize with Google Drive Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export & Restore Section
            const Text(
              'Data Export & Recovery',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                    title: const Text('Export Medical History JSON'),
                    subtitle: const Text('Download or share a complete uncompressed backup file'),
                    trailing: _isExporting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.chevron_right),
                    onTap: _isExporting ? null : _handleExportData,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.settings_backup_restore_rounded, color: AppColors.secondary),
                    title: const Text('Restore from Backup File'),
                    subtitle: const Text('Import doctors, visits, medicines and test history'),
                    trailing: _isRestoring
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.chevron_right),
                    onTap: _isRestoring ? null : _handleRestoreData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security & App Lock Section
            const Text(
              'Security & Privacy',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                    title: const Text('App Lock PIN Protection'),
                    subtitle: Text(security.hasPin ? 'PIN is configured' : 'Set a 4-digit PIN code'),
                    value: security.isAppLockEnabled,
                    onChanged: (val) {
                      if (!security.hasPin && val) {
                        _showSetPinDialog();
                      } else {
                        security.toggleAppLock(val);
                      }
                    },
                  ),
                  if (security.isAppLockEnabled) ...[
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.pin_outlined, color: AppColors.onSurfaceVariant),
                      title: const Text('Change Security PIN'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showSetPinDialog,
                    ),
                    const Divider(height: 1, indent: 56),
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.secondary),
                      title: const Text('Biometric Authentication'),
                      subtitle: const Text('Unlock using Fingerprint or Face ID'),
                      value: security.isBiometricEnabled,
                      onChanged: (val) => security.toggleBiometric(val),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out')),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text('Sign Out Account', style: TextStyle(color: AppColors.error)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';

// ============================================
// HerCare - Settings Screen
// Écran des Paramètres
// ============================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification toggles / Interrupteurs de notification
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  // App settings / Paramètres de l'application
  bool _darkMode = false;
  bool _autoRefresh = true;
  String _language = 'French / Français';

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final user = authVm.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page Title
          Text(
            'Settings / Paramètres',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // ── Two Column Layout
          LayoutBuilder(
            builder: (context, constraints) {
              // Wide screen: two columns
              // Écran large : deux colonnes
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildProfileCard(user),
                          const SizedBox(height: 16),
                          _buildNotificationSettings(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildAppSettings(),
                          const SizedBox(height: 16),
                          _buildSystemInfo(),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Narrow screen: single column
              return Column(
                children: [
                  _buildProfileCard(user),
                  const SizedBox(height: 16),
                  _buildNotificationSettings(),
                  const SizedBox(height: 16),
                  _buildAppSettings(),
                  const SizedBox(height: 16),
                  _buildSystemInfo(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Profile Card / Carte de profil
  Widget _buildProfileCard(dynamic user) {
    final name = user?.fullName ?? 'Administrator';
    final email = user?.email ?? 'admin@hercare.dz';

    return _SettingsCard(
      title: 'Profile / Profil',
      child: Column(
        children: [
          // Avatar
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AdminColors.primaryBlue,
                      AdminColors.pink,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Admin Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AdminColors.purpleCard.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Administrator',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.purpleCard,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AdminColors.borderLight),
          const SizedBox(height: 16),

          // Change Password Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showChangePasswordDialog(context),
              icon: const Icon(
                Icons.lock_outline_rounded,
                size: 16,
              ),
              label: Text(
                'Change Password / Changer le mot de passe',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.primaryBlue,
                side: const BorderSide(
                  color: AdminColors.primaryBlue,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification Settings
  Widget _buildNotificationSettings() {
    return _SettingsCard(
      title: 'Notifications',
      child: Column(
        children: [
          _buildToggleItem(
            title: 'Email Notifications',
            subtitle: 'Receive alerts via email'
                ' / Recevoir des alertes par email',
            value: _emailNotifications,
            onChanged: (v) => setState(() => _emailNotifications = v),
          ),
          const Divider(
            color: AdminColors.borderLight,
            height: 24,
          ),
          _buildToggleItem(
            title: 'Push Notifications',
            subtitle: 'In-app notifications'
                ' / Notifications dans l\'application',
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          const Divider(
            color: AdminColors.borderLight,
            height: 24,
          ),
          _buildToggleItem(
            title: 'SMS Notifications',
            subtitle: 'Emergency alerts via SMS'
                ' / Alertes urgentes par SMS',
            value: _smsNotifications,
            onChanged: (v) => setState(() => _smsNotifications = v),
          ),
        ],
      ),
    );
  }

  // ── App Settings
  Widget _buildAppSettings() {
    return _SettingsCard(
      title: 'Application',
      child: Column(
        children: [
          _buildToggleItem(
            title: 'Auto Refresh',
            subtitle: 'Auto refresh data every 30s'
                ' / Rafraîchir les données toutes les 30s',
            value: _autoRefresh,
            onChanged: (v) => setState(() => _autoRefresh = v),
          ),
          const Divider(
            color: AdminColors.borderLight,
            height: 24,
          ),
          _buildToggleItem(
            title: 'Dark Mode',
            subtitle: 'Coming soon / Bientôt disponible',
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          const Divider(
            color: AdminColors.borderLight,
            height: 24,
          ),

          // Language Selector
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _language,
                  onChanged: (v) => setState(() => _language = v!),
                  decoration: InputDecoration(
                    labelText: 'Language / Langue',
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: AdminColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AdminColors.pageBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AdminColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AdminColors.border,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    'French / Français',
                    'English',
                    'English / French',
                  ]
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── System Info Card
  Widget _buildSystemInfo() {
    return _SettingsCard(
      title: 'System Information / Info Système',
      child: Column(
        children: [
          _buildInfoRow(
            'App Name',
            'HerCare',
          ),
          _buildInfoRow(
            'Version',
            '1.0.0',
          ),
          _buildInfoRow(
            'Platform',
            'Flutter / Multiplatform',
          ),
          _buildInfoRow(
            'Database',
            'Firebase Firestore',
          ),
          _buildInfoRow(
            'Auth',
            'Firebase Authentication',
          ),
        ],
      ),
    );
  }

  // ── Toggle Item
  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        // Switch
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AdminColors.primaryBlue,
          activeTrackColor: AdminColors.primaryBlue.withValues(alpha: 0.3),
        ),

        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Info Row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Value
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Label
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AdminColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Change Password Dialog
  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Password / Changer mot de passe',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPasswordField(
                  'Current Password / Mot de passe actuel',
                  currentCtrl,
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  'New Password / Nouveau mot de passe',
                  newCtrl,
                ),
                const SizedBox(height: 14),
                _buildPasswordField(
                  'Confirm Password / Confirmer',
                  confirmCtrl,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel / Annuler',
                          style: GoogleFonts.inter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                final current = currentCtrl.text.trim();
                                final next = newCtrl.text.trim();
                                final confirm = confirmCtrl.text.trim();
                                if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill all password fields')),
                                  );
                                  return;
                                }
                                if (next.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('New password must be at least 6 characters')),
                                  );
                                  return;
                                }
                                if (next != confirm) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('New password and confirmation do not match')),
                                  );
                                  return;
                                }
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null || user.email == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No authenticated user')),
                                  );
                                  return;
                                }

                                try {
                                  setDialogState(() => isSaving = true);
                                  final cred = EmailAuthProvider.credential(
                                    email: user.email!,
                                    password: current,
                                  );
                                  await user.reauthenticateWithCredential(cred);
                                  await user.updatePassword(next);
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Password changed successfully / Mot de passe modifie',
                                          style: GoogleFonts.inter(),
                                        ),
                                        backgroundColor: AdminColors.success,
                                      ),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  setDialogState(() => isSaving = false);
                                  final msg = e.code == 'wrong-password'
                                      ? 'Current password is incorrect'
                                      : 'Failed to change password: ${e.message ?? e.code}';
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }
                                } catch (e) {
                                  setDialogState(() => isSaving = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to change password: $e')),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Save / Sauvegarder',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Password Field Helper
  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: true,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: AdminColors.textLight,
            ),
            filled: true,
            fillColor: AdminColors.pageBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AdminColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AdminColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AdminColors.primaryBlue,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// Settings Card Container
// Conteneur de carte paramètres
// ============================================
class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
            color: AdminColors.borderLight,
            height: 1,
          ),
          const SizedBox(height: 16),
          // Card Content
          child,
        ],
      ),
    );
  }
}




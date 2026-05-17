import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

/// Doctor settings — layout inspired by admin settings (profile, app, notifications, system).
class DoctorSettingsScreen extends StatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  State<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends State<DoctorSettingsScreen> {
  static const String _appVersion = '1.0.0';

  bool _autoRefresh = true;
  bool _emailNotif = true;
  bool _pushNotif = true;
  bool _smsNotif = false;
  String _languageCode = 'fr';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    final name = user?.fullName ?? DoctorStrings.doctorFallbackName;
    final email = user?.email ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 920;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DoctorPageHeader(
                title: DoctorStrings.settingsTitle,
                subtitle: DoctorStrings.settingsPageSubtitle,
              ),
              const SizedBox(height: 24),
              if (wide)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _profileCard(
                            name: name,
                            email: email,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _applicationCard()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _notificationsCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _systemCard()),
                      ],
                    ),
                  ],
                )
              else ...[
                _profileCard(name: name, email: email),
                const SizedBox(height: 16),
                _applicationCard(),
                const SizedBox(height: 16),
                _notificationsCard(),
                const SizedBox(height: 16),
                _systemCard(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _profileCard({
    required String name,
    required String email,
  }) {
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return DoctorSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DoctorStrings.settingsProfileCard,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DoctorColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      DoctorColors.primary,
                      DoctorColors.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: DoctorColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: DoctorColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DoctorColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: DoctorColors.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        DoctorStrings.settingsRoleDoctor,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: DoctorColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _applicationCard() {
    return DoctorSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DoctorStrings.settingsApplicationCard,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DoctorColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _toggleTile(
            title: DoctorStrings.settingsAutoRefresh,
            subtitle: DoctorStrings.settingsAutoRefreshSub,
            value: _autoRefresh,
            onChanged: (v) => setState(() => _autoRefresh = v),
          ),
          _toggleTile(
            title: DoctorStrings.settingsDarkMode,
            subtitle: DoctorStrings.settingsDarkModeSub,
            value: false,
            onChanged: (_) {},
            enabled: false,
          ),
          const SizedBox(height: 8),
          Text(
            DoctorStrings.settingsLanguageSelect,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DoctorColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(_languageCode),
            initialValue: _languageCode,
            decoration: InputDecoration(
              filled: true,
              fillColor: DoctorColors.pageBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DoctorColors.cardBorder),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'fr',
                child: Text(DoctorStrings.settingsLangFrench),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(DoctorStrings.settingsLangEnglish),
              ),
            ],
            onChanged: (v) => setState(() => _languageCode = v ?? 'fr'),
          ),
        ],
      ),
    );
  }

  Widget _notificationsCard() {
    return DoctorSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DoctorStrings.settingsNotificationsCard,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DoctorColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _toggleTile(
            title: DoctorStrings.settingsEmailNotif,
            subtitle: DoctorStrings.settingsEmailNotifSub,
            value: _emailNotif,
            onChanged: (v) => setState(() => _emailNotif = v),
          ),
          _toggleTile(
            title: DoctorStrings.settingsPushNotif,
            subtitle: DoctorStrings.settingsPushNotifSub,
            value: _pushNotif,
            onChanged: (v) => setState(() => _pushNotif = v),
          ),
          _toggleTile(
            title: DoctorStrings.settingsSmsNotif,
            subtitle: DoctorStrings.settingsSmsNotifSub,
            value: _smsNotif,
            onChanged: (v) => setState(() => _smsNotif = v),
          ),
        ],
      ),
    );
  }

  Widget _systemCard() {
    return DoctorSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DoctorStrings.settingsSystemCard,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DoctorColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _kv(DoctorStrings.settingsAppNameLabel, AppConstants.appName),
          _kv(DoctorStrings.settingsVersionLabel, _appVersion),
          _kv(DoctorStrings.settingsPlatformLabel, DoctorStrings.settingsPlatformValue),
          _kv(DoctorStrings.settingsDatabaseLabel, DoctorStrings.settingsDatabaseValue),
          _kv(DoctorStrings.settingsAuthLabel, DoctorStrings.settingsAuthValue),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: DoctorColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: DoctorColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: DoctorColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DoctorColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: Colors.white,
            activeTrackColor: DoctorColors.primary,
          ),
        ],
      ),
    );
  }
}

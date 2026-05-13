import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../services/patient_service.dart';
import '../../widgets/patient/patient_screen_chrome.dart';

class PatientNotificationsScreen extends StatelessWidget {
  const PatientNotificationsScreen({
    super.key,
    required this.locale,
    required this.patientId,
  });

  final String locale;
  final String patientId;

  @override
  Widget build(BuildContext context) {
    final svc = context.read<PatientService>();
    final s = PatientL10n.of(locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientPageHeader(
            title: s.notificationsTitle,
            subtitle: s.notificationsSub,
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: svc.watchNotifications(patientId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final notifs = snap.data ?? [];
              if (notifs.isEmpty) {
                return Center(
                  child: Text(s.noNotifications,
                      style: GoogleFonts.inter(
                          color: PatientColors.textSecondary)),
                );
              }
              return PatientCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: notifs.asMap().entries.map((e) {
                    final n = e.value;
                    final ts = (n['createdAt'] as Timestamp?)?.toDate();
                    final dateStr = ts != null
                        ? _fmtDate(ts, s)
                        : '—';
                    final title = n['title'] as String? ??
                        n['message'] as String? ??
                        '—';
                    final body =
                        n['body'] as String? ?? '';
                    final type = n['type'] as String? ?? 'info';
                    final odd = e.key.isOdd;

                    return Container(
                      color: odd
                          ? PatientColors.primaryTint.withValues(alpha: 0.3)
                          : Colors.white,
                      child: ListTile(
                        leading: _notifIcon(type),
                        title: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: PatientColors.textPrimary,
                          ),
                        ),
                        subtitle: body.isNotEmpty
                            ? Text(
                                body,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: PatientColors.textSecondary,
                                ),
                              )
                            : null,
                        trailing: Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: PatientColors.textLight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt, PatientL10n s) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return s.today;
    if (diff.inDays == 1) return s.yesterday;
    return DateFormat('d MMM y').format(dt);
  }

  Widget _notifIcon(String type) {
    switch (type) {
      case 'appointment':
        return const CircleAvatar(
          backgroundColor: PatientColors.blueLight,
          child: Icon(Icons.calendar_today, color: PatientColors.blue, size: 18),
        );
      case 'medication':
        return const CircleAvatar(
          backgroundColor: PatientColors.warningLight,
          child:
              Icon(Icons.medication, color: PatientColors.warning, size: 18),
        );
      case 'analysis':
        return const CircleAvatar(
          backgroundColor: PatientColors.successLight,
          child: Icon(Icons.science, color: PatientColors.success, size: 18),
        );
      case 'doctor':
        return const CircleAvatar(
          backgroundColor: PatientColors.primaryTint,
          child: Icon(Icons.person, color: PatientColors.primary, size: 18),
        );
      default:
        return const CircleAvatar(
          backgroundColor: PatientColors.primaryTint,
          child: Icon(Icons.notifications, color: PatientColors.primary, size: 18),
        );
    }
  }
}

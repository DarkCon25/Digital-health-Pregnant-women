import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../services/patient_service.dart';
import '../../widgets/patient/patient_screen_chrome.dart';

class MyMedicalFileScreen extends StatelessWidget {
  const MyMedicalFileScreen({
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
            title: s.medFileTitle,
            subtitle: s.medFileSub,
          ),
          const SizedBox(height: 24),
          StreamBuilder<Map<String, dynamic>?>(
            stream: svc.watchMedicalFile(patientId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final mf = snap.data;
              if (mf == null) {
                return Center(
                  child: Text(
                    s.noMedFile,
                    style: GoogleFonts.inter(color: PatientColors.textSecondary),
                  ),
                );
              }
              return _MedFileBody(mf: mf, s: s);
            },
          ),
        ],
      ),
    );
  }
}

class _MedFileBody extends StatelessWidget {
  const _MedFileBody({required this.mf, required this.s});

  final Map<String, dynamic> mf;
  final PatientL10n s;

  String _fmt(dynamic v) {
    if (v == null) return '—';
    if (v is String) return v.isEmpty ? '—' : v;
    return v.toString();
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '—';
    try {
      DateTime dt;
      if (v is DateTime) {
        dt = v;
      } else if (v.runtimeType.toString().contains('Timestamp')) {
        dt = (v as dynamic).toDate() as DateTime;
      } else {
        return v.toString();
      }
      return DateFormat('d MMMM y').format(dt);
    } catch (_) {
      return v.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.of(context).size.width > 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top info cards
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _infoCard(context)),
              const SizedBox(width: 16),
              Expanded(child: _pregnancyCard(context)),
            ],
          )
        else ...[
          _infoCard(context),
          const SizedBox(height: 16),
          _pregnancyCard(context),
        ],
        const SizedBox(height: 16),

        // ── Timeline
        _timelineCard(context),
        const SizedBox(height: 16),

        // ── Doctor notes
        _notesCard(context),
      ],
    );
  }

  Widget _infoCard(BuildContext context) {
    return PatientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(s.medFileTitle),
          const SizedBox(height: 16),
          _row(s.fileNumber, _fmt(mf['fileNumber'] ?? mf['patientFileNumber'])),
          _row(s.patientName, _fmt(mf['patientName'])),
          _row(s.bloodType, _fmt(mf['bloodType'])),
          _row(s.attendingPhysician, _fmt(mf['doctorName'] ?? mf['assignedDoctor'])),
          _row(s.room, _fmt(mf['roomNumber'])),
          _row(s.registrationDate, _fmtDate(mf['registrationDate'] ?? mf['createdAt'])),
          _row(s.healthStatus, _fmt(mf['status'] ?? mf['healthStatus'])),
        ],
      ),
    );
  }

  Widget _pregnancyCard(BuildContext context) {
    return PatientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(s.pregnancyAge),
          const SizedBox(height: 16),
          _row(s.pregnancyWeeks,
              '${_fmt(mf['pregnancyWeek'] ?? mf['gestationalWeek'])} ${s.weeks}'),
          _row(s.deliveryType, _fmt(mf['deliveryType'])),
          _row(s.expectedDueDate, _fmtDate(mf['expectedDeliveryDate'])),
          _row(s.lastUpdated, _fmtDate(mf['updatedAt'])),
        ],
      ),
    );
  }

  Widget _timelineCard(BuildContext context) {
    final week = (mf['pregnancyWeek'] ?? mf['gestationalWeek'] ?? 0) as num;
    final pct = (week / 40).clamp(0.0, 1.0).toDouble();
    final t1done = pct > 0.33;
    final t2done = pct > 0.66;
    final t3done = pct >= 1.0;

    return PatientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(s.pregnancyTimeline),
          const SizedBox(height: 20),
          // Timeline bar
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: PatientColors.primaryLight,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: PatientColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimelineMilestone(
                label: s.trimester1,
                done: t1done,
              ),
              _TimelineMilestone(
                label: s.trimester2,
                done: t2done,
              ),
              _TimelineMilestone(
                label: s.trimester3,
                done: t3done,
              ),
              _TimelineMilestone(
                label: s.dueDateLabel,
                done: t3done,
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _notesCard(BuildContext context) {
    final notes = _fmt(mf['doctorNotes'] ?? mf['notes']);
    return PatientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(s.doctorNotes),
          const SizedBox(height: 12),
          Text(
            notes,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: PatientColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.noteConsultDoctor,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: PatientColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardTitle(String t) => Text(
        t,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: PatientColors.textPrimary,
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: PatientColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PatientColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
}

class _TimelineMilestone extends StatelessWidget {
  const _TimelineMilestone({
    required this.label,
    required this.done,
    this.icon,
  });

  final String label;
  final bool done;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? PatientColors.primary : PatientColors.primaryLight,
          ),
          child: Icon(
            icon ?? Icons.check,
            size: 16,
            color: done ? Colors.white : PatientColors.primaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: done ? FontWeight.w700 : FontWeight.w400,
            color: done ? PatientColors.primary : PatientColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

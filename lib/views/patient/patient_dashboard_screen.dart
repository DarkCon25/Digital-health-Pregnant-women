import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../core/routes.dart';
import '../../models/patient/fetal_image_model.dart';
import '../../services/patient_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/patient/analyses_viewmodel.dart';
import '../../viewmodels/patient/appointments_viewmodel.dart';
import '../../viewmodels/patient/patient_dashboard_viewmodel.dart';
import '../../viewmodels/patient/patient_locale_viewmodel.dart';
import '../../viewmodels/patient/profile_viewmodel.dart';
import '../../widgets/patient/health_card.dart';
import '../../widgets/patient/patient_sidebar.dart';
import '../../widgets/patient/patient_topbar.dart';
import 'analyses_screen.dart';
import 'appointments_screen.dart';
import 'emergency_screen.dart';
import 'fetal_images_screen.dart';
import 'my_medical_file_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

/// Root shell for the patient portal — wraps all patient screens.
class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientLocaleViewModel()),
        Provider(create: (_) => PatientService()),
        ChangeNotifierProxyProvider<PatientService, PatientDashboardViewModel>(
          create: (c) =>
              PatientDashboardViewModel(c.read<PatientService>()),
          update: (_, svc, vm) => vm ?? PatientDashboardViewModel(svc),
        ),
        ChangeNotifierProxyProvider<PatientService,
            PatientAppointmentsViewModel>(
          create: (c) =>
              PatientAppointmentsViewModel(c.read<PatientService>()),
          update: (_, svc, vm) =>
              vm ?? PatientAppointmentsViewModel(svc),
        ),
        ChangeNotifierProxyProvider<PatientService, AnalysesViewModel>(
          create: (c) => AnalysesViewModel(c.read<PatientService>()),
          update: (_, svc, vm) => vm ?? AnalysesViewModel(svc),
        ),
        ChangeNotifierProxyProvider<PatientService, PatientProfileViewModel>(
          create: (c) =>
              PatientProfileViewModel(c.read<PatientService>()),
          update: (_, svc, vm) =>
              vm ?? PatientProfileViewModel(svc),
        ),
      ],
      child: const _PatientShell(),
    );
  }
}

class _PatientShell extends StatefulWidget {
  const _PatientShell();

  @override
  State<_PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<_PatientShell> {
  PatientPage _page = PatientPage.dashboard;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          );
        }
        return;
      }
      context.read<PatientDashboardViewModel>().start(uid);
      context.read<PatientAppointmentsViewModel>().start(uid);
      context.read<AnalysesViewModel>().start(uid);
      context.read<PatientProfileViewModel>().start(uid);
    });
    // Rebuild topbar clock every minute
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientDashboardViewModel>();
    final localeVm = context.watch<PatientLocaleViewModel>();
    final locale = localeVm.locale;
    final patient = vm.patient;
    final name = patient?.fullName ?? '';

    return Directionality(
      textDirection: localeVm.textDirection,
      child: Scaffold(
        backgroundColor: PatientColors.pageBg,
        body: Row(
          children: [
            PatientSidebar(
              currentPage: _page,
              onSelect: (p) => setState(() => _page = p),
              nurseName: name,
              onLogout: _logout,
            ),
            Expanded(
              child: Column(
                children: [
                  PatientTopbar(patientName: name),
                  Expanded(
                    child: Container(
                      color: PatientColors.pageBg,
                      child: _buildBody(locale, patient?.uid ?? ''),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(String locale, String uid) {
    switch (_page) {
      case PatientPage.dashboard:
        return _DashboardHome(
          locale: locale,
          onNavigate: (p) => setState(() => _page = p),
        );
      case PatientPage.medicalFile:
        return MyMedicalFileScreen(locale: locale, patientId: uid);
      case PatientPage.analyses:
        return AnalysesScreen(locale: locale);
      case PatientPage.fetalImages:
        return FetalImagesScreen(locale: locale, patientId: uid);
      case PatientPage.appointments:
        return AppointmentsScreen(locale: locale, patientId: uid);
      case PatientPage.emergency:
        return EmergencyScreen(locale: locale, patientId: uid);
      case PatientPage.notifications:
        return PatientNotificationsScreen(locale: locale, patientId: uid);
      case PatientPage.profile:
        return PatientProfileScreen(locale: locale, patientId: uid);
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Dashboard Home tab
// ──────────────────────────────────────────────────────────────────────────────
class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.locale,
    required this.onNavigate,
  });

  final String locale;
  final ValueChanged<PatientPage> onNavigate;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientDashboardViewModel>();
    final s = PatientL10n.of(locale);
    final patient = vm.patient;
    final medFile = vm.medFile;
    final name = patient?.fullName ?? '';

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final systolic = medFile?['bloodPressureSystolic'];
    final diastolic = medFile?['bloodPressureDiastolic'];
    final bp = (medFile?['bloodPressure'] as String?) ??
        ((systolic != null || diastolic != null)
            ? '${systolic ?? '—'}/${diastolic ?? '—'}'
            : '—');
    final glucose = medFile?['bloodGlucose'] ??
        medFile?['bloodSugar'] ??
        medFile?['glucose'] ??
        medFile?['sugarLevel'];
    final temp = medFile?['temperatureCelsius'] ?? medFile?['temperature'];
    final weight = patient?.pregnancyWeek != null
        ? (medFile?['weight'] ?? '—').toString()
        : '—';
    final fetalHR = medFile?['fetalHeartRateBpm'] ??
        medFile?['fetalHeartRate'] ??
        medFile?['heartRateBpm'] ??
        medFile?['heartRate'];

    final weeks = patient?.pregnancyWeek ?? 0;
    final months = (weeks / 4.33).round();
    final doctorName = patient?.assignedDoctorName ?? '—';
    final bloodType = patient?.bloodType ?? '—';
    final dueDate = patient?.expectedDeliveryDate;
    final dueDateStr =
        dueDate != null ? DateFormat('d MMM y').format(dueDate) : '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Welcome banner
          _WelcomeBanner(name: name, locale: locale, weeks: weeks,
              months: months, doctorName: doctorName, bloodType: bloodType,
              dueDateStr: dueDateStr),
          const SizedBox(height: 24),

          // ── Health cards row
          _HealthGrid(
            s: s,
            bp: bp,
            glucose: '$glucose',
            temp: '$temp',
            weight: weight,
            fetalHR: '$fetalHR',
          ),
          const SizedBox(height: 24),

          // ── Emergency button
          _QuickEmergency(
            locale: locale,
            onTap: () => onNavigate(PatientPage.emergency),
          ),
          const SizedBox(height: 24),

          // ── Recent fetal images
          _RecentImages(
            locale: locale,
            images: vm.recentImages,
            onViewAll: () => onNavigate(PatientPage.fetalImages),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.name,
    required this.locale,
    required this.weeks,
    required this.months,
    required this.doctorName,
    required this.bloodType,
    required this.dueDateStr,
  });

  final String name;
  final String locale;
  final int weeks;
  final int months;
  final String doctorName;
  final String bloodType;
  final String dueDateStr;

  @override
  Widget build(BuildContext context) {
    final s = PatientL10n.of(locale);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PatientColors.primary, PatientColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PatientColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left text
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.greetingHello} ${name.split(' ').first} !',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.greetingSub,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                        icon: Icons.pregnant_woman,
                        label: '$weeks ${s.weeks}'),
                    _InfoChip(
                        icon: Icons.calendar_today,
                        label: '$months ${s.months}'),
                    _InfoChip(icon: Icons.person_outline, label: doctorName),
                    _InfoChip(
                        icon: Icons.water_drop_outlined,
                        label: bloodType),
                    _InfoChip(
                        icon: Icons.event_available,
                        label: dueDateStr),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right — pregnancy illustration placeholder
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.child_care,
                size: 60,
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthGrid extends StatelessWidget {
  const _HealthGrid({
    required this.s,
    required this.bp,
    required this.glucose,
    required this.temp,
    required this.weight,
    required this.fetalHR,
  });

  final PatientL10n s;
  final String bp, glucose, temp, weight, fetalHR;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (s.metricBP, bp, s.metricBPUnit, Icons.favorite_border,
          PatientColors.bloodPressure),
      (s.metricGlucose, glucose, s.metricGlucoseUnit,
          Icons.water_drop_outlined, PatientColors.bloodSugar),
      (s.metricTemp, temp, s.metricTempUnit, Icons.thermostat_outlined,
          PatientColors.temperature),
      (s.metricWeight, weight, s.metricWeightUnit, Icons.monitor_weight_outlined,
          PatientColors.weight),
      (s.metricFetalHR, fetalHR, s.metricFetalHRUnit,
          Icons.child_care_outlined, PatientColors.fetalHR),
    ];

    return LayoutBuilder(builder: (context, box) {
      final cols = box.maxWidth > 800 ? 5 : box.maxWidth > 540 ? 3 : 2;
      final cellW = (box.maxWidth - (cols - 1) * 12) / cols;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: metrics.map((m) {
          return SizedBox(
            width: cellW,
            child: HealthCard(
              label: m.$1,
              value: m.$2,
              unit: m.$3,
              icon: m.$4,
              accentColor: m.$5,
            ),
          );
        }).toList(),
      );
    });
  }
}

class _QuickEmergency extends StatelessWidget {
  const _QuickEmergency({required this.locale, required this.onTap});

  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = PatientL10n.of(locale);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: PatientColors.criticalLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PatientColors.critical.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.emergency_outlined,
                color: PatientColors.critical, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.emergencyNeedHelp,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: PatientColors.critical,
                    ),
                  ),
                  Text(
                    s.emergencyDesc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: PatientColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: PatientColors.critical),
          ],
        ),
      ),
    );
  }
}

class _RecentImages extends StatelessWidget {
  const _RecentImages({
    required this.locale,
    required this.images,
    required this.onViewAll,
  });

  final String locale;
  final List<FetalImageModel> images;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final s = PatientL10n.of(locale);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PatientColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Text(
                s.recentFetalImages,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: PatientColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewAll,
                child: Text(s.viewAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (images.isEmpty)
            Text(
              s.noImages,
              style: GoogleFonts.inter(color: PatientColors.textSecondary),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final img = images[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      child: img.imageUrl.isNotEmpty
                          ? Image.network(
                              img.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: PatientColors.primaryTint,
                                child: const Center(
                                  child: Icon(Icons.child_care,
                                      color: PatientColors.primaryLight,
                                      size: 36),
                                ),
                              ),
                            )
                          : Container(
                              color: PatientColors.primaryTint,
                              child: const Center(
                                child: Icon(Icons.child_care,
                                    color: PatientColors.primaryLight,
                                    size: 36),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

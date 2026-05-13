import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/doctor/lab_test_model.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';
import '../../viewmodels/doctor/medical_file_viewmodel.dart';
import '../../widgets/doctor/doctor_fl_chart.dart';
import '../../widgets/doctor/vital_signs_card.dart';

class MedicalFileScreen extends StatelessWidget {
  const MedicalFileScreen({super.key, required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return ChangeNotifierProvider(
      create: (_) => MedicalFileViewModel(
        context.read<DoctorService>(),
        patientId,
        doctorId,
      )..init(),
      child: DefaultTabController(
        length: 5,
        child: _MedicalFileTabsShell(patientId: patientId),
      ),
    );
  }
}

class _MedicalFileTabsShell extends StatelessWidget {
  const _MedicalFileTabsShell({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicalFileViewModel>();
    final p = vm.patient;

    return Scaffold(
      backgroundColor: DoctorColors.pageBg,
      appBar: AppBar(
        backgroundColor: DoctorColors.topbarBg,
        foregroundColor: DoctorColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          p == null ? DoctorStrings.medicalFileTitle : p.fullName,
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          isScrollable: true,
          labelColor: DoctorColors.primary,
          unselectedLabelColor: DoctorColors.textSecondary,
          indicatorColor: DoctorColors.primary,
          tabs: const [
            Tab(text: DoctorStrings.tabBasic),
            Tab(text: DoctorStrings.tabPregnancy),
            Tab(text: DoctorStrings.tabVitals),
            Tab(text: DoctorStrings.tabLabs),
            Tab(text: DoctorStrings.tabReports),
          ],
        ),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              children: [
                _BasicInfoTab(patient: p),
                _PregnancyTab(patientId: patientId),
                _HealthIndicatorsTab(patientId: patientId),
                _LabTab(patientId: patientId),
                const _ReportsTab(),
              ],
            ),
    );
  }
}

class _BasicInfoTab extends StatelessWidget {
  const _BasicInfoTab({required this.patient});

  final PatientModel? patient;

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return const Center(child: Text(DoctorStrings.noPatientData));
    }
    final p = patient!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: DoctorColors.primary.withValues(alpha: 0.15),
                backgroundImage: p.profileImage != null &&
                        p.profileImage!.isNotEmpty
                    ? NetworkImage(p.profileImage!)
                    : null,
                child: p.profileImage == null || p.profileImage!.isEmpty
                    ? Text(
                        p.firstName.isNotEmpty ? p.firstName[0] : '?',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: DoctorColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _line(Icons.badge_outlined, DoctorStrings.labelId, p.uid),
                    _line(Icons.cake_outlined, DoctorStrings.labelAge,
                        '${p.age ?? "—"}'),
                    _line(
                      Icons.bloodtype_outlined,
                      DoctorStrings.labelBloodType,
                      p.bloodType ?? '—',
                    ),
                    _line(Icons.phone_outlined, DoctorStrings.labelPhone, p.phone),
                    _line(
                      Icons.place_outlined,
                      DoctorStrings.labelAddress,
                      p.address ?? p.wilaya,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _miniStat(
                DoctorStrings.miniGestationalWeek,
                '${p.gestationalWeek ?? p.pregnancyWeek ?? "—"}',
              ),
              _miniStat(
                DoctorStrings.miniEdd,
                p.expectedDeliveryDate != null
                    ? DateFormat.yMMMd().format(p.expectedDeliveryDate!)
                    : '—',
              ),
              _miniStat(DoctorStrings.miniRoom, p.roomNumber ?? '—'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _line(IconData i, String l, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(i, size: 18, color: DoctorColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$l: ',
            style: GoogleFonts.inter(
              color: DoctorColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _miniStat(String title, String value) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DoctorColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: DoctorColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _PregnancyTab extends StatelessWidget {
  const _PregnancyTab({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final service = context.read<DoctorService>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.watchPregnancyMonitoring(patientId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final rows = snap.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: DoctorColors.cardBorder),
                ),
                child: DoctorFlMonitoringChart(
                  rows: rows,
                  primaryKey: 'weight',
                  secondaryKey: 'sugarLevel',
                  title: DoctorStrings.curveFollowUp,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                DoctorStrings.visitsTable,
                style: GoogleFonts.inter(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text(DoctorStrings.colDate)),
                    DataColumn(label: Text(DoctorStrings.colWeight)),
                    DataColumn(label: Text(DoctorStrings.colGlucose)),
                    DataColumn(label: Text(DoctorStrings.colPressure)),
                    DataColumn(label: Text(DoctorStrings.colPulse)),
                  ],
                  rows: rows.reversed.take(20).map((r) {
                    final ts = r['createdAt'];
                    final d = ts is Timestamp
                        ? DateFormat.MMMd().format(ts.toDate())
                        : '—';
                    return DataRow(cells: [
                      DataCell(Text(d)),
                      DataCell(Text('${r['weight'] ?? '—'}')),
                      DataCell(Text('${r['sugarLevel'] ?? '—'}')),
                      DataCell(Text('${r['bloodPressure'] ?? '—'}')),
                      DataCell(Text('${r['heartbeat'] ?? '—'}')),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HealthIndicatorsTab extends StatefulWidget {
  const _HealthIndicatorsTab({required this.patientId});

  final String patientId;

  @override
  State<_HealthIndicatorsTab> createState() => _HealthIndicatorsTabState();
}

class _HealthIndicatorsTabState extends State<_HealthIndicatorsTab> {
  final _sys = TextEditingController();
  final _dia = TextEditingController();
  final _hr = TextEditingController();
  final _fhr = TextEditingController();
  final _glucose = TextEditingController();
  final _temp = TextEditingController();
  final _note = TextEditingController();
  final _diag = TextEditingController();

  @override
  void dispose() {
    _sys.dispose();
    _dia.dispose();
    _hr.dispose();
    _fhr.dispose();
    _glucose.dispose();
    _temp.dispose();
    _note.dispose();
    _diag.dispose();
    super.dispose();
  }

  void _sync(MedicalFileViewModel vm) {
    final m = vm.medical;
    if (m == null) return;
    if (_sys.text.isEmpty && m.bloodPressureSystolic != null) {
      _sys.text = '${m.bloodPressureSystolic}';
    }
    if (_dia.text.isEmpty && m.bloodPressureDiastolic != null) {
      _dia.text = '${m.bloodPressureDiastolic}';
    }
    if (_hr.text.isEmpty && m.heartRateBpm != null) {
      _hr.text = '${m.heartRateBpm}';
    }
    if (_fhr.text.isEmpty && m.fetalHeartRateBpm != null) {
      _fhr.text = '${m.fetalHeartRateBpm}';
    }
    if (_glucose.text.isEmpty && m.bloodGlucose != null) {
      _glucose.text = '${m.bloodGlucose}';
    }
    if (_temp.text.isEmpty && m.temperatureCelsius != null) {
      _temp.text = '${m.temperatureCelsius}';
    }
  }

  int? _pi(String s) => int.tryParse(s.trim());
  double? _pd(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicalFileViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync(vm);
    });
    final m = vm.medical;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (m != null)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                VitalSignsCard(
                  label: DoctorStrings.labelPressure,
                  value: m.bloodPressureSystolic != null &&
                          m.bloodPressureDiastolic != null
                      ? '${m.bloodPressureSystolic}/${m.bloodPressureDiastolic}'
                      : '—',
                  unit: 'mmHg',
                  icon: Icons.favorite_outline,
                  accentColor: DoctorColors.critical,
                ),
                VitalSignsCard(
                  label: DoctorStrings.labelMaternalHr,
                  value: '${m.heartRateBpm ?? "—"}',
                  unit: DoctorStrings.unitBpm,
                  icon: Icons.monitor_heart_outlined,
                ),
                VitalSignsCard(
                  label: DoctorStrings.labelFetalHr,
                  value: '${m.fetalHeartRateBpm ?? "—"}',
                  unit: DoctorStrings.unitBpm,
                  icon: Icons.child_care_outlined,
                ),
                VitalSignsCard(
                  label: DoctorStrings.labelGlucoseShort,
                  value: '${m.bloodGlucose ?? "—"}',
                  unit: 'g/L',
                  icon: Icons.bloodtype_outlined,
                ),
              ],
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DoctorColors.cardBorder),
            ),
            child: DoctorFlMonitoringChart(
              rows: vm.monitoringHistory,
              primaryKey: 'weight',
              secondaryKey: 'sugarLevel',
              title: DoctorStrings.vitalsTrendTitle,
              height: 200,
            ),
          ),
          const SizedBox(height: 16),
          Text(DoctorStrings.updateVitals,
              style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _sys,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labelSystolic,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _dia,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labelDiastolic,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _hr,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labelHr,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _fhr,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labelFhr,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _glucose,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labelSugar,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _temp,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labelTemp,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: vm.saving
                ? null
                : () async {
                    final ok = await vm.saveVitals(
                      systolic: _pi(_sys.text),
                      diastolic: _pi(_dia.text),
                      heartRate: _pi(_hr.text),
                      fetalHr: _pi(_fhr.text),
                      glucose: _pd(_glucose.text),
                      temp: _pd(_temp.text),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? DoctorStrings.savedSnackbar
                                : (vm.error ?? 'Failed to save vitals'),
                          ),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.save_outlined),
            label: const Text(DoctorStrings.save),
            style: FilledButton.styleFrom(
              backgroundColor: DoctorColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(DoctorStrings.visitNote,
              style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          TextField(
              controller: _diag,
              decoration: const InputDecoration(
                labelText: DoctorStrings.labelDiagnosis,
              )),
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: DoctorStrings.labelNotes,
            ),
          ),
          OutlinedButton.icon(
            onPressed: vm.saving
                ? null
                : () async {
                    final ok = await vm.addConsultationNote(
                      notes: _note.text,
                      diagnosis: _diag.text.isEmpty ? null : _diag.text,
                      visitDate: DateTime.now(),
                    );
                    if (ok) {
                      _note.clear();
                      _diag.clear();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? DoctorStrings.visitRegisteredSnackbar
                                : (vm.error ?? 'Failed to register visit'),
                          ),
                        ),
                      );
                    }
                  },
            icon: const Icon(Icons.note_add_outlined),
            label: const Text(DoctorStrings.registerVisit),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: vm.saving
                ? null
                : () {
                    final patient = vm.patient;
                    final diagnosis = _diag.text.trim();
                    final notes = _note.text.trim();
                    _showPrescriptionPreview(
                      context,
                      patientName: patient?.fullName ?? DoctorStrings.doctorFallbackName,
                      diagnosis: diagnosis.isEmpty ? 'N/A' : diagnosis,
                      notes: notes.isEmpty ? 'N/A' : notes,
                    );
                  },
            style: FilledButton.styleFrom(
              backgroundColor: DoctorColors.primary,
            ),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print Prescription'),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionPreview(
    BuildContext context, {
    required String patientName,
    required String diagnosis,
    required String notes,
  }) {
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final text = '''
Prescription
Date: $now
Patient: $patientName

Diagnosis:
$diagnosis

Notes / Treatment:
$notes
''';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Prescription Preview'),
        content: SingleChildScrollView(
          child: SelectableText(
            text,
            style: GoogleFonts.inter(fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Use browser/OS print dialog (Ctrl+P) to print.'),
                ),
              );
            },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }
}

class _LabTab extends StatelessWidget {
  const _LabTab({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = context.read<DoctorService>();
    final patient = context.watch<MedicalFileViewModel>().patient;
    final canAddLab = doctorId.isNotEmpty && patient != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                DoctorStrings.storedLabs,
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: !canAddLab
                    ? null
                    : () {
                        final p =
                            context.read<MedicalFileViewModel>().patient;
                        if (p == null) return;
                        _addLab(context, service, doctorId, p);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: DoctorColors.primary,
                ),
                icon: const Icon(Icons.add),
                label: const Text(DoctorStrings.addLabTest),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<LabTestModel>>(
              stream: service.watchLabTestsForPatient(doctorId, patientId),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tests = snap.data!;
                if (tests.isEmpty) {
                  return Center(
                    child: Text(
                      DoctorStrings.noLabTests,
                      style: GoogleFonts.inter(color: DoctorColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: tests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = tests[i];
                    final ok = t.status.toLowerCase() == 'normal';
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: DoctorColors.cardBorder),
                      ),
                      title: Text(t.testName,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${t.category} • ${DateFormat.yMMMd().format(t.testDate)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            t.value,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              color: ok
                                  ? DoctorColors.success
                                  : DoctorColors.critical,
                            ),
                          ),
                          if (t.pdfUrl != null && t.pdfUrl!.isNotEmpty)
                            TextButton(
                              onPressed: () {},
                              child: const Text('PDF'),
                            ),
                        ],
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

  static Future<void> _addLab(
    BuildContext context,
    DoctorService service,
    String doctorId,
    PatientModel patient,
  ) async {
    String category = 'blood';
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    String status = 'normal';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text(DoctorStrings.newLabDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labCategory,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'blood',
                      child: Text(DoctorStrings.labCatBlood),
                    ),
                    DropdownMenuItem(
                      value: 'urine',
                      child: Text(DoctorStrings.labCatUrine),
                    ),
                    DropdownMenuItem(
                      value: 'xray',
                      child: Text(DoctorStrings.labCatXray),
                    ),
                  ],
                  onChanged: (v) => setS(() => category = v ?? 'blood'),
                ),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labTestName,
                  ),
                ),
                TextField(
                  controller: valueCtrl,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labValue,
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.labResultStatus,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'normal',
                      child: Text(DoctorStrings.labNormal),
                    ),
                    DropdownMenuItem(
                      value: 'abnormal',
                      child: Text(DoctorStrings.labAbnormal),
                    ),
                  ],
                  onChanged: (v) => setS(() => status = v ?? 'normal'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(DoctorStrings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                await service.addLabTest(
                  LabTestModel(
                    id: '',
                    doctorId: doctorId,
                    patientId: patient.uid,
                    patientName: patient.fullName,
                    category: category,
                    testName: nameCtrl.text.trim().isEmpty
                        ? DoctorStrings.labDefaultName
                        : nameCtrl.text.trim(),
                    value: valueCtrl.text.trim().isEmpty
                        ? '—'
                        : valueCtrl.text.trim(),
                    status: status,
                    testDate: DateTime.now(),
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text(DoctorStrings.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MedicalFileViewModel>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          DoctorStrings.visitLogTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...vm.consultations.map(
          (c) => Card(
            child: ListTile(
              title: Text(c.notes, maxLines: 4),
              subtitle: Text(DateFormat.yMMMd().add_Hm().format(c.visitDate)),
              trailing: c.diagnosis != null
                  ? Chip(label: Text(c.diagnosis!))
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

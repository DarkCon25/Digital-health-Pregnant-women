import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/doctor/icu_case_model.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';
import '../../viewmodels/doctor/my_patients_viewmodel.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

/// ICU cases — Firestore collection `icu_cases`.
class DoctorIcuScreen extends StatelessWidget {
  const DoctorIcuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = context.read<DoctorService>();
    final patients = context.watch<MyPatientsViewModel>().patients;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<IcuCaseModel>>(
        stream: uid.isEmpty
            ? const Stream.empty()
            : service.watchIcuCases(uid),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cases = snap.data!;
          final active = cases.where((c) => c.isActive).length;
          final stable = cases
              .where((c) => c.status.toLowerCase() == 'stable')
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DoctorPageHeader(
                title: DoctorStrings.icuTitle,
                subtitle: DoctorStrings.icuPageSubtitle,
                actions: [
                  FilledButton.icon(
                    onPressed: uid.isEmpty
                        ? null
                        : () => _openAdd(context, service, uid, patients),
                    style: FilledButton.styleFrom(
                      backgroundColor: DoctorColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(DoctorStrings.addIcuCase),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _summary(DoctorStrings.icuSummaryActive, '$active',
                      DoctorColors.critical),
                  _summary(DoctorStrings.icuSummaryStable, '$stable',
                      DoctorColors.success),
                  _summary(DoctorStrings.icuSummaryTotal, '${cases.length}',
                      DoctorColors.primary),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DoctorSurfaceCard(
                  padding: EdgeInsets.zero,
                  child: cases.isEmpty
                      ? Center(
                          child: Text(
                            DoctorStrings.noIcuCases,
                            style: GoogleFonts.inter(
                              color: DoctorColors.textSecondary,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text(DoctorStrings.colPatient)),
                              DataColumn(label: Text(DoctorStrings.colReason)),
                              DataColumn(
                                label: Text(DoctorStrings.icuColAdmission),
                              ),
                              DataColumn(label: Text(DoctorStrings.colStatus)),
                              DataColumn(label: Text('')),
                            ],
                            rows: cases.map((c) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(c.patientName)),
                                  DataCell(Text(c.reason)),
                                  DataCell(Text(
                                    c.admittedAt != null
                                        ? DateFormat.yMMMd()
                                            .add_Hm()
                                            .format(c.admittedAt!)
                                        : '—',
                                  )),
                                  DataCell(Text(c.status)),
                                  DataCell(
                                    TextButton(
                                      onPressed: () => service
                                          .updateIcuCaseStatus(
                                        c.id,
                                        'discharged',
                                      ),
                                      child: const Text(DoctorStrings.discharge),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _summary(String t, String v, Color c) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: GoogleFonts.inter(fontSize: 12, color: DoctorColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            v,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openAdd(
    BuildContext context,
    DoctorService service,
    String doctorId,
    List<PatientModel> patients,
  ) async {
    if (patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(DoctorStrings.addPatientsFirst)),
      );
      return;
    }
    String? pid = patients.first.uid;
    final reasonCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return AlertDialog(
            title: const Text(DoctorStrings.icuDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(pid),
                  initialValue: pid,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.selectPatient,
                  ),
                  items: patients
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.uid,
                          child: Text(p.fullName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setS(() => pid = v),
                ),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(
                    labelText: DoctorStrings.reasonAdmission,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(DoctorStrings.cancel),
              ),
              FilledButton(
                onPressed: pid == null
                    ? null
                    : () async {
                        final p =
                            patients.firstWhere((e) => e.uid == pid);
                        await service.addIcuCase(
                          IcuCaseModel(
                            id: '',
                            doctorId: doctorId,
                            patientId: p.uid,
                            patientName: p.fullName,
                            reason: reasonCtrl.text.trim().isEmpty
                                ? DoctorStrings.reasonUnknown
                                : reasonCtrl.text.trim(),
                            admittedAt: DateTime.now(),
                            status: 'active',
                          ),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                child: const Text(DoctorStrings.save),
              ),
            ],
          );
        },
      ),
    );
  }
}

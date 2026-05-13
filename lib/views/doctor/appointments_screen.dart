import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';
import '../../viewmodels/doctor/doctor_dashboard_viewmodel.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = context.read<DoctorService>();
    final dash = context.watch<DoctorDashboardViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DoctorPageHeader(
            title: DoctorStrings.appointmentsTitle,
            subtitle: DoctorStrings.appointmentsPageSubtitle,
            actions: [
              FilledButton.icon(
                onPressed: doctorId.isEmpty
                    ? null
                    : () => _showAddDialog(context, service, doctorId, dash),
                icon: const Icon(Icons.add),
                label: const Text(DoctorStrings.newAppointment),
                style: FilledButton.styleFrom(
                  backgroundColor: DoctorColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DoctorSurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: dash.appointments.isEmpty
                ? Center(
                    child: Text(
                      DoctorStrings.noAppointments,
                      style: GoogleFonts.inter(
                        color: DoctorColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: dash.appointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final a = dash.appointments[i];
                      final fmt = DateFormat.yMMMd().add_Hm();
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: DoctorColors.cardBorder),
                        ),
                        title: Text(
                          a.patientName,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(fmt.format(a.startAt)),
                        trailing: Chip(label: Text(a.status)),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _showAddDialog(
    BuildContext context,
    DoctorService service,
    String doctorId,
    DoctorDashboardViewModel dash,
  ) async {
    final patients = dash.patients;
    if (patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(DoctorStrings.noPatientsForAppointment),
        ),
      );
      return;
    }

    String? selectedId = patients.first.uid;
    DateTime start = DateTime.now().add(const Duration(days: 1));
    final noteCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return AlertDialog(
            title: const Text(DoctorStrings.newAppointmentDialogTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedId),
                    initialValue: selectedId,
                    decoration: const InputDecoration(
                      labelText: DoctorStrings.selectPatient,
                    ),
                    items: patients
                        .map(
                          (PatientModel p) => DropdownMenuItem(
                            value: p.uid,
                            child: Text(p.fullName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setS(() => selectedId = v),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(DateFormat.yMMMd().add_Hm().format(start)),
                    trailing: const Icon(Icons.schedule),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: start,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (d == null) return;
                      if (!ctx.mounted) return;
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.fromDateTime(start),
                      );
                      if (t == null) return;
                      setS(() {
                        start = DateTime(
                          d.year,
                          d.month,
                          d.day,
                          t.hour,
                          t.minute,
                        );
                      });
                    },
                  ),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: DoctorStrings.noteField,
                    ),
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
                onPressed: selectedId == null
                    ? null
                    : () async {
                        final p =
                            patients.firstWhere((e) => e.uid == selectedId);
                        await service.addAppointment(
                          doctorId: doctorId,
                          patientId: p.uid,
                          patientName: p.fullName,
                          startAt: start,
                          notes: noteCtrl.text.isEmpty ? null : noteCtrl.text,
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

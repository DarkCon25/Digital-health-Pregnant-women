import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/localization/patient_strings.dart';
import '../../core/patient_colors.dart';
import '../../viewmodels/patient/appointments_viewmodel.dart';
import '../../viewmodels/patient/patient_dashboard_viewmodel.dart';
import '../../widgets/patient/appointment_card.dart';
import '../../widgets/patient/patient_screen_chrome.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({
    super.key,
    required this.locale,
    required this.patientId,
  });

  final String locale;
  final String patientId;

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _showUpcoming = true;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientAppointmentsViewModel>();
    final s = PatientL10n.of(widget.locale);
    final list = _showUpcoming ? vm.upcoming : vm.past;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PatientPageHeader(
            title: s.appointmentsTitle,
            subtitle: s.appointmentsSub,
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: Text(s.requestNewAppointment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PatientColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () =>
                    _showRequestDialog(context, s, widget.patientId),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabs
          Row(
            children: [
              _tabBtn(s.tabUpcoming, _showUpcoming, () {
                setState(() => _showUpcoming = true);
              }),
              const SizedBox(width: 8),
              _tabBtn(s.tabPast, !_showUpcoming, () {
                setState(() => _showUpcoming = false);
              }),
            ],
          ),
          const SizedBox(height: 16),

          if (vm.requestSent)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PatientColors.successLight,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: PatientColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: PatientColors.success, size: 20),
                  const SizedBox(width: 10),
                  Text(s.requestSent,
                      style: GoogleFonts.inter(
                          color: PatientColors.success,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          if (vm.loading)
            const Center(child: CircularProgressIndicator())
          else if (list.isEmpty)
            Center(
              child: Text(s.noAppointments,
                  style:
                      GoogleFonts.inter(color: PatientColors.textSecondary)),
            )
          else
            ...list.map((a) => AppointmentCard(appt: a, locale: widget.locale)),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? PatientColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? PatientColors.primary : PatientColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : PatientColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showRequestDialog(
      BuildContext context, PatientL10n s, String patientId) {
    final vm = context.read<PatientAppointmentsViewModel>();
    final dashVm = context.read<PatientDashboardViewModel>();
    final patient = dashVm.patient;
    String type = 'Prenatal Check-up';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
    String notes = '';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            s.requestNewAppointment,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                color: PatientColors.textPrimary),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: s.appointmentType,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => type = v,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    DateFormat('d MMM y – HH:mm').format(selectedDate),
                  ),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (d == null) return;
                    if (!ctx.mounted) return;
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime:
                          TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (t == null) return;
                    if (!ctx.mounted) return;
                    setDlg(() {
                      selectedDate = DateTime(
                          d.year, d.month, d.day, t.hour, t.minute);
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: notes,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: s.doctorNotes,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => notes = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PatientColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                vm.requestAppointment(
                  patientId: patientId,
                  patientName: patient?.fullName,
                  doctorId: patient?.assignedDoctorId ?? '',
                  doctorName: patient?.assignedDoctorName ?? '',
                  type: type,
                  dateTime: selectedDate,
                  notes: notes,
                );
              },
              child: Text(s.requestNewAppointment),
            ),
          ],
        ),
      ),
    );
  }
}

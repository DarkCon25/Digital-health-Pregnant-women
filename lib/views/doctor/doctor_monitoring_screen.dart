import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';
import '../../viewmodels/doctor/my_patients_viewmodel.dart';
import '../../widgets/doctor/doctor_fl_chart.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

/// Monitoring & analysis — `pregnancy_monitoring` stream (no static rows).
class DoctorMonitoringScreen extends StatefulWidget {
  const DoctorMonitoringScreen({super.key});

  @override
  State<DoctorMonitoringScreen> createState() => _DoctorMonitoringScreenState();
}

class _DoctorMonitoringScreenState extends State<DoctorMonitoringScreen> {
  String? _patientId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyPatientsViewModel>();
    final service = context.read<DoctorService>();
    final patients = vm.filtered;
    if (_patientId == null && patients.isNotEmpty) {
      _patientId = patients.first.uid;
    }
    if (_patientId != null &&
        !patients.any((p) => p.uid == _patientId)) {
      _patientId = patients.isNotEmpty ? patients.first.uid : null;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DoctorPageHeader(
            title: DoctorStrings.monitoringTitle,
            subtitle: DoctorStrings.monitoringPageSubtitle,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(_patientId),
            initialValue: _patientId,
            decoration: InputDecoration(
              labelText: DoctorStrings.selectPatient,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: DoctorColors.cardBorder),
              ),
            ),
            items: patients
                .map(
                  (PatientModel p) => DropdownMenuItem(
                    value: p.uid,
                    child: Text(p.fullName),
                  ),
                )
                .toList(),
            onChanged: patients.isEmpty
                ? null
                : (v) => setState(() => _patientId = v),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _patientId == null
                ? Center(
                    child: Text(
                      DoctorStrings.noPatientsForMonitoring,
                      style: GoogleFonts.inter(
                        color: DoctorColors.textSecondary,
                      ),
                    ),
                  )
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: service.watchPregnancyMonitoring(_patientId!),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final rows = snap.data!;
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DoctorSurfaceCard(
                              child: DoctorFlMonitoringChart(
                                rows: rows,
                                primaryKey: 'weight',
                                secondaryKey: 'sugarLevel',
                                title: DoctorStrings.monitoringChartTitle,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              DoctorStrings.measurementsLog,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DoctorSurfaceCard(
                              padding: EdgeInsets.zero,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(
                                      label: Text(DoctorStrings.colDate),
                                    ),
                                    DataColumn(
                                      label: Text(DoctorStrings.colWeight),
                                    ),
                                    DataColumn(
                                      label: Text(DoctorStrings.colGlucose),
                                    ),
                                    DataColumn(
                                      label: Text(DoctorStrings.colPressure),
                                    ),
                                    DataColumn(
                                      label: Text(DoctorStrings.colPulse),
                                    ),
                                  ],
                                  rows: rows.reversed.take(25).map((r) {
                                    final ts = r['createdAt'];
                                    final date = ts is Timestamp
                                        ? DateFormat.yMMMd()
                                            .add_Hm()
                                            .format(ts.toDate())
                                        : '—';
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(date)),
                                        DataCell(Text('${r['weight'] ?? '—'}')),
                                        DataCell(Text('${r['sugarLevel'] ?? '—'}')),
                                        DataCell(Text('${r['bloodPressure'] ?? '—'}')),
                                        DataCell(Text('${r['heartbeat'] ?? '—'}')),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
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

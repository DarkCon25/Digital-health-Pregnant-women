import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/nurse_colors.dart';
import '../../core/nurse_strings.dart';
import '../../viewmodels/nurse/nurse_patients_viewmodel.dart';
import '../../widgets/nurse/nurse_screen_chrome.dart';
import '../../widgets/nurse/patient_quick_actions.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({
    super.key,
    required this.onOpenMonitoring,
    required this.onOpenDetails,
  });

  final void Function(String patientId) onOpenMonitoring;
  final void Function(String patientId) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NursePatientsViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NursePageHeader(
            title: NurseStrings.pagePatients,
            subtitle: NurseStrings.searchHint,
          ),
          const SizedBox(height: 16),
          NurseSurfaceCard(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 720;
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        onChanged: vm.setSearch,
                        decoration: _dec(NurseStrings.searchHint),
                      ),
                      const SizedBox(height: 12),
                      _dropdown(
                        vm.statusFilter.isEmpty ? '' : vm.statusFilter,
                        NurseStrings.filterStatus,
                        const [
                          DropdownMenuItem(value: '', child: Text(NurseStrings.filterAll)),
                          DropdownMenuItem(value: 'stable', child: Text('Stable')),
                          DropdownMenuItem(value: 'critical', child: Text('Critical')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                        ],
                        (v) => vm.setStatusFilter(v ?? ''),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: vm.setSearch,
                        decoration: _dec(NurseStrings.searchHint),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 130,
                      child: _dropdown(
                        vm.statusFilter.isEmpty ? '' : vm.statusFilter,
                        NurseStrings.filterStatus,
                        const [
                          DropdownMenuItem(value: '', child: Text(NurseStrings.filterAll)),
                          DropdownMenuItem(value: 'stable', child: Text('Stable')),
                          DropdownMenuItem(value: 'critical', child: Text('Critical')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                        ],
                        (v) => vm.setStatusFilter(v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: _dropdown(
                        vm.roomFilter.isEmpty ? '' : vm.roomFilter,
                        NurseStrings.filterRoom,
                        [
                          const DropdownMenuItem(value: '', child: Text(NurseStrings.filterAll)),
                          ...vm.roomOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))),
                        ],
                        (v) => vm.setRoomFilter(v ?? ''),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: vm.filtered.isEmpty
                ? Center(
                    child: Text(
                      NurseStrings.noPatients,
                      style: GoogleFonts.inter(color: NurseColors.textSecondary),
                    ),
                  )
                : NurseSurfaceCard(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(NurseColors.tint),
                        columns: const [
                          DataColumn(label: Text(NurseStrings.colFileNo)),
                          DataColumn(label: Text(NurseStrings.colName)),
                          DataColumn(label: Text(NurseStrings.colPregnancy)),
                          DataColumn(label: Text(NurseStrings.colDelivery)),
                          DataColumn(label: Text(NurseStrings.colCare)),
                          DataColumn(label: Text(NurseStrings.colRoom)),
                          DataColumn(label: Text(NurseStrings.colActions)),
                        ],
                        rows: vm.filtered.map((p) {
                          final month = p.pregnancyMonth;
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                p.id.length > 8 ? '${p.id.substring(0, 8)}…' : p.id,
                                style: GoogleFonts.inter(fontSize: 12),
                              )),
                              DataCell(Text(p.fullName)),
                              DataCell(Text(month != null ? '$month mo. / ${month} m.' : '—')),
                              DataCell(Text(p.deliveryType ?? '—')),
                              DataCell(Text(p.careNeeded ? NurseStrings.yes : NurseStrings.no)),
                              DataCell(Text(p.roomNumber ?? '—')),
                              DataCell(
                                PatientQuickActions(
                                  onMonitor: () => onOpenMonitoring(p.id),
                                  onDetails: () => onOpenDetails(p.id),
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
      ),
    );
  }

  static InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: NurseColors.pageBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  static Widget _dropdown(
    String value,
    String label,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label$value'),
      initialValue: value.isEmpty ? '' : value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: NurseColors.pageBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

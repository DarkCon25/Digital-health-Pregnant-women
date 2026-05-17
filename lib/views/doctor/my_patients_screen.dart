import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../core/routes.dart';
import '../../viewmodels/doctor/my_patients_viewmodel.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

class MyPatientsScreen extends StatelessWidget {
  const MyPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MyPatientsViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DoctorPageHeader(
            title: DoctorStrings.patientsListTitle,
            subtitle: DoctorStrings.patientsListSubtitle,
          ),
          const SizedBox(height: 20),
          DoctorSurfaceCard(
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
                        decoration: InputDecoration(
                          hintText: DoctorStrings.searchPatientsHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: DoctorColors.pageBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: DoctorColors.cardBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('room_${vm.roomFilter}'),
                        initialValue:
                            vm.roomFilter.isEmpty ? '' : vm.roomFilter,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: DoctorStrings.filterRoom,
                          filled: true,
                          fillColor: DoctorColors.pageBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text(DoctorStrings.filterAll),
                          ),
                          ...vm.roomOptions.map(
                            (r) =>
                                DropdownMenuItem(value: r, child: Text(r)),
                          ),
                        ],
                        onChanged: (v) => vm.setRoomFilter(v ?? ''),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey(vm.statusFilter),
                        initialValue:
                            vm.statusFilter.isEmpty ? '' : vm.statusFilter,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: DoctorStrings.filterStatus,
                          filled: true,
                          fillColor: DoctorColors.pageBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text(DoctorStrings.filterAll),
                          ),
                          DropdownMenuItem(
                            value: 'stable',
                            child: Text(DoctorStrings.statusStable),
                          ),
                          DropdownMenuItem(
                            value: 'critical',
                            child: Text(DoctorStrings.statusCritical),
                          ),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text(DoctorStrings.statusActive),
                          ),
                        ],
                        onChanged: vm.setStatusFilter,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onChanged: vm.setSearch,
                        decoration: InputDecoration(
                          hintText: DoctorStrings.searchPatientsHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: DoctorColors.pageBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: DoctorColors.cardBorder,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('room_${vm.roomFilter}'),
                        initialValue:
                            vm.roomFilter.isEmpty ? '' : vm.roomFilter,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: DoctorStrings.filterRoom,
                          filled: true,
                          fillColor: DoctorColors.pageBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text(DoctorStrings.filterAll),
                          ),
                          ...vm.roomOptions.map(
                            (r) =>
                                DropdownMenuItem(value: r, child: Text(r)),
                          ),
                        ],
                        onChanged: (v) => vm.setRoomFilter(v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(vm.statusFilter),
                        initialValue:
                            vm.statusFilter.isEmpty ? '' : vm.statusFilter,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: DoctorStrings.filterStatus,
                          filled: true,
                          fillColor: DoctorColors.pageBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text(DoctorStrings.filterAll),
                          ),
                          DropdownMenuItem(
                            value: 'stable',
                            child: Text(DoctorStrings.statusStable),
                          ),
                          DropdownMenuItem(
                            value: 'critical',
                            child: Text(DoctorStrings.statusCritical),
                          ),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text(DoctorStrings.statusActive),
                          ),
                        ],
                        onChanged: vm.setStatusFilter,
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
                ? DoctorSurfaceCard(
                    child: Center(
                      child: Text(
                        DoctorStrings.noMatchingPatients,
                        style: GoogleFonts.inter(
                          color: DoctorColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : DoctorSurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${DoctorStrings.pagePatients} (${vm.filtered.length})',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: DoctorColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth:
                                    MediaQuery.sizeOf(context).width - 100,
                              ),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  DoctorColors.lavenderTint,
                                ),
                                columns: const [
                                  DataColumn(label: Text(DoctorStrings.colId)),
                                  DataColumn(label: Text(DoctorStrings.colName)),
                                  DataColumn(label: Text(DoctorStrings.colAge)),
                                  DataColumn(
                                    label: Text(DoctorStrings.colAdmission),
                                  ),
                                  DataColumn(
                                      label: Text(DoctorStrings.colRoom)),
                                  DataColumn(
                                    label: Text(DoctorStrings.colStatus),
                                  ),
                                  DataColumn(
                                    label: Text(DoctorStrings.colActions),
                                  ),
                                ],
                                rows: vm.pagedPatients.map((p) {
                                  final st = p.status.toLowerCase();
                                  final color = st == 'critical'
                                      ? DoctorColors.critical
                                      : DoctorColors.success;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                        p.uid.length > 8
                                            ? '${p.uid.substring(0, 8)}…'
                                            : p.uid,
                                        style:
                                            GoogleFonts.inter(fontSize: 12),
                                      )),
                                      DataCell(Text(p.fullName)),
                                      DataCell(Text('${p.age ?? "—"}')),
                                      DataCell(Text(
                                        DateFormat.yMMMd()
                                            .format(p.createdAt),
                                      )),
                                      DataCell(Text(p.roomNumber ?? '—')),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            p.status,
                                            style: GoogleFonts.inter(
                                              color: color,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          tooltip:
                                              DoctorStrings.openMedicalFile,
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            color: DoctorColors.primary,
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.doctorMedicalFile,
                                              arguments: p.uid,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                DoctorStrings.pageIndicator(
                                  vm.pageIndex + 1,
                                  vm.pageCount,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: DoctorColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: vm.pageIndex > 0
                                    ? () => vm.setPage(vm.pageIndex - 1)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                              IconButton(
                                onPressed: vm.pageIndex < vm.pageCount - 1
                                    ? () => vm.setPage(vm.pageIndex + 1)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

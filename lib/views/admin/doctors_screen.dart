import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../core/admin_doctors_strings.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/add_doctor_dialog.dart';
import '../../widgets/admin/assign_patient_to_doctor_dialog.dart';
import '../../widgets/admin/data_table_widget.dart';
import '../../widgets/admin/edit_doctor_dialog.dart';
import 'doctor_profile_screen.dart';

// HerCare — Admin doctors: real-time Firestore, filters, CRUD, assign, availability.

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final _search = TextEditingController();
  String _specialtyFilter = '';
  String _statusFilter = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openProfile(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminDashboardViewModel>(),
          child: DoctorProfileScreen(
            doctorId: id,
            initialData: data,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AdminDoctorsStrings.pageTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => showAddDoctorDialog(context, service),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  AdminDoctorsStrings.addDoctor,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _filterBar(),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: service.getDoctorsStream(),
            builder: (context, snapshot) {
              final loading =
                  snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData;

              if (snapshot.hasError) {
                return _errorCard('${snapshot.error}');
              }

              final raw = snapshot.data?.docs ?? [];
              final specialties = <String>{};
              for (final d in raw) {
                final m = d.data()! as Map<String, dynamic>;
                final s = '${m['specialty'] ?? ''}'.trim();
                if (s.isNotEmpty) specialties.add(s);
              }
              final sortedSpecs = specialties.toList()..sort();

              final q = _search.text.trim().toLowerCase();
              final docs = raw.where((doc) {
                final data = doc.data()! as Map<String, dynamic>;
                final fn =
                    '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                        .toLowerCase();
                final em = '${data['email'] ?? ''}'.toLowerCase();
                final ph = '${data['phone'] ?? ''}'.toLowerCase();
                final spec = '${data['specialty'] ?? ''}'.trim();
                final st = '${data['status'] ?? 'active'}';

                if (_specialtyFilter.isNotEmpty && spec != _specialtyFilter) {
                  return false;
                }
                if (_statusFilter.isNotEmpty && st != _statusFilter) {
                  return false;
                }
                if (q.isEmpty) return true;
                return fn.contains(q) || em.contains(q) || ph.contains(q);
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sortedSpecs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          Text(
                            '${AdminDoctorsStrings.filterSpecialty}:',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textSecondary,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text(AdminDoctorsStrings.filterAll),
                            selected: _specialtyFilter.isEmpty,
                            onSelected: (_) =>
                                setState(() => _specialtyFilter = ''),
                          ),
                          ...sortedSpecs.map(
                            (s) => ChoiceChip(
                              label: Text(s),
                              selected: _specialtyFilter == s,
                              onSelected: (_) =>
                                  setState(() => _specialtyFilter = s),
                            ),
                          ),
                        ],
                      ),
                    ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tableWidth =
                          constraints.maxWidth < 1240 ? 1240.0 : constraints.maxWidth;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: tableWidth,
                          child: AdminDataTable(
                        title:
                            '${AdminDoctorsStrings.tableTitle} (${docs.length})',
                        isLoading: loading,
                        columns: const [
                          AdminDoctorsStrings.colName,
                          AdminDoctorsStrings.colEmail,
                          AdminDoctorsStrings.colPhone,
                          AdminDoctorsStrings.colSpecialty,
                          AdminDoctorsStrings.colPatients,
                          AdminDoctorsStrings.colAvailable,
                          AdminDoctorsStrings.colStatus,
                          AdminDoctorsStrings.colActions,
                        ],
                        rows: docs.map((doc) {
                          final data = doc.data()! as Map<String, dynamic>;
                          final fullName =
                              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                                  .trim();
                          final displayName =
                              fullName.isEmpty ? doc.id : fullName;
                          final email = '${data['email'] ?? '—'}';
                          final phone = '${data['phone'] ?? '—'}';
                          final specialty = '${data['specialty'] ?? '—'}';
                          final patients = data['patients'] is int
                              ? data['patients'] as int
                              : int.tryParse('${data['patients'] ?? 0}') ?? 0;
                          final isAvailable = data['isAvailable'] != false;

                          return [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      AdminColors.primaryBluePale,
                                  backgroundImage:
                                      (data['profileImage'] as String?) !=
                                                  null &&
                                              (data['profileImage'] as String)
                                                  .isNotEmpty
                                          ? NetworkImage(
                                              data['profileImage'] as String,
                                            )
                                          : null,
                                  child:
                                      (data['profileImage'] as String?) ==
                                                  null ||
                                              (data['profileImage'] as String)
                                                  .isEmpty
                                          ? Text(
                                              displayName.isNotEmpty
                                                  ? displayName[0]
                                                      .toUpperCase()
                                                  : 'D',
                                              style: const TextStyle(
                                                color: AdminColors.primaryBlue,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            )
                                          : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AdminColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              email,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AdminColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              phone,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AdminColors.textSecondary,
                              ),
                            ),
                            Text(
                              specialty,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AdminColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$patients',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Switch.adaptive(
                              value: isAvailable,
                              activeTrackColor:
                                  AdminColors.primaryBlue.withValues(alpha: 0.45),
                              activeThumbColor: AdminColors.primaryBlue,
                              onChanged: (v) async {
                                await service.setDoctorAvailability(
                                  doctorId: doc.id,
                                  isAvailable: v,
                                );
                              },
                            ),
                            StatusBadge(
                              status: '${data['status'] ?? 'active'}',
                            ),
                            TableActions(
                              onView: () => _openProfile(
                                context,
                                doc.id,
                                data,
                              ),
                              onAssign: () => showAssignPatientToDoctorDialog(
                                context,
                                service,
                                doctorId: doc.id,
                                doctorName: displayName,
                              ),
                              onEdit: () => showEditDoctorDialog(
                                context,
                                service,
                                doc.id,
                                data,
                              ),
                              onDelete: () async {
                                final ok = await service.deleteDoctor(doc.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? AdminDoctorsStrings
                                                .doctorDeleted
                                            : '${AdminDoctorsStrings.errorPrefix}: delete',
                                      ),
                                      backgroundColor: ok
                                          ? AdminColors.success
                                          : AdminColors.danger,
                                    ),
                                  );
                                }
                              },
                            ),
                          ];
                        }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AdminColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: AdminDoctorsStrings.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AdminColors.pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              AdminDoctorsStrings.filterStatus,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AdminColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _statusFilter,
              items: const [
                DropdownMenuItem(
                  value: '',
                  child: Text(AdminDoctorsStrings.filterAll),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text(AdminDoctorsStrings.statusActive),
                ),
                DropdownMenuItem(
                  value: 'leave',
                  child: Text(AdminDoctorsStrings.statusLeave),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text(AdminDoctorsStrings.statusInactive),
                ),
              ],
              onChanged: (v) => setState(() => _statusFilter = v ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Card(
      color: AdminColors.dangerBg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AdminColors.danger),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${AdminDoctorsStrings.errorPrefix}: $message\n'
                'Firestore index may be required for role + createdAt.',
                style: GoogleFonts.inter(
                  color: AdminColors.danger,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

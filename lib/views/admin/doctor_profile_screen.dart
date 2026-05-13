import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/admin_colors.dart';
import '../../core/admin_doctors_strings.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/data_table_widget.dart';
import '../../widgets/admin/edit_doctor_dialog.dart';
import '../../widgets/admin/assign_patient_to_doctor_dialog.dart';

/// Full doctor profile — live Firestore document + assigned patients stream.
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({
    super.key,
    required this.doctorId,
    required this.initialData,
  });

  final String doctorId;
  final Map<String, dynamic> initialData;

  String get _fullName =>
      '${initialData['firstName'] ?? ''} ${initialData['lastName'] ?? ''}'
          .trim();

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

    return Scaffold(
      backgroundColor: AdminColors.pageBg,
      appBar: AppBar(
        title: Text(
          AdminDoctorsStrings.profileTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: service.watchDoctor(doctorId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${AdminDoctorsStrings.errorPrefix}: ${snap.error}',
                  style: GoogleFonts.inter(color: AdminColors.danger),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = Map<String, dynamic>.from(
            (snap.data!.data() as Map?) ?? const {},
          );
          final name =
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          final displayName = name.isEmpty ? _fullName : name;
          final email = '${data['email'] ?? ''}';
          final phone = '${data['phone'] ?? '—'}';
          final specialty = '${data['specialty'] ?? '—'}';
          final status = '${data['status'] ?? 'active'}';
          final patientsCount = data['patients'] is int
              ? data['patients'] as int
              : int.tryParse('${data['patients'] ?? 0}') ?? 0;
          final isAvailable = data['isAvailable'] != false;
          final created = data['createdAt'];
          String createdLabel = '—';
          if (created is Timestamp) {
            createdLabel =
                DateFormat.yMMMd().add_Hm().format(created.toDate());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerCard(
                  context,
                  service,
                  displayName,
                  email,
                  phone,
                  specialty,
                  status,
                  patientsCount,
                  isAvailable,
                  createdLabel,
                  data,
                ),
                const SizedBox(height: 20),
                Text(
                  AdminDoctorsStrings.assignedPatients,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: service.getAssignedPatientsStream(doctorId),
                  builder: (context, psnap) {
                    if (!psnap.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final pdocs = psnap.data!.docs;
                    if (pdocs.isEmpty) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AdminColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            AdminDoctorsStrings.noAssignedPatients,
                            style: GoogleFonts.inter(
                              color: AdminColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AdminColors.border),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pdocs.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final m =
                              pdocs[i].data()! as Map<String, dynamic>;
                          final pn =
                              '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'
                                  .trim();
                          return ListTile(
                            title: Text(
                              pn.isEmpty ? pdocs[i].id : pn,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${m['email'] ?? ''}',
                              style: GoogleFonts.inter(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headerCard(
    BuildContext context,
    AdminService service,
    String displayName,
    String email,
    String phone,
    String specialty,
    String status,
    int patientsCount,
    bool isAvailable,
    String createdLabel,
    Map<String, dynamic> data,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AdminColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AdminColors.primaryBluePale,
                  backgroundImage: (data['profileImage'] as String?) != null &&
                          (data['profileImage'] as String).isNotEmpty
                      ? NetworkImage(data['profileImage'] as String)
                      : null,
                  child: (data['profileImage'] as String?) == null ||
                          (data['profileImage'] as String).isEmpty
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'D',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AdminColors.primaryBlue,
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
                        displayName,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(email,
                          style: GoogleFonts.inter(
                            color: AdminColors.textSecondary,
                          )),
                      Text(phone,
                          style: GoogleFonts.inter(
                            color: AdminColors.textSecondary,
                          )),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusBadge(status: status),
                          Chip(
                            label: Text(
                              '${AdminDoctorsStrings.colPatients}: $patientsCount',
                              style: GoogleFonts.inter(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${AdminDoctorsStrings.specialty}: $specialty',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${AdminDoctorsStrings.uid}: $doctorId',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AdminColors.textSecondary,
              ),
            ),
            Text(
              '${AdminDoctorsStrings.createdAt}: $createdLabel',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AdminColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AdminDoctorsStrings.availability,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AdminDoctorsStrings.isAvailableLabel,
                style: GoogleFonts.inter(fontSize: 14),
              ),
              value: isAvailable,
              activeThumbColor: AdminColors.primaryBlue,
              onChanged: (v) async {
                await service.setDoctorAvailability(
                  doctorId: doctorId,
                  isAvailable: v,
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showEditDoctorDialog(
                    context,
                    service,
                    doctorId,
                    data,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(AdminDoctorsStrings.edit),
                ),
                OutlinedButton.icon(
                  onPressed: () => showAssignPatientToDoctorDialog(
                    context,
                    service,
                    doctorId: doctorId,
                    doctorName: displayName,
                  ),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: Text(AdminDoctorsStrings.assignShort),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          AdminDoctorsStrings.deleteDoctorConfirmTitle,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                        content: Text(
                          AdminDoctorsStrings.deleteDoctorConfirmBody,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(AdminDoctorsStrings.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.danger,
                            ),
                            child: Text(AdminDoctorsStrings.delete),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      final deleted = await service.deleteDoctor(doctorId);
                      if (context.mounted) {
                        if (deleted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AdminDoctorsStrings.doctorDeleted),
                              backgroundColor: AdminColors.success,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${AdminDoctorsStrings.errorPrefix}: delete',
                              ),
                              backgroundColor: AdminColors.danger,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(AdminDoctorsStrings.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

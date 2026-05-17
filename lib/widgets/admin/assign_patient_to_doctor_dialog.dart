import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/admin_colors.dart';
import '../../core/admin_doctors_strings.dart';
import '../../services/admin_service.dart';

Future<void> showAssignPatientToDoctorDialog(
  BuildContext context,
  AdminService service, {
  required String doctorId,
  required String doctorName,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AssignPatientToDoctorDialog(
      service: service,
      doctorId: doctorId,
      doctorName: doctorName,
    ),
  );
}

class AssignPatientToDoctorDialog extends StatefulWidget {
  const AssignPatientToDoctorDialog({
    super.key,
    required this.service,
    required this.doctorId,
    required this.doctorName,
  });

  final AdminService service;
  final String doctorId;
  final String doctorName;

  @override
  State<AssignPatientToDoctorDialog> createState() =>
      _AssignPatientToDoctorDialogState();
}

class _AssignPatientToDoctorDialogState
    extends State<AssignPatientToDoctorDialog> {
  final _search = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _assign(String patientId) async {
    setState(() => _busy = true);
    final ok = await widget.service.assignDoctorToPatient(
      patientId: patientId,
      doctorId: widget.doctorId,
      doctorName: widget.doctorName,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (ok) {
      Navigator.pop(context);
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(AdminDoctorsStrings.assignSuccess),
          backgroundColor: AdminColors.success,
        ),
      );
    } else {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(AdminDoctorsStrings.assignFailed),
          backgroundColor: AdminColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AdminDoctorsStrings.assignPatientTitle,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                widget.doctorName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AdminColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
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
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AdminDoctorsStrings.assignPatientHint,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: widget.service.getPatientsStream(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AdminColors.primaryBlue,
                        ),
                      );
                    }
                    final q = _search.text.trim().toLowerCase();
                    final docs = snap.data!.docs.where((d) {
                      final m = d.data()! as Map<String, dynamic>;
                      if (m['role'] != 'patient') return false;
                      final fn = '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'
                          .toLowerCase();
                      final em = '${m['email'] ?? ''}'.toLowerCase();
                      final ph = '${m['phone'] ?? ''}'.toLowerCase();
                      if (q.isEmpty) return true;
                      return fn.contains(q) ||
                          em.contains(q) ||
                          ph.contains(q);
                    }).toList();

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          AdminDoctorsStrings.noPatientsMatch,
                          style: GoogleFonts.inter(
                            color: AdminColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final m = doc.data()! as Map<String, dynamic>;
                        final name =
                            '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'
                                .trim();
                        final assignedId =
                            m['assignedDoctorId'] as String? ?? '';
                        final isThisDoctor =
                            assignedId == widget.doctorId;
                        final subtitle = assignedId.isEmpty
                            ? '— / —'
                            : (isThisDoctor
                                ? 'Already assigned / Déjà assignée'
                                : '${m['assignedDoctorName'] ?? assignedId}');

                        return ListTile(
                          enabled: !_busy && !isThisDoctor,
                          title: Text(
                            name.isEmpty ? doc.id : name,
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            subtitle,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          trailing: isThisDoctor
                              ? const Icon(Icons.check_circle,
                                  color: AdminColors.success)
                              : TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _assign(doc.id),
                                  child: const Text(AdminDoctorsStrings.assign),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

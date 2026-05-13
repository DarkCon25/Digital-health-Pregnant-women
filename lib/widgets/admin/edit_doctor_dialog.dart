import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/admin_colors.dart';
import '../../core/admin_doctors_strings.dart';
import '../../services/admin_service.dart';

Future<void> showEditDoctorDialog(
  BuildContext context,
  AdminService service,
  String docId,
  Map<String, dynamic> data,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => EditDoctorDialog(
      service: service,
      docId: docId,
      data: data,
    ),
  );
}

class EditDoctorDialog extends StatefulWidget {
  const EditDoctorDialog({
    super.key,
    required this.service,
    required this.docId,
    required this.data,
  });

  final AdminService service;
  final String docId;
  final Map<String, dynamic> data;

  @override
  State<EditDoctorDialog> createState() => _EditDoctorDialogState();
}

class _EditDoctorDialogState extends State<EditDoctorDialog> {
  late final TextEditingController _specialty;
  late final TextEditingController _phone;
  late String _status;
  late bool _isAvailable;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _specialty = TextEditingController(text: '${widget.data['specialty'] ?? ''}');
    _phone = TextEditingController(text: '${widget.data['phone'] ?? ''}');
    _status = '${widget.data['status'] ?? 'active'}';
    _isAvailable = widget.data['isAvailable'] != false;
  }

  @override
  void dispose() {
    _specialty.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final ok = await widget.service.updateDoctor(
      widget.docId,
      {
        'specialty': _specialty.text.trim(),
        'phone': _phone.text.trim(),
        'status': _status,
        'isAvailable': _isAvailable,
      },
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AdminDoctorsStrings.doctorUpdated),
          backgroundColor: AdminColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AdminDoctorsStrings.errorPrefix}: update failed / échec',
          ),
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
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AdminDoctorsStrings.editDialogTitle,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.data['firstName'] ?? ''} ${widget.data['lastName'] ?? ''}'
                  '\n${widget.data['email'] ?? ''}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AdminColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _field(
                  AdminDoctorsStrings.specialty,
                  _specialty,
                  Icons.medical_services_outlined,
                ),
                const SizedBox(height: 14),
                _field(
                  AdminDoctorsStrings.phone,
                  _phone,
                  Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                Text(
                  AdminDoctorsStrings.colStatus,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  key: ValueKey(_status),
                  initialValue: _status,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AdminColors.pageBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AdminColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: [
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
                  onChanged: (v) {
                    if (v != null) setState(() => _status = v);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AdminDoctorsStrings.isAvailableLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: _isAvailable,
                  activeThumbColor: AdminColors.primaryBlue,
                  onChanged: (v) => setState(() => _isAvailable = v),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AdminDoctorsStrings.cancel,
                          style: GoogleFonts.inter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                AdminDoctorsStrings.save,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: keyboard,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: AdminColors.pageBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AdminColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AdminColors.primaryBlue,
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

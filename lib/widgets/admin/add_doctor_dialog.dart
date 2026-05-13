import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/admin_colors.dart';
import '../../core/admin_doctors_strings.dart';
import '../../services/admin_service.dart';

Future<void> showAddDoctorDialog(
  BuildContext context,
  AdminService service,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AddDoctorDialog(service: service),
  );
}

class AddDoctorDialog extends StatefulWidget {
  const AddDoctorDialog({super.key, required this.service});

  final AdminService service;

  @override
  State<AddDoctorDialog> createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _specialty = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _specialty.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(AdminDoctorsStrings.fillRequired),
          backgroundColor: AdminColors.warning,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final id = await widget.service.addDoctor(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
      password: _password.text,
      phone: _phone.text,
      specialty: _specialty.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (id != null) {
      Navigator.pop(context);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(AdminDoctorsStrings.doctorAdded),
          backgroundColor: AdminColors.success,
        ),
      );
    } else {
      final code = widget.service.lastError ?? '';
      final details = switch (code) {
        'email-already-in-use' =>
          'Email already used / E-mail deja utilise',
        'invalid-email' => 'Invalid email format / Format e-mail invalide',
        'weak-password' =>
          'Weak password (min 6) / Mot de passe faible (min 6)',
        _ => code.isNotEmpty ? code : 'unknown error / erreur inconnue',
      };
      messenger?.showSnackBar(
        SnackBar(
          content: Text('${AdminDoctorsStrings.errorPrefix}: $details'),
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Expanded(
                      child: Text(
                        AdminDoctorsStrings.addDialogTitle,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        AdminDoctorsStrings.firstName,
                        _firstName,
                        Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        AdminDoctorsStrings.lastName,
                        _lastName,
                        Icons.person_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _field(
                  AdminDoctorsStrings.email,
                  _email,
                  Icons.email_outlined,
                  keyboard: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _field(
                  AdminDoctorsStrings.password,
                  _password,
                  Icons.lock_outline_rounded,
                  obscure: true,
                ),
                const SizedBox(height: 14),
                _field(
                  AdminDoctorsStrings.phone,
                  _phone,
                  Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _field(
                  AdminDoctorsStrings.specialty,
                  _specialty,
                  Icons.medical_services_outlined,
                ),
                const SizedBox(height: 24),
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
                        onPressed: _loading ? null : _submit,
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
                                AdminDoctorsStrings.add,
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
    bool obscure = false,
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
          obscureText: obscure,
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

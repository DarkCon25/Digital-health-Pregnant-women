import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../services/doctor_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/doctor/doctor_screen_chrome.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _emailCtrl = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _error = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _assign() async {
    final authVm = context.read<AuthViewModel>();
    final service = context.read<DoctorService>();
    final uid = authVm.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final name =
        authVm.currentUser?.fullName ?? DoctorStrings.doctorFallbackName;
    setState(() {
      _busy = true;
      _message = null;
      _error = false;
    });

    final code = await service.assignPatientToMe(
      doctorId: uid,
      doctorDisplayName: name,
      patientEmail: _emailCtrl.text,
    );

    setState(() {
      _busy = false;
      if (code == null) {
        _message = DoctorStrings.linkSuccess;
        _error = false;
        _emailCtrl.clear();
      } else if (code == 'not_found') {
        _message = DoctorStrings.linkNotFound;
        _error = true;
      } else if (code == 'not_patient') {
        _message = DoctorStrings.linkNotPatient;
        _error = true;
      } else if (code == 'already_assigned') {
        _message = DoctorStrings.linkAlreadyAssigned;
        _error = false;
      } else if (code == 'empty_email') {
        _message = DoctorStrings.linkEnterEmail;
        _error = true;
      } else {
        _message = code;
        _error = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DoctorPageHeader(
                title: DoctorStrings.pageAddPatient,
                subtitle: DoctorStrings.linkPatientDescription,
              ),
              const SizedBox(height: 20),
              DoctorSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      DoctorStrings.linkExistingPatient,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: DoctorColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: DoctorStrings.patientEmailLabel,
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
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _assign,
                      style: FilledButton.styleFrom(
                        backgroundColor: DoctorColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              DoctorStrings.assignPatient,
                              style:
                                  GoogleFonts.inter(fontWeight: FontWeight.w700),
                            ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _message!,
                        style: GoogleFonts.inter(
                          color: _error
                              ? DoctorColors.critical
                              : DoctorColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

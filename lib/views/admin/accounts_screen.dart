import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../core/constants.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/data_table_widget.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final Map<String, String> _selectedRoles = {};
  String? _statusMessage;
  bool _isSaving = false;

  final List<String> _roleOptions = [
    AppConstants.roleAdmin,
    AppConstants.roleDoctor,
    AppConstants.roleNurse,
    AppConstants.rolePatient,
  ];

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accounts & Role Management',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage users, change roles, and keep patient, doctor, and nurse access aligned with your workflow.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AdminColors.textSecondary,
            ),
          ),
          if (_statusMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AdminColors.primaryBluePale,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AdminColors.primaryBlue),
              ),
              child: Text(
                _statusMessage!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AdminColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: service.getAllUsersStream(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              return AdminDataTable(
                title: 'User Accounts (${docs.length})',
                isLoading: snapshot.connectionState == ConnectionState.waiting,
                columns: const [
                  'User',
                  'Email',
                  'Current Role',
                  'Change To',
                  'Action',
                  'Password',
                  'Admin Set',
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final currentRole =
                      data['role'] as String? ?? AppConstants.rolePatient;
                  final selectedRole = _selectedRoles[doc.id] ?? currentRole;

                  return [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AdminColors.primaryBluePale,
                          child: Text(
                            data['firstName']
                                    ?.toString()
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              color: AdminColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data['firstName'] ?? 'User'} ${data['lastName'] ?? ''}'
                                    .trim(),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['uid'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AdminColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      data['email'] ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AdminColors.primaryBluePale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        currentRole,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.primaryBlue,
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _roleOptions.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRoles[doc.id] = value;
                          });
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: _isSaving || selectedRole == currentRole
                          ? null
                          : () =>
                              _updateUserRole(service, doc.id, selectedRole),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(90, 38),
                      ),
                      child: const Text('Save'),
                    ),
                    OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => _sendResetPassword(
                                service,
                                (data['email'] ?? '').toString(),
                              ),
                      child: const Text('Reset'),
                    ),
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () => _showSetPasswordDialog(
                                service: service,
                                uid: doc.id,
                                email: (data['email'] ?? '').toString(),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(110, 38),
                      ),
                      child: const Text('Set Password'),
                    ),
                  ];
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserRole(
    AdminService service,
    String uid,
    String role,
  ) async {
    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    final success = await service.updateUserRole(uid: uid, role: role);

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) {
          _statusMessage = 'Role updated successfully.';
          _selectedRoles.remove(uid);
        } else {
          _statusMessage = 'Unable to update role. Please try again.';
        }
      });
    }
  }

  Future<void> _sendResetPassword(
    AdminService service,
    String email,
  ) async {
    final target = email.trim();
    if (target.isEmpty) {
      setState(() {
        _statusMessage = 'User email is missing. Cannot send reset link.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    final success = await service.sendPasswordResetForUser(target);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (success) {
        _statusMessage = 'Password reset link sent to $target';
      } else {
        final code = service.lastError ?? 'unknown-error';
        _statusMessage = 'Failed to send password reset: $code';
      }
    });
  }

  Future<void> _showSetPasswordDialog({
    required AdminService service,
    required String uid,
    required String email,
  }) async {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool saving = false;
    String? error;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'Set Password',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email.isEmpty ? uid : email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AdminColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    error!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AdminColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final p1 = passwordCtrl.text.trim();
                      final p2 = confirmCtrl.text.trim();
                      if (p1.length < 6) {
                        setDialogState(() {
                          error = 'Password must be at least 6 characters.';
                        });
                        return;
                      }
                      if (p1 != p2) {
                        setDialogState(() {
                          error = 'Passwords do not match.';
                        });
                        return;
                      }

                      setDialogState(() {
                        saving = true;
                        error = null;
                      });
                      final ok = await service.setUserPasswordByAdmin(
                        uid: uid,
                        newPassword: p1,
                      );
                      if (!ctx.mounted || !mounted) return;
                      if (ok) {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _statusMessage = 'Password changed successfully.';
                        });
                      } else {
                        setDialogState(() {
                          saving = false;
                          error =
                              'Failed to change password: ${service.lastError ?? 'unknown-error'}';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/data_table_widget.dart';

// ============================================
// HerCare - Nurses Screen
// Écran des Infirmières
// ============================================

class NursesScreen extends StatelessWidget {
  const NursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nurses List / Liste des Infirmières',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),

              // Add Nurse Button
              ElevatedButton.icon(
                onPressed: () => _showAddNurseDialog(context, service),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add Nurse / Ajouter Infirmière',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.greenCard,
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

          const SizedBox(height: 20),

          // ── Nurses Table
          StreamBuilder<QuerySnapshot>(
            stream: service.getNursesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading nurses: ${snapshot.error}',
                    style: GoogleFonts.inter(color: AdminColors.danger),
                  ),
                );
              }

              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final docs = [...(snapshot.data?.docs ?? [])]
                ..sort((a, b) {
                  final aTs =
                      (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTs =
                      (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final aMs = aTs?.millisecondsSinceEpoch ?? 0;
                  final bMs = bTs?.millisecondsSinceEpoch ?? 0;
                  return bMs.compareTo(aMs);
                });

              return AdminDataTable(
                title: 'Nurses (${docs.length}) / Infirmières',
                isLoading: isLoading,
                columns: const [
                  'Name / Nom',
                  'Department / Service',
                  'Shift / Horaire',
                  'Status / Statut',
                  'Actions',
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullName = '${data['firstName'] ?? ''} '
                      '${data['lastName'] ?? ''}';

                  return [
                    // Name
                    Text(
                      fullName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textPrimary,
                      ),
                    ),

                    // Department / Service
                    Text(
                      data['department'] ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                    ),

                    // Shift / Horaire
                    _buildShiftBadge(data['shift'] ?? 'morning'),

                    // Status
                    StatusBadge(
                      status: data['status'] ?? 'active',
                    ),

                    // Actions
                    TableActions(
                      onEdit: () => _showEditNurseDialog(
                        context,
                        service,
                        doc.id,
                        data,
                      ),
                      onDelete: () => service.deleteNurse(doc.id),
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

  // Shift Badge / Badge horaire
  Widget _buildShiftBadge(String shift) {
    Color color;
    String label;

    switch (shift) {
      case 'morning':
        color = AdminColors.orangeCard;
        label = 'Morning / Matin';
        break;
      case 'afternoon':
        color = AdminColors.primaryBlue;
        label = 'Afternoon / Après-midi';
        break;
      case 'night':
        color = AdminColors.purpleCard;
        label = 'Night / Nuit';
        break;
      default:
        color = AdminColors.textSecondary;
        label = shift;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════
  // ADD NURSE DIALOG
  // ══════════════════════════════════════════
  void _showAddNurseDialog(
    BuildContext context,
    AdminService service,
  ) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final departmentCtrl = TextEditingController();
    String selectedShift = 'morning';
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Text(
                        'Add New Nurse / Ajouter Infirmière',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Name Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'First Name / Prénom',
                          controller: firstNameCtrl,
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          label: 'Last Name / Nom',
                          controller: lastNameCtrl,
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Email',
                    controller: emailCtrl,
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Password / Mot de passe',
                    controller: passwordCtrl,
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),

                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Phone / Téléphone',
                    controller: phoneCtrl,
                    icon: Icons.phone_outlined,
                    inputType: TextInputType.phone,
                  ),

                  const SizedBox(height: 14),
                  _buildFormField(
                    label: 'Department / Service',
                    controller: departmentCtrl,
                    icon: Icons.local_hospital_outlined,
                  ),

                  const SizedBox(height: 14),

                  // Shift Dropdown
                  Text(
                    'Shift / Horaire',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedShift,
                    onChanged: (v) => setDialogState(
                      () => selectedShift = v!,
                    ),
                    decoration: _dropdownDecoration(),
                    items: [
                      _buildDropdownItem(
                        'morning',
                        'Morning / Matin',
                      ),
                      _buildDropdownItem(
                        'afternoon',
                        'Afternoon / Après-midi',
                      ),
                      _buildDropdownItem(
                        'night',
                        'Night / Nuit',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel / Annuler',
                            style: GoogleFonts.inter(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setDialogState(() => isLoading = true);
                                  final id = await service.addNurse(
                                    firstName: firstNameCtrl.text,
                                    lastName: lastNameCtrl.text,
                                    email: emailCtrl.text,
                                    password: passwordCtrl.text,
                                    phone: phoneCtrl.text,
                                    department: departmentCtrl.text,
                                    shift: selectedShift,
                                  );

                                  if (id != null) {
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                      if (!context.mounted) return;
                                      _showSnackBar(
                                        context,
                                        'Nurse account created successfully.',
                                        AdminColors.success,
                                      );
                                    }
                                  } else {
                                    setDialogState(() => isLoading = false);
                                    if (!context.mounted) return;
                                    final code =
                                        service.lastError ?? 'unknown-error';
                                    _showSnackBar(
                                      context,
                                      'Cannot create nurse account: $code',
                                      AdminColors.danger,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.greenCard,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Add / Ajouter',
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
      ),
    );
  }

  // ══════════════════════════════════════════
  // EDIT NURSE DIALOG
  // ══════════════════════════════════════════
  void _showEditNurseDialog(
    BuildContext context,
    AdminService service,
    String docId,
    Map<String, dynamic> data,
  ) {
    final departmentCtrl = TextEditingController(
      text: data['department'] ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: data['phone'] ?? '',
    );
    String selectedShift = data['shift'] ?? 'morning';
    String selectedStatus = data['status'] ?? 'active';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Nurse / Modifier Infirmière',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                _buildFormField(
                  label: 'Department / Service',
                  controller: departmentCtrl,
                  icon: Icons.local_hospital_outlined,
                ),
                const SizedBox(height: 14),

                _buildFormField(
                  label: 'Phone / Téléphone',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 14),

                // Shift
                Text(
                  'Shift / Horaire',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedShift,
                  onChanged: (v) => setDialogState(
                    () => selectedShift = v!,
                  ),
                  decoration: _dropdownDecoration(),
                  items: [
                    _buildDropdownItem('morning', 'Morning / Matin'),
                    _buildDropdownItem('afternoon', 'Afternoon / Après-midi'),
                    _buildDropdownItem('night', 'Night / Nuit'),
                  ],
                ),
                const SizedBox(height: 14),

                // Status
                Text(
                  'Status / Statut',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  onChanged: (v) => setDialogState(
                    () => selectedStatus = v!,
                  ),
                  decoration: _dropdownDecoration(),
                  items: [
                    _buildDropdownItem('active', 'Active'),
                    _buildDropdownItem('leave', 'On Leave / En congé'),
                    _buildDropdownItem('inactive', 'Inactive'),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Cancel / Annuler',
                            style: GoogleFonts.inter()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await service.updateNurse(docId, {
                            'department': departmentCtrl.text,
                            'phone': phoneCtrl.text,
                            'shift': selectedShift,
                            'status': selectedStatus,
                          });
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            _showSnackBar(
                              context,
                              '✅ Updated! / Mis à jour!',
                              AdminColors.success,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.greenCard,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Save / Sauvegarder',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w700)),
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

  // ──────────────────────────────────────────
  // Helper Methods
  // ──────────────────────────────────────────

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
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
          controller: controller,
          keyboardType: inputType,
          obscureText: isPassword,
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
              borderSide:
                  const BorderSide(color: AdminColors.primaryBlue, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Text(label, style: GoogleFonts.inter(fontSize: 14)),
    );
  }
}

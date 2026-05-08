import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/data_table_widget.dart';

// ============================================
// HerCare - Doctors Screen
// Écran des Médecins
// ============================================

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

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
              // Page Title / Titre de la page
              Text(
                'Doctors List / Liste des Médecins',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),

              // Add Doctor Button / Bouton Ajouter Médecin
              ElevatedButton.icon(
                onPressed: () => _showAddDoctorDialog(context, service),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add Doctor / Ajouter Médecin',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
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

          const SizedBox(height: 20),

          // ── Doctors Table with Firebase Stream
          // ── Tableau médecins avec Firebase Stream
          StreamBuilder<QuerySnapshot>(
            stream: service.getDoctorsStream(),
            builder: (context, snapshot) {
              // Check loading state / Vérifier l'état de chargement
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              // Get documents / Obtenir les documents
              final docs = snapshot.data?.docs ?? [];

              return AdminDataTable(
                title: 'Doctors (${docs.length}) / Médecins',
                isLoading: isLoading,
                columns: const [
                  'Name / Nom',
                  'Phone / Téléphone',
                  'Specialty / Spécialité',
                  'Status / Statut',
                  'Actions',
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fullName = '${data['firstName'] ?? ''} '
                      '${data['lastName'] ?? ''}';

                  return [
                    // Name + Avatar
                    Row(
                      children: [
                        // Avatar circle / Cercle avatar
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              AdminColors.primaryBlue.withAlpha(38),
                          child: Text(
                            fullName.isNotEmpty
                                ? fullName[0].toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              color: AdminColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          fullName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Phone / Téléphone
                    Text(
                      data['phone'] ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                    ),

                    // Specialty / Spécialité
                    Text(
                      data['specialty'] ?? '-',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                    ),

                    // Status Badge / Badge statut
                    StatusBadge(
                      status: data['status'] ?? 'active',
                    ),

                    // Action Buttons / Boutons d'action
                    TableActions(
                      onEdit: () => _showEditDoctorDialog(
                        context,
                        service,
                        doc.id,
                        data,
                      ),
                      onDelete: () => service.deleteDoctor(doc.id),
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

  // ══════════════════════════════════════════
  // ADD DOCTOR DIALOG / DIALOGUE AJOUTER MÉDECIN
  // ══════════════════════════════════════════
  void _showAddDoctorDialog(
    BuildContext context,
    AdminService service,
  ) {
    // Controllers for form fields
    // Contrôleurs pour les champs du formulaire
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();
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
                  // ── Dialog Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button / Bouton fermer
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Text(
                        'Add New Doctor / Ajouter Médecin',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Name Row (First + Last)
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

                  // Email
                  _buildFormField(
                    label: 'Email',
                    controller: emailCtrl,
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

                  // Password / Mot de passe
                  _buildFormField(
                    label: 'Password / Mot de passe',
                    controller: passwordCtrl,
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),

                  const SizedBox(height: 14),

                  // Phone / Téléphone
                  _buildFormField(
                    label: 'Phone / Téléphone',
                    controller: phoneCtrl,
                    icon: Icons.phone_outlined,
                    inputType: TextInputType.phone,
                  ),

                  const SizedBox(height: 14),

                  // Specialty / Spécialité
                  _buildFormField(
                    label: 'Specialty / Spécialité',
                    controller: specialtyCtrl,
                    icon: Icons.medical_services_outlined,
                  ),

                  const SizedBox(height: 24),

                  // ── Action Buttons
                  Row(
                    children: [
                      // Cancel / Annuler
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

                      // Add / Ajouter
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  // Validate fields
                                  if (emailCtrl.text.isEmpty ||
                                      passwordCtrl.text.isEmpty) {
                                    return;
                                  }

                                  setDialogState(
                                    () => isLoading = true,
                                  );

                                  try {
                                    await service.addDoctor(
                                      firstName: firstNameCtrl.text,
                                      lastName: lastNameCtrl.text,
                                      email: emailCtrl.text,
                                      password: passwordCtrl.text,
                                      phone: phoneCtrl.text,
                                      specialty: specialtyCtrl.text,
                                    );

                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                      _showSnackBar(
                                        context,
                                        '✅ Doctor added successfully!'
                                        ' / Médecin ajouté!',
                                        AdminColors.success,
                                      );
                                    }
                                  } catch (e) {
                                    setDialogState(
                                      () => isLoading = false,
                                    );
                                    _showSnackBar(
                                      context,
                                      'Error: ${e.toString()}',
                                      AdminColors.danger,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.primaryBlue,
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
  // EDIT DOCTOR DIALOG / DIALOGUE MODIFIER
  // ══════════════════════════════════════════
  void _showEditDoctorDialog(
    BuildContext context,
    AdminService service,
    String docId,
    Map<String, dynamic> data,
  ) {
    final specialtyCtrl = TextEditingController(
      text: data['specialty'] ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: data['phone'] ?? '',
    );
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
                // Title / Titre
                Text(
                  'Edit Doctor / Modifier Médecin',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 20),

                // Specialty / Spécialité
                _buildFormField(
                  label: 'Specialty / Spécialité',
                  controller: specialtyCtrl,
                  icon: Icons.medical_services_outlined,
                ),

                const SizedBox(height: 14),

                // Phone / Téléphone
                _buildFormField(
                  label: 'Phone / Téléphone',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                ),

                const SizedBox(height: 14),

                // Status Dropdown / Menu déroulant statut
                Text(
                  'Status / Statut',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  onChanged: (value) => setDialogState(
                    () => selectedStatus = value!,
                  ),
                  decoration: InputDecoration(
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                        value: 'leave', child: Text('On Leave / En congé')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Inactive')),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Buttons
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
                        onPressed: () async {
                          await service.updateDoctor(
                            docId,
                            {
                              'specialty': specialtyCtrl.text,
                              'phone': phoneCtrl.text,
                              'status': selectedStatus,
                            },
                          );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            _showSnackBar(
                              context,
                              '✅ Updated successfully!'
                              ' / Mis à jour!',
                              AdminColors.success,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save / Sauvegarder',
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

  // ── Form Field Builder
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

  // ── Show SnackBar
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// NURSES SCREEN / ÉCRAN DES INFIRMIÈRES
// ══════════════════════════════════════════════

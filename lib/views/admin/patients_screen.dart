import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/data_table_widget.dart';
import 'patient_profile_screen.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Patients Screen
// Écran des patientes
// ════════════════════════════════════════════════════════════════

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title / Titre de la page
          Text(
            'Liste des patientes',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Patients table / Tableau des patientes
          StreamBuilder<QuerySnapshot>(
            stream: service.getPatientsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading patients: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: AdminColors.danger),
                  ),
                );
              }

              final loading =
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
                title: 'Patientes (${docs.length})',
                isLoading: loading,
                columns: const [
                  'Name',
                  'Wilaya',
                  'Status',
                  'Assigned Doctor',
                  'Babies',
                  'Actions',
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';
                  final babies =
                      List<String>.from(data['babies'] ?? []);
                  final doctorName =
                      data['assignedDoctorName'] ?? 'Not assigned';

                  return [
                    // Column 1 - Name with avatar
                    // Colonne 1 - Nom avec avatar
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: data['profileImage'] != null
                              ? NetworkImage(data['profileImage'] as String)
                              : null,
                          backgroundColor:
                              AdminColors.pink.withAlpha(38),
                          child: data['profileImage'] == null
                              ? Text(
                                  name.isNotEmpty ? name[0] : 'P',
                                  style: const TextStyle(
                                    color: AdminColors.pink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    // Column 2 - Wilaya
                    // Colonne 2 - Wilaya
                    Text(
                      data['wilaya'] ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AdminColors.textSecondary,
                      ),
                    ),

                    // Column 3 - Status badge
                    // Colonne 3 - Badge de statut
                    StatusBadge(status: data['status'] ?? 'active'),

                    // Column 4 - Assigned doctor button
                    // Colonne 4 - Bouton médecin assigné
                    GestureDetector(
                      onTap: () => _showAssignDoctorDialog(
                        context,
                        service,
                        doc.id,
                        name,
                        data['assignedDoctorId'] as String?,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: data['assignedDoctorId'] != null
                              ? AdminColors.successBg
                              : AdminColors.warningBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: data['assignedDoctorId'] != null
                                ? AdminColors.success
                                : AdminColors.warning,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              data['assignedDoctorId'] != null
                                  ? Icons.person_outline
                                  : Icons.person_add_outlined,
                              size: 14,
                              color: data['assignedDoctorId'] != null
                                  ? AdminColors.success
                                  : AdminColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctorName,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: data['assignedDoctorId'] != null
                                    ? AdminColors.success
                                    : AdminColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Column 5 - Babies counter + add button
                    // Colonne 5 - Compteur de bébés + bouton d'ajout
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 20,
                          color: AdminColors.primaryBlue,
                          onPressed: () => _showAddBabyDialog(
                            context,
                            service,
                            doc.id,
                            name,
                          ),
                          tooltip: 'Add baby',
                        ),
                        const SizedBox(width: 4),
                        if (babies.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showBabiesDialog(
                              context,
                              service,
                              doc.id,
                              name,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AdminColors.primaryBluePale,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${babies.length} baby(ies)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AdminColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Column 6 - Actions (edit / delete)
                    // Colonne 6 - Actions (modifier / supprimer)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'View',
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatientProfileScreen(patientId: doc.id),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _showEditPatientDialog(
                            context,
                            service,
                            doc.id,
                            data,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline, size: 18, color: AdminColors.danger),
                          onPressed: () => service.deletePatient(doc.id),
                        ),
                        IconButton(
                          tooltip: 'Print',
                          icon: const Icon(Icons.print_outlined, size: 18),
                          onPressed: () => _snack(context, 'Print request queued', AdminColors.primaryBlue),
                        ),
                        IconButton(
                          tooltip: 'Emergency',
                          icon: const Icon(Icons.emergency_outlined, size: 18, color: AdminColors.danger),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('emergency_alerts').add({
                              'patientId': doc.id,
                              'patientName': name,
                              'roomNumber': data['roomNumber'] ?? '-',
                              'severity': 'high',
                              'status': 'open',
                              'alertTime': FieldValue.serverTimestamp(),
                            });
                            if (context.mounted) {
                              _snack(context, 'Emergency alert sent', AdminColors.danger);
                            }
                          },
                        ),
                      ],
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

  // ════════════════════════════════════════════════════════════════
  // DIALOGS / FENÊTRES DE DIALOGUE
  // نوافذ الحوار
  // ════════════════════════════════════════════════════════════════

  /// Edit patient profile dialog
  /// Fenêtre de modification du profil de la patiente
  void _showEditPatientDialog(
    BuildContext context,
    AdminService service,
    String patientId,
    Map<String, dynamic> data,
  ) {
    final phoneCtrl =
        TextEditingController(text: data['phone'] as String? ?? '');
    final wilayaCtrl =
        TextEditingController(text: data['wilaya'] as String? ?? '');
    final addressCtrl =
        TextEditingController(text: data['address'] as String? ?? '');
    String status = data['status'] as String? ?? 'active';

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setS) => Dialog(
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
                  // Dialog title / Titre du dialogue
                  Text(
                    'Edit Patient Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone field / Champ téléphone
                  _buildTextField(
                    'Phone',
                    phoneCtrl,
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  // Wilaya field / Champ wilaya
                  _buildTextField(
                    'Wilaya',
                    wilayaCtrl,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),

                  // Address field / Champ adresse
                  _buildTextField(
                    'Address',
                    addressCtrl,
                    Icons.home_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),

                  // Status dropdown / Menu déroulant statut
                  Text(
                    'Status',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: status,
                    onChanged: (v) => setS(() => status = v!),
                    decoration: _dropDeco(),
                    items: [
                      _dropItem('active', 'Active'),
                      _dropItem('stable', 'Stable'),
                      _dropItem('critical', 'Critical'),
                      _dropItem('inactive', 'Inactive'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action buttons / Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dCtx),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await service.updatePatientProfile(
                              patientId: patientId,
                              phone: phoneCtrl.text.trim(),
                              wilaya: wilayaCtrl.text.trim(),
                              address: addressCtrl.text.trim(),
                            );

                            await service.updatePatient(
                              patientId,
                              {'status': status},
                            );

                            if (dCtx.mounted) Navigator.pop(dCtx);

                            if (context.mounted) {
                              _snack(
                                context,
                                'Updated successfully',
                                AdminColors.success,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.pink,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Save',
                            style: GoogleFonts.poppins(
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

  /// Assign doctor to patient dialog
  /// Fenêtre d'assignation d'un médecin à une patiente
  void _showAssignDoctorDialog(
    BuildContext context,
    AdminService service,
    String patientId,
    String patientName,
    String? currentDoctorId,
  ) {
    String? selectedDoctorId = currentDoctorId;
    String? selectedDoctorName;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setS) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title / Titre du dialogue
                Text(
                  'Assign a Doctor',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Patient: $patientName',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AdminColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Doctors list / Liste des médecins
                StreamBuilder<QuerySnapshot>(
                  stream: service.getDoctorsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AdminColors.primaryBlue,
                        ),
                      );
                    }

                    final doctors = snapshot.data?.docs ?? [];

                    if (doctors.isEmpty) {
                      return Center(
                        child: Text(
                          'No doctors available',
                          style: GoogleFonts.poppins(
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: doctors.length,
                        itemBuilder: (context, index) {
                          final doc = doctors[index];
                          final docData =
                              doc.data() as Map<String, dynamic>;
                          final doctorName =
                              '${docData['firstName'] ?? ''} '
                              '${docData['lastName'] ?? ''}';
                          final specialty =
                              docData['specialty'] as String? ?? '';

                          return RadioListTile<String>(
                            value: doc.id,
                            groupValue: selectedDoctorId,
                            activeColor: AdminColors.primaryBlue,
                            onChanged: (value) {
                              setS(() {
                                selectedDoctorId = value;
                                selectedDoctorName = doctorName;
                              });
                            },
                            title: Text(
                              doctorName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              specialty,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            secondary: CircleAvatar(
                              backgroundColor:
                                  AdminColors.primaryBlue.withAlpha(30),
                              backgroundImage:
                                  docData['profileImage'] != null
                                      ? NetworkImage(
                                          docData['profileImage'] as String)
                                      : null,
                              child: docData['profileImage'] == null
                                  ? Text(
                                      doctorName.isNotEmpty
                                          ? doctorName[0]
                                          : 'D',
                                      style: const TextStyle(
                                        color: AdminColors.primaryBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Action buttons / Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dCtx),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedDoctorId == null
                            ? null
                            : () async {
                                await service.assignDoctorToPatient(
                                  patientId: patientId,
                                  doctorId: selectedDoctorId!,
                                  doctorName: selectedDoctorName ?? '',
                                );

                                if (dCtx.mounted) Navigator.pop(dCtx);

                                if (context.mounted) {
                                  _snack(
                                    context,
                                    'Doctor assigned successfully',
                                    AdminColors.success,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Assign',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
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

  /// Add new baby dialog
  /// Fenêtre d'ajout d'un nouveau bébé
  void _showAddBabyDialog(
    BuildContext context,
    AdminService service,
    String motherId,
    String motherName,
  ) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String gender = 'male';
    DateTime birthDate = DateTime.now();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setS) => Dialog(
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
                  // Dialog title / Titre du dialogue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(dCtx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Text(
                        'Add a New Baby',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mother: $motherName',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // First name & Last name row
                  // Ligne prénom & nom
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'First Name',
                          firstNameCtrl,
                          Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Last Name',
                          lastNameCtrl,
                          Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Gender selection / Sélection du genre
                  Text(
                    'Gender',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'male',
                          groupValue: gender,
                          activeColor: AdminColors.primaryBlue,
                          onChanged: (v) => setS(() => gender = v!),
                          title: Text(
                            'Male',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'female',
                          groupValue: gender,
                          activeColor: AdminColors.pink,
                          onChanged: (v) => setS(() => gender = v!),
                          title: Text(
                            'Female',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Date of birth / Date de naissance
                  Container(
                    decoration: BoxDecoration(
                      color: AdminColors.pageBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.calendar_today,
                        color: AdminColors.primaryBlue,
                        size: 20,
                      ),
                      title: Text(
                        'Date of Birth',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dCtx,
                            initialDate: birthDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setS(() => birthDate = picked);
                          }
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.poppins(
                            color: AdminColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Weight & Height row / Ligne poids & taille
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Weight (kg)',
                          weightCtrl,
                          Icons.monitor_weight_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Height (cm)',
                          heightCtrl,
                          Icons.height_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Notes field / Champ notes
                  _buildTextField(
                    'Notes (optional)',
                    notesCtrl,
                    Icons.note_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Action buttons / Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(dCtx),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (firstNameCtrl.text.trim().isEmpty) {
                                    _snack(
                                      context,
                                      'Please enter the first name',
                                      AdminColors.danger,
                                    );
                                    return;
                                  }

                                  setS(() => isLoading = true);

                                  try {
                                    await service.addBaby(
                                      motherId: motherId,
                                      firstName:
                                          firstNameCtrl.text.trim(),
                                      lastName: lastNameCtrl.text.trim(),
                                      gender: gender,
                                      birthDate: birthDate,
                                      weight: double.tryParse(
                                          weightCtrl.text),
                                      height: double.tryParse(
                                          heightCtrl.text),
                                      notes: notesCtrl.text.isNotEmpty
                                          ? notesCtrl.text.trim()
                                          : null,
                                    );

                                    if (dCtx.mounted) {
                                      Navigator.pop(dCtx);
                                    }

                                    if (context.mounted) {
                                      _snack(
                                        context,
                                        'Baby added successfully',
                                        AdminColors.success,
                                      );
                                    }
                                  } catch (e) {
                                    setS(() => isLoading = false);
                                    if (context.mounted) {
                                      _snack(
                                        context,
                                        'Error: ${e.toString()}',
                                        AdminColors.danger,
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.pink,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
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
                                  'Add Baby',
                                  style: GoogleFonts.poppins(
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

  /// View babies list dialog
  /// Fenêtre d'affichage de la liste des bébés
  void _showBabiesDialog(
    BuildContext context,
    AdminService service,
    String motherId,
    String motherName,
  ) {
    showDialog(
      context: context,
      builder: (dCtx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title / Titre du dialogue
              Text(
                'Babies of: $motherName',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Babies list stream / Flux de la liste des bébés
              StreamBuilder<QuerySnapshot>(
                stream: service.getBabiesStream(motherId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AdminColors.primaryBlue,
                      ),
                    );
                  }

                  final babies = [...(snapshot.data?.docs ?? [])]
                    ..sort((a, b) {
                      final aTs =
                          (a.data() as Map<String, dynamic>)['birthDate'] as Timestamp?;
                      final bTs =
                          (b.data() as Map<String, dynamic>)['birthDate'] as Timestamp?;
                      final aMs = aTs?.millisecondsSinceEpoch ?? 0;
                      final bMs = bTs?.millisecondsSinceEpoch ?? 0;
                      return bMs.compareTo(aMs);
                    });

                  if (babies.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.child_care,
                              size: 52,
                              color: AdminColors.textLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No babies registered',
                              style: GoogleFonts.poppins(
                                color: AdminColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: babies.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: AdminColors.borderLight,
                      ),
                      itemBuilder: (context, index) {
                        final baby = babies[index];
                        final babyData =
                            baby.data() as Map<String, dynamic>;
                        final babyName =
                            '${babyData['firstName'] ?? ''} '
                            '${babyData['lastName'] ?? ''}';
                        final babyGender = babyData['gender'] == 'male'
                            ? 'Male'
                            : 'Female';

                        // Parse birth date / Analyser la date de naissance
                        final birthDateRaw = babyData['birthDate'];
                        String birthDateStr = '-';
                        if (birthDateRaw is Timestamp) {
                          final bd = birthDateRaw.toDate();
                          birthDateStr =
                              '${bd.day}/${bd.month}/${bd.year}';
                        }

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                babyData['gender'] == 'male'
                                    ? AdminColors.primaryBlue.withAlpha(50)
                                    : AdminColors.pink.withAlpha(50),
                            child: Icon(
                              babyData['gender'] == 'male'
                                  ? Icons.boy
                                  : Icons.girl,
                              color: babyData['gender'] == 'male'
                                  ? AdminColors.primaryBlue
                                  : AdminColors.pink,
                            ),
                          ),
                          title: Text(
                            babyName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '$babyGender  •  $birthDateStr',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AdminColors.danger,
                            ),
                            onPressed: () async {
                              // Confirm deletion dialog
                              // Dialogue de confirmation de suppression
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  title: Text(
                                    'Confirm Deletion',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  content: Text(
                                    'Do you want to delete $babyName?',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AdminColors.danger,
                                      ),
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && context.mounted) {
                                await service.deleteBaby(
                                  baby.id,
                                  motherId,
                                );
                                if (context.mounted) {
                                  _snack(
                                    context,
                                    'Deleted successfully',
                                    AdminColors.success,
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Close button / Bouton fermer
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dCtx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Close', style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HELPER WIDGETS / WIDGETS UTILITAIRES
  // عناصر مساعدة
  // ════════════════════════════════════════════════════════════════

  /// Custom text field builder
  /// Constructeur de champ de texte personnalisé
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 18,
              color: AdminColors.textLight,
            ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Dropdown decoration builder
  /// Constructeur de décoration pour menu déroulant
  InputDecoration _dropDeco() => InputDecoration(
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      );

  /// Dropdown item builder
  /// Constructeur d'élément de menu déroulant
  DropdownMenuItem<String> _dropItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Text(label, style: GoogleFonts.poppins(fontSize: 14)),
    );
  }

  /// Show snack bar notification
  /// Afficher une notification snack bar
  void _snack(BuildContext context, String msg, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

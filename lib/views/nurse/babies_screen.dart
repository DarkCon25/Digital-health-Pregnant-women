import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/nurse_colors.dart';
import '../../models/baby_model.dart';
import '../../services/nurse_service.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Babies Management Screen (Nurse)
// واجهة Baby Management / Gestion des nouveau-nes الجدد (الممرضة)
// ════════════════════════════════════════════════════════════════

class NurseBabiesScreen extends StatelessWidget {
  const NurseBabiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<NurseService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Baby button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Baby Management / Gestion des nouveau-nes',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NurseColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBabyDialog(context, service),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Baby / Ajouter un nouveau-ne'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NurseColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Babies list
          _buildBabiesList(service),
        ],
      ),
    );
  }

  /// Build babies list
  Widget _buildBabiesList(NurseService service) {
    return StreamBuilder<List<BabyModel>>(
      stream: service.watchBabies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: NurseColors.primary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error / Erreur: ${snapshot.error}',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          );
        }

        final babies = snapshot.data ?? [];

        if (babies.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.child_care,
                    size: 64,
                    color: NurseColors.textSecondary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No babies registered / Aucun nouveau-ne enregistre',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: NurseColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            // تم استبدال NurseColors.border بـ Colors.grey.shade300
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'All Babies / Tous les nouveau-nes (${babies.length})',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: NurseColors.textPrimary,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name / Nom')),
                    DataColumn(label: Text('Mother / Mere')),
                    DataColumn(label: Text('Gender / Sexe')),
                    DataColumn(label: Text('Birth Date / Date de naissance')),
                    DataColumn(label: Text('Weight (kg) / Poids (kg)')),
                    DataColumn(label: Text('Height (cm) / Taille (cm)')),
                    DataColumn(label: Text('Health Status / Etat de sante')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: babies.map((baby) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          baby.fullName,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        )),
                        DataCell(
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(baby.motherId)
                                .get(),
                            builder: (context, motherSnapshot) {
                              if (motherSnapshot.connectionState == ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              }
                              String motherName = 'Unknown / Inconnu';
                              if (motherSnapshot.hasData && motherSnapshot.data!.exists) {
                                final motherData = motherSnapshot.data!.data() as Map<String, dynamic>?;
                                if (motherData != null) {
                                  motherName = '${motherData['firstName'] ?? ''} ${motherData['lastName'] ?? ''}'.trim();
                                }
                              }
                              return Text(
                                motherName,
                                style: GoogleFonts.inter(fontSize: 13),
                              );
                            },
                          ),
                        ),
                        DataCell(Text(
                          baby.gender == 'male' ? 'Male / Garcon' : 'Female / Fille',
                          style: GoogleFonts.inter(fontSize: 13),
                        )),
                        DataCell(Text(
                          '${baby.birthDate.day}/${baby.birthDate.month}/${baby.birthDate.year}',
                          style: GoogleFonts.inter(fontSize: 13),
                        )),
                        DataCell(Text(
                          baby.weight?.toStringAsFixed(1) ?? 'N/A',
                          style: GoogleFonts.inter(fontSize: 13),
                        )),
                        DataCell(Text(
                          baby.height?.toStringAsFixed(1) ?? 'N/A',
                          style: GoogleFonts.inter(fontSize: 13),
                        )),
                        DataCell(_buildHealthStatusBadge(baby.healthStatus)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Edit / Modifier',
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _showEditBabyDialog(context, baby, service),
                              ),
                              IconButton(
                                tooltip: 'Delete / Supprimer',
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () => _showDeleteDialog(context, baby.id, service),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build health status badge
  Widget _buildHealthStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'healthy':
        color = const Color(0xFF4CAF50);
        label = 'Healthy / Sain';
        break;
      case 'needs_care':
        color = const Color(0xFFFF9800);
        label = 'Needs Care / Besoin de soins';
        break;
      case 'critical':
        color = const Color(0xFFF44336);
        label = 'Critical / Critique';
        break;
      default:
        color = const Color(0xFF9E9E9E);
        label = 'Unspecified / Non defini';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Show add baby dialog
  void _showAddBabyDialog(BuildContext context, NurseService service) {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String? selectedMotherId;
    String gender = 'male';
    DateTime birthDate = DateTime.now();
    String healthStatus = 'healthy';
    
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add New Baby / Ajouter un nouveau-ne',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('First Name / Prenom', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: firstNameCtrl,
                    enabled: !isSaving,
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Required / Requis' : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'First Name / Prenom',
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Last Name / Nom', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: lastNameCtrl,
                    enabled: !isSaving,
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Required / Requis' : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Last Name / Nom',
                    ),
                  ),
                  const SizedBox(height: 12),

Text('Mother / Mere', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                   const SizedBox(height: 6),
                   StreamBuilder<QuerySnapshot>(
                     stream: FirebaseFirestore.instance
                         .collection('users')
                         .where('role', isEqualTo: 'patient')
                         .snapshots(),
                     builder: (context, snap) {
                       final mothers = snap.data?.docs ?? [];

                       if (selectedMotherId != null && !mothers.any((m) => m.id == selectedMotherId)) {
                         selectedMotherId = null;
                       }

                       return DropdownButtonFormField<String>(
                         initialValue: selectedMotherId,
                         validator: (v) => v == null ? 'Please select a mother / Veuillez selectionner une mere' : null,
                         onChanged: isSaving ? null : (v) => setDialogState(() => selectedMotherId = v),
                         items: mothers.map((d) {
                           final data = d.data() as Map<String, dynamic>;
                           final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
                           return DropdownMenuItem(value: d.id, child: Text(name));
                         }).toList(),
                         decoration: InputDecoration(
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                           hintText: 'Select mother / Selectionner la mere',
                         ),
                       );
                     },
                   ),
                   const SizedBox(height: 12),

Text('Gender / Sexe', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                   const SizedBox(height: 6),
                   RadioGroup<String>(
                     groupValue: gender,
onChanged: (String? v) {
                        if (!isSaving && v != null) {
                          setDialogState(() => gender = v);
                        }
                      },
                      child: const Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              value: 'male',
                              title: Text('Male / Garcon'),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              value: 'female',
                              title: Text('Female / Fille'),
                            ),
                          ),
                        ],
                     ),
                   ),
                   const SizedBox(height: 12),

                   Text('Birth Date / Date de naissance', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: isSaving ? null : () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: birthDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (selected != null) {
                        setDialogState(() => birthDate = selected);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        // تم استبدال NurseColors.border بـ Colors.grey.shade300
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${birthDate.day}/${birthDate.month}/${birthDate.year}'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Weight (kg) / Poids (kg)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: weightCtrl,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Weight / Poids',
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Height (cm) / Taille (cm)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: heightCtrl,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Height / Taille',
                    ),
                  ),
                  const SizedBox(height: 12),

Text('Health Status / Etat de sante', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                   const SizedBox(height: 6),
                   DropdownButtonFormField<String>(
                     initialValue: healthStatus,
                    items: const [
                      DropdownMenuItem(value: 'healthy', child: Text('Healthy / Sain')),
                      DropdownMenuItem(value: 'needs_care', child: Text('Needs Care / Besoin de soins')),
                      DropdownMenuItem(value: 'critical', child: Text('Critical / Critique')),
                    ],
                    onChanged: isSaving ? null : (v) => setDialogState(() => healthStatus = v ?? 'healthy'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Notes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: notesCtrl,
                    enabled: !isSaving,
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Additional notes / Notes supplementaires',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dCtx),
              child: const Text('Cancel / Annuler'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (!formKey.currentState!.validate() || selectedMotherId == null) return;

                setDialogState(() => isSaving = true);

                try {
                  await service.addBaby(
                    motherId: selectedMotherId!,
                    firstName: firstNameCtrl.text.trim(),
                    lastName: lastNameCtrl.text.trim(),
                    gender: gender,
                    birthDate: birthDate,
                    weight: double.tryParse(weightCtrl.text),
                    height: double.tryParse(heightCtrl.text),
                    healthStatus: healthStatus,
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text,
                  );

                  if (dCtx.mounted) {
                    Navigator.pop(dCtx);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Baby added successfully / Nouveau-ne ajoute avec succes'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error / Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (dCtx.mounted) {
                    setDialogState(() => isSaving = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: NurseColors.primary),
              child: isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Add / Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show edit baby dialog
  void _showEditBabyDialog(BuildContext context, BabyModel baby, NurseService service) {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController(text: baby.firstName);
    final lastNameCtrl = TextEditingController(text: baby.lastName);
    final weightCtrl = TextEditingController(text: baby.weight?.toString() ?? '');
    final heightCtrl = TextEditingController(text: baby.height?.toString() ?? '');
    final notesCtrl = TextEditingController(text: baby.notes ?? '');
    String healthStatus = baby.healthStatus;

    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Baby Details / Modifier les informations du nouveau-ne'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameCtrl,
                    enabled: !isSaving,
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Required / Requis' : null,
                    decoration: const InputDecoration(labelText: 'First Name / Prenom', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameCtrl,
                    enabled: !isSaving,
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Required / Requis' : null,
                    decoration: const InputDecoration(labelText: 'Last Name / Nom', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: weightCtrl,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Weight (kg) / Poids (kg)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: heightCtrl,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Height (cm) / Taille (cm)', border: OutlineInputBorder()),
                  ),
const SizedBox(height: 12),
                   DropdownButtonFormField<String>(
                     initialValue: healthStatus,
                    items: const [
                      DropdownMenuItem(value: 'healthy', child: Text('Healthy / Sain')),
                      DropdownMenuItem(value: 'needs_care', child: Text('Needs Care / Besoin de soins')),
                      DropdownMenuItem(value: 'critical', child: Text('Critical / Critique')),
                    ],
                    onChanged: isSaving ? null : (v) => setDialogState(() => healthStatus = v ?? 'healthy'),
                    decoration: const InputDecoration(labelText: 'Health Status / Etat de sante', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesCtrl,
                    enabled: !isSaving,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dCtx),
              child: const Text('Cancel / Annuler'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (!formKey.currentState!.validate()) return;
                
                setDialogState(() => isSaving = true);

                try {
                  await service.updateBaby(baby.id, {
                    'firstName': firstNameCtrl.text.trim(),
                    'lastName': lastNameCtrl.text.trim(),
                    'weight': double.tryParse(weightCtrl.text),
                    'height': double.tryParse(heightCtrl.text),
                    'healthStatus': healthStatus,
                    'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  });

                  if (dCtx.mounted) Navigator.pop(dCtx);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updated successfully / Mise a jour reussie'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error / Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (dCtx.mounted) setDialogState(() => isSaving = false);
                }
              },
              child: isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save / Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show delete dialog
  void _showDeleteDialog(BuildContext context, String babyId, NurseService service) {
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setDialogState) => AlertDialog(
          title: const Text('Confirm Deletion / Confirmer la suppression'),
          content: const Text('Are you sure you want to delete this baby? / Etes-vous sur de vouloir supprimer ce nouveau-ne ?'),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(dCtx),
              child: const Text('Cancel / Annuler'),
            ),
            ElevatedButton(
              onPressed: isDeleting ? null : () async {
                setDialogState(() => isDeleting = true);
                try {
                  await service.deleteBaby(babyId);
                  
                  if (dCtx.mounted) Navigator.pop(dCtx);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deleted successfully / Supprime avec succes'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error / Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                  if (dCtx.mounted) setDialogState(() => isDeleting = false);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: isDeleting 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Delete / Supprimer'),
            ),
          ],
        ),
      ),
    );
  }
}

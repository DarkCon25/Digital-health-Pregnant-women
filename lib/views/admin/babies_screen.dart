import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../models/baby_model.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/chart_widget.dart';
import '../../widgets/admin/data_table_widget.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Babies Management Screen
// Écran de gestion des bébés
// ════════════════════════════════════════════════════════════════

class BabiesScreen extends StatelessWidget {
  const BabiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

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
                'Babies Management / Gestion des Bébés',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBabyDialog(context, service),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Baby / Ajouter Bébé'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryBlue,
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

          // Statistics row / Rangée de statistiques
          _buildStatsRow(service),

          const SizedBox(height: 24),

          // Charts row / Rangée de graphiques
          _buildChartsRow(service),

          const SizedBox(height: 24),

          // Babies list / Liste des bébés
          _buildBabiesList(service),
        ],
      ),
    );
  }

  /// Build statistics cards
  Widget _buildStatsRow(AdminService service) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('babies').snapshots(),
      builder: (context, snapshot) {
        int totalBabies = snapshot.data?.docs.length ?? 0;
        int males = 0, females = 0;
        int healthy = 0;

        for (var doc in snapshot.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['gender'] == 'male') males++;
          if (data['gender'] == 'female') females++;

          final status = data['healthStatus'] ?? 'healthy';
          if (status == 'healthy') healthy++;
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Babies / Total Bébés',
                value: totalBabies.toString(),
                icon: Icons.child_care,
                color: const Color(0xFFFF6B9D),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Boys / Garçons',
                value: males.toString(),
                icon: Icons.boy,
                color: const Color(0xFF4A9EFF),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Girls / Filles',
                value: females.toString(),
                icon: Icons.girl,
                color: const Color(0xFFFF6B9D),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Healthy / Sains',
                value: healthy.toString(),
                icon: Icons.favorite,
                color: AdminColors.greenCard,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build charts section
  Widget _buildChartsRow(AdminService service) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('babies').snapshots(),
      builder: (context, snapshot) {
        // Calculate gender distribution
        int males = 0, females = 0;
        for (var doc in snapshot.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['gender'] == 'male') males++;
          if (data['gender'] == 'female') females++;
        }

        // Calculate health status distribution
        int healthy = 0, needsCare = 0, critical = 0;
        for (var doc in snapshot.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['healthStatus'] ?? 'healthy';
          if (status == 'healthy') healthy++;
          if (status == 'needs_care') needsCare++;
          if (status == 'critical') critical++;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gender distribution pie chart
            Expanded(
              child: PieChartWidget(
                title: 'Gender Distribution / Distribution du sexe',
                data: [
                  if (males > 0)
                    PieChartData(
                      label: 'Boys / Garçons',
                      value: males.toDouble(),
                      color: const Color(0xFF4A9EFF),
                    ),
                  if (females > 0)
                    PieChartData(
                      label: 'Girls / Filles',
                      value: females.toDouble(),
                      color: const Color(0xFFFF6B9D),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Health status pie chart
            Expanded(
              child: PieChartWidget(
                title: 'Health Status / État de santé',
                data: [
                  if (healthy > 0)
                    PieChartData(
                      label: 'Healthy / Sains',
                      value: healthy.toDouble(),
                      color: AdminColors.greenCard,
                    ),
                  if (needsCare > 0)
                    PieChartData(
                      label: 'Needs Care / À surveiller',
                      value: needsCare.toDouble(),
                      color: AdminColors.orangeCard,
                    ),
                  if (critical > 0)
                    PieChartData(
                      label: 'Critical / Critique',
                      value: critical.toDouble(),
                      color: AdminColors.danger,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build babies list with all data
  Widget _buildBabiesList(AdminService service) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('babies')
          .orderBy('birthDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AdminColors.primaryBlue),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.inter(color: AdminColors.danger),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.child_care,
                    size: 64,
                    color: AdminColors.textSecondary.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Babies / Pas de bébés',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return AdminDataTable(
          title: 'All Babies / Tous les bébés',
          columns: const [
            'Name / Nom',
            'Mother / Mère',
            'Gender / Sexe',
            'Birth Date / Date de naissance',
            'Health Status / État de santé',
            'Weight / Poids',
            'Height / Taille',
            'Actions',
          ],
          rows: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final baby = BabyModel.fromMap(data, doc.id);

            return [
              Text(
                baby.fullName,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(baby.motherId)
                    .snapshots(),
                builder: (context, motherSnapshot) {
                  String motherName = 'Unknown / Inconnu';
                  if (motherSnapshot.hasData && motherSnapshot.data != null) {
                    final motherData =
                        motherSnapshot.data!.data() as Map<String, dynamic>?;
                    if (motherData != null) {
                      motherName =
                          '${motherData['firstName'] ?? ''} ${motherData['lastName'] ?? ''}'
                              .trim();
                    }
                  }

                  return Text(
                    motherName,
                    style: GoogleFonts.inter(fontSize: 13),
                  );
                },
              ),
              _buildGenderBadge(baby.gender),
              Text(
                '${baby.birthDate.day}/${baby.birthDate.month}/${baby.birthDate.year}',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              _buildHealthStatusBadge(baby.healthStatus),
              Text(
                '${baby.weight?.toStringAsFixed(1) ?? 'N/A'} kg',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              Text(
                '${baby.height?.toStringAsFixed(1) ?? 'N/A'} cm',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              TableActions(
                onEdit: () => _showEditBabyDialog(context, baby),
                onDelete: () => _showDeleteDialog(context, doc.id, service),
              ),
            ];
          }).toList(),
        );
      },
    );
  }

  /// Build gender badge
  Widget _buildGenderBadge(String gender) {
    final isMale = gender == 'male';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMale
            ? const Color(0xFF4A9EFF).withAlpha(25)
            : const Color(0xFFFF6B9D).withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isMale ? '♂ Boy / Garçon' : '♀ Girl / Fille',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isMale ? const Color(0xFF4A9EFF) : const Color(0xFFFF6B9D),
        ),
      ),
    );
  }

  /// Build health status badge
  Widget _buildHealthStatusBadge(String status) {
    // Map health status to badge status
    String badgeStatus;
    switch (status) {
      case 'healthy':
        badgeStatus = 'active';
        break;
      case 'needs_care':
        badgeStatus = 'maintenance';
        break;
      case 'critical':
        badgeStatus = 'critical';
        break;
      default:
        badgeStatus = 'inactive';
    }

    return StatusBadge(status: badgeStatus);
  }

  /// Show add baby dialog with mother selection
  void _showAddBabyDialog(BuildContext context, AdminService service) {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String? selectedMotherId;
    String gender = 'male';
    DateTime birthDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add New Baby / Ajouter un Bébé',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mother selection dropdown
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'patient')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final mothers = snapshot.data!.docs;
                    if (mothers.isEmpty) {
                      return Center(
                        child: Text(
                          'No mothers found / Aucune mère trouvée',
                          style: GoogleFonts.inter(),
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: selectedMotherId,
                      decoration: InputDecoration(
                        labelText: 'Select Mother / Sélectionner la mère',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: mothers.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final fullName =
                            '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                                .trim();
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedMotherId = value;
                      },
                      validator: (v) => v == null
                          ? 'Please select a mother / Sélectionner une mère'
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // First name
                TextFormField(
                  controller: firstNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'First Name / Prénom',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Required / Requis' : null,
                ),
                const SizedBox(height: 12),

                // Last name
                TextFormField(
                  controller: lastNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Last Name / Nom',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Required / Requis' : null,
                ),
                const SizedBox(height: 12),

                // Gender selection
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: InputDecoration(
                    labelText: 'Gender / Sexe',
                    prefixIcon: const Icon(Icons.wc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text('Boy / Garçon'),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text('Girl / Fille'),
                    ),
                  ],
                  onChanged: (v) => gender = v ?? gender,
                ),
                const SizedBox(height: 12),

                // Birth date
                StatefulBuilder(
                  builder: (context, setState) => ListTile(
                    title: Text(
                      'Birth Date / Date de naissance',
                      style: GoogleFonts.inter(),
                    ),
                    subtitle: Text(
                      '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                      style: GoogleFonts.inter(),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: birthDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => birthDate = picked);
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Weight
                TextFormField(
                  controller: weightCtrl,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg) / Poids',
                    prefixIcon: const Icon(Icons.monitor_weight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Height
                TextFormField(
                  controller: heightCtrl,
                  decoration: InputDecoration(
                    labelText: 'Height (cm) / Taille',
                    prefixIcon: const Icon(Icons.height),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Notes
                TextFormField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  selectedMotherId != null) {
                try {
                  await service.addBaby(
                    motherId: selectedMotherId!,
                    firstName: firstNameCtrl.text,
                    lastName: lastNameCtrl.text,
                    gender: gender,
                    birthDate: birthDate,
                    weight: double.tryParse(weightCtrl.text),
                    height: double.tryParse(heightCtrl.text),
                    notes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Baby added successfully / Bébé ajouté'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primaryBlue,
            ),
            child: const Text('Save / Enregistrer'),
          ),
        ],
      ),
    );
  }

  /// Show edit baby dialog
  void _showEditBabyDialog(BuildContext context, BabyModel baby) {
    final formKey = GlobalKey<FormState>();
    final firstNameCtrl = TextEditingController(text: baby.firstName);
    final lastNameCtrl = TextEditingController(text: baby.lastName);
    final weightCtrl =
        TextEditingController(text: baby.weight?.toString() ?? '');
    final heightCtrl =
        TextEditingController(text: baby.height?.toString() ?? '');
    final notesCtrl = TextEditingController(text: baby.notes ?? '');
    String gender = baby.gender;
    String healthStatus = baby.healthStatus;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Baby / Modifier Bébé',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'First Name / Prénom'),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Required / Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastNameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Last Name / Nom'),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Required / Requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: const InputDecoration(labelText: 'Gender / Sexe'),
                  items: const [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text('Boy / Garçon'),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text('Girl / Fille'),
                    ),
                  ],
                  onChanged: (v) => gender = v ?? gender,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: weightCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Weight (kg) / Poids'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: heightCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Height (cm) / Taille'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: healthStatus,
                  decoration: const InputDecoration(
                      labelText: 'Health Status / État de santé'),
                  items: const [
                    DropdownMenuItem(
                        value: 'healthy', child: Text('Healthy / Sain')),
                    DropdownMenuItem(
                        value: 'needs_care',
                        child: Text('Needs Care / À surveiller')),
                    DropdownMenuItem(
                        value: 'critical', child: Text('Critical / Critique')),
                  ],
                  onChanged: (v) => healthStatus = v ?? healthStatus,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final service = context.read<AdminDashboardViewModel>().service;
                await service.updateBaby(baby.id, {
                  'firstName': firstNameCtrl.text,
                  'lastName': lastNameCtrl.text,
                  'gender': gender,
                  'weight': double.tryParse(weightCtrl.text),
                  'height': double.tryParse(heightCtrl.text),
                  'healthStatus': healthStatus,
                  'notes': notesCtrl.text,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save / Enregistrer'),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteDialog(
    BuildContext context,
    String babyId,
    AdminService service,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Baby / Supprimer Bébé'),
        content: const Text('Are you sure / Êtes-vous sûr?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel / Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get mother ID first
              final babyDoc = await FirebaseFirestore.instance
                  .collection('babies')
                  .doc(babyId)
                  .get();
              final motherId = (babyDoc.data() as Map?)?['motherId'];

              if (motherId != null) {
                await service.deleteBaby(babyId, motherId);
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
            ),
            child: const Text('Delete / Supprimer'),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AdminColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AdminColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

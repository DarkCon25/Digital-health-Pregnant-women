import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../widgets/admin/data_table_widget.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Rooms Screen
// Écran des chambres / salles
// ════════════════════════════════════════════════════════════════

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<AdminDashboardViewModel>().service;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Page title
              Text(
                'Rooms List / Liste des Chambres',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textPrimary,
                ),
              ),

              // Add room button
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, service),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add Room',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.orangeCard,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
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

          // Rooms table
          StreamBuilder<QuerySnapshot>(
            stream: service.getRoomsStream(),
            builder: (context, snapshot) {
              final loading =
                  snapshot.connectionState == ConnectionState.waiting;
              final docs = snapshot.data?.docs ?? [];

              return AdminDataTable(
                title: 'Rooms / Chambres (${docs.length})',
                isLoading: loading,
                columns: const [
                  'Number',
                  'Floor',
                  'Type',
                  'Capacity',
                  'Status',
                  'Actions',
                ],
                rows: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;

                  return [
                    // Column 1 - Room number
                    Text(
                      'Room ${d['number'] ?? '-'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.textPrimary,
                      ),
                    ),

                    // Column 2 - Floor
                    Text(
                      'Floor ${d['floor'] ?? 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                    ),

                    // Column 3 - Type
                    _buildTypeChip(d['type'] as String? ?? 'private'),

                    // Column 4 - Capacity
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bed_outlined,
                          size: 14,
                          color: AdminColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${d['capacity'] ?? 1} bed(s)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Column 5 - Status badge
                    _StatusBadge(
                      status: d['status'] as String? ?? 'available',
                    ),

                    // Column 6 - Actions
                    _TableActions(
                      onEdit: () => _showEditDialog(
                        context,
                        service,
                        doc.id,
                        d,
                      ),
                      onDelete: () => service.deleteRoom(doc.id),
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
  // DIALOGS
  // ════════════════════════════════════════════════════════════════

  void _showAddDialog(BuildContext context, AdminService service) {
    final numberCtrl = TextEditingController();
    String type = 'private';
    int floor = 1;
    int capacity = 1;
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
            width: 460,
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
                      Text(
                        'Add New Room',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dCtx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Room number
                  _buildField(
                    label: 'Room Number',
                    controller: numberCtrl,
                    icon: Icons.bed_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  // Type
                  _buildDropdownLabel('Room Type'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    onChanged: (v) => setS(() => type = v!),
                    decoration: _dropDeco(),
                    items: _roomTypeItems(),
                  ),
                  const SizedBox(height: 14),

                  // Floor & Capacity
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownLabel('Floor'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              initialValue: floor,
                              onChanged: (v) => setS(() => floor = v!),
                              decoration: _dropDeco(),
                              items: List.generate(
                                5,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                    'Floor ${i + 1}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownLabel('Capacity'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              initialValue: capacity,
                              onChanged: (v) => setS(() => capacity = v!),
                              decoration: _dropDeco(),
                              items: List.generate(
                                4,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                    '${i + 1} bed(s)',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              isLoading ? null : () => Navigator.pop(dCtx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                  if (numberCtrl.text.trim().isEmpty) {
                                    _snack(
                                      context,
                                      'Please enter a room number',
                                      AdminColors.danger,
                                    );
                                    return;
                                  }

                                  setS(() => isLoading = true);

                                  try {
                                    await service.addRoom(
                                      number: numberCtrl.text.trim(),
                                      type: type,
                                      floor: floor,
                                      capacity: capacity,
                                    );

                                    if (dCtx.mounted) {
                                      Navigator.pop(dCtx);
                                    }

                                    if (context.mounted) {
                                      _snack(
                                        context,
                                        'Room added successfully',
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
                            backgroundColor: AdminColors.orangeCard,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                  'Add',
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

  void _showEditDialog(
    BuildContext context,
    AdminService service,
    String docId,
    Map<String, dynamic> data,
  ) {
    final numberCtrl = TextEditingController(
      text: data['number'] as String? ?? '',
    );
    String selectedType = data['type'] as String? ?? 'private';
    int selectedFloor = data['floor'] as int? ?? 1;
    int selectedCapacity = data['capacity'] as int? ?? 1;
    String selectedStatus = data['status'] as String? ?? 'available';
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
            width: 460,
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
                      Text(
                        'Edit Room',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dCtx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    label: 'Room Number',
                    controller: numberCtrl,
                    icon: Icons.bed_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),

                  _buildDropdownLabel('Room Type'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    onChanged: (v) => setS(() => selectedType = v!),
                    decoration: _dropDeco(),
                    items: _roomTypeItems(),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownLabel('Floor'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              initialValue: selectedFloor,
                              onChanged: (v) => setS(() => selectedFloor = v!),
                              decoration: _dropDeco(),
                              items: List.generate(
                                5,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                    'Floor ${i + 1}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownLabel('Capacity'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              initialValue: selectedCapacity,
                              onChanged: (v) =>
                                  setS(() => selectedCapacity = v!),
                              decoration: _dropDeco(),
                              items: List.generate(
                                4,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                    '${i + 1} bed(s)',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildDropdownLabel('Status'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    onChanged: (v) => setS(() => selectedStatus = v!),
                    decoration: _dropDeco(),
                    items: _statusItems(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              isLoading ? null : () => Navigator.pop(dCtx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                                  if (numberCtrl.text.trim().isEmpty) {
                                    _snack(
                                      context,
                                      'Please enter a room number',
                                      AdminColors.danger,
                                    );
                                    return;
                                  }

                                  setS(() => isLoading = true);

                                  try {
                                    await service.updateRoom(docId, {
                                      'number': numberCtrl.text.trim(),
                                      'type': selectedType,
                                      'floor': selectedFloor,
                                      'capacity': selectedCapacity,
                                      'status': selectedStatus,
                                    });

                                    if (dCtx.mounted) {
                                      Navigator.pop(dCtx);
                                    }

                                    if (context.mounted) {
                                      _snack(
                                        context,
                                        'Room updated successfully',
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
                            backgroundColor: AdminColors.orangeCard,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

  // ════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ════════════════════════════════════════════════════════════════

  Widget _buildTypeChip(String type) {
    Color color;
    String label;
    IconData icon;

    switch (type) {
      case 'icu':
        color = AdminColors.danger;
        label = 'ICU';
        icon = Icons.monitor_heart_outlined;
        break;
      case 'shared':
        color = AdminColors.primaryBlue;
        label = 'Shared';
        icon = Icons.people_outline;
        break;
      case 'maternity':
        color = Colors.pink;
        label = 'Maternity';
        icon = Icons.pregnant_woman_outlined;
        break;
      default:
        color = AdminColors.greenCard;
        label = 'Private';
        icon = Icons.person_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AdminColors.textPrimary,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
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

  List<DropdownMenuItem<String>> _roomTypeItems() => [
        DropdownMenuItem(
          value: 'private',
          child: Text(
            'Private',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DropdownMenuItem(
          value: 'shared',
          child: Text(
            'Shared',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DropdownMenuItem(
          value: 'icu',
          child: Text(
            'ICU',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DropdownMenuItem(
          value: 'maternity',
          child: Text(
            'Maternity',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ];

  List<DropdownMenuItem<String>> _statusItems() => [
        DropdownMenuItem(
          value: 'available',
          child: Text(
            'Available',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DropdownMenuItem(
          value: 'occupied',
          child: Text(
            'Occupied',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
        DropdownMenuItem(
          value: 'maintenance',
          child: Text(
            'Maintenance',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ];

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

// ════════════════════════════════════════════════════════════════
// MISSING WIDGETS - إضافة الـ widgets الناقصة
// ════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'available':
        color = AdminColors.success;
        label = 'Available';
        break;
      case 'occupied':
        color = AdminColors.info;
        label = 'Occupied';
        break;
      case 'maintenance':
        color = AdminColors.warning;
        label = 'Maintenance';
        break;
      default:
        color = AdminColors.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _TableActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TableActions({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDelete != null)
          _ActionButton(
            icon: Icons.delete_outline_rounded,
            color: AdminColors.danger,
            onTap: () => _confirmDelete(context),
          ),
        const SizedBox(width: 6),
        if (onEdit != null)
          _ActionButton(
            icon: Icons.edit_outlined,
            color: AdminColors.primaryBlue,
            onTap: onEdit!,
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Delete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete this room?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                _hovered ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? widget.color : AdminColors.border,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}


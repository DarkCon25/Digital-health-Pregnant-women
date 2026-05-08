import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/admin_colors.dart';

// ============================================
// HerCare - Data Table Widget
// Widget Tableau de données
// ============================================

class AdminDataTable extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<List<Widget>> rows;
  final VoidCallback? onViewAll;
  final bool isLoading;

  const AdminDataTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.onViewAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Table Header / En-tête du tableau
          _buildTableHeader(),

          // ── Column Headers / En-têtes des colonnes
          _buildColumnHeaders(),

          // ── Table Content / Contenu du tableau
          _buildTableContent(),
        ],
      ),
    );
  }

  // ── Table Header (title + view all button)
  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // View all button / Bouton voir tout
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All / Voir tout',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AdminColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          // Table title / Titre du tableau
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AdminColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Column Headers Row
  Widget _buildColumnHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AdminColors.pageBg,
        border: Border(
          top: BorderSide(color: AdminColors.border),
          bottom: BorderSide(color: AdminColors.border),
        ),
      ),
      child: Row(
        children: columns.map((col) {
          return Expanded(
            child: Text(
              col,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AdminColors.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Table Content
  Widget _buildTableContent() {
    // Loading state / État de chargement
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AdminColors.primaryBlue,
          ),
        ),
      );
    }

    // Empty state / État vide
    if (rows.isEmpty) {
      return _buildEmptyState();
    }

    // Data rows / Lignes de données
    return Column(
      children: rows.asMap().entries.map((entry) {
        return _TableRow(
          cells: entry.value,
          isLast: entry.key == rows.length - 1,
        );
      }).toList(),
    );
  }

  // ── Empty State Widget
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 52,
            color: AdminColors.textLight,
          ),
          const SizedBox(height: 12),
          Text(
            'No data found / Aucune donnée trouvée',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AdminColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Single Table Row / Ligne de tableau unique
// ============================================
class _TableRow extends StatefulWidget {
  final List<Widget> cells;
  final bool isLast;

  const _TableRow({
    required this.cells,
    required this.isLast,
  });

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          // Highlight on hover / Surligner au survol
          color: _isHovered ? AdminColors.primaryBluePale : AdminColors.cardBg,
          border: widget.isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: AdminColors.borderLight),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          child: Row(
            children: widget.cells.map((cell) {
              return Expanded(child: cell);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================
// Status Badge / Badge de statut
// ============================================
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config['color'] as Color,
        ),
      ),
    );
  }

  // Get config based on status / Obtenir la config selon le statut
  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return {
          'label': 'Active',
          'color': AdminColors.success,
          'bg': AdminColors.successBg,
        };
      case 'inactive':
        return {
          'label': 'Inactive',
          'color': AdminColors.textSecondary,
          'bg': AdminColors.borderLight,
        };
      case 'critical':
        return {
          'label': 'Critical / Critique',
          'color': AdminColors.danger,
          'bg': AdminColors.dangerBg,
        };
      case 'stable':
        return {
          'label': 'Stable',
          'color': AdminColors.success,
          'bg': AdminColors.successBg,
        };
      case 'occupied':
        return {
          'label': 'Occupied / Occupée',
          'color': AdminColors.info,
          'bg': AdminColors.infoBg,
        };
      case 'available':
        return {
          'label': 'Available / Disponible',
          'color': AdminColors.success,
          'bg': AdminColors.successBg,
        };
      case 'maintenance':
        return {
          'label': 'Maintenance',
          'color': AdminColors.warning,
          'bg': AdminColors.warningBg,
        };
      case 'leave':
        return {
          'label': 'On Leave / En congé',
          'color': AdminColors.warning,
          'bg': AdminColors.warningBg,
        };
      default:
        return {
          'label': status,
          'color': AdminColors.textSecondary,
          'bg': AdminColors.borderLight,
        };
    }
  }
}

// ============================================
// Table Action Buttons (Edit + Delete)
// Boutons d'action du tableau
// ============================================
class TableActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TableActions({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button / Bouton modifier
        if (onEdit != null)
          _ActionButton(
            icon: Icons.edit_outlined,
            color: AdminColors.primaryBlue,
            onTap: onEdit!,
          ),

        const SizedBox(width: 6),

        // Delete button / Bouton supprimer
        if (onDelete != null)
          _ActionButton(
            icon: Icons.delete_outline_rounded,
            color: AdminColors.danger,
            onTap: () => _showDeleteConfirm(context),
          ),
      ],
    );
  }

  // Show delete confirmation dialog
  // Afficher la boîte de confirmation de suppression
  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Delete / Confirmer la suppression',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure? This action cannot be undone.\n'
          'Êtes-vous sûr ? Cette action est irréversible.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          // Cancel / Annuler
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel / Annuler',
              style: GoogleFonts.inter(
                color: AdminColors.textSecondary,
              ),
            ),
          ),

          // Delete / Supprimer
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
            ),
            child: Text(
              'Delete / Supprimer',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single Action Button
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                _isHovered ? widget.color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? widget.color : AdminColors.border,
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

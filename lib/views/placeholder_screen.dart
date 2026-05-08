import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/admin_colors.dart';
import '../core/routes.dart';
import '../viewmodels/auth_viewmodel.dart';

// ============================================
// HerCare - Placeholder Screen
// Écran de chargement / redirection
// This screen checks the user role and redirects
// Cet écran vérifie le rôle et redirige
// ============================================

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({super.key});

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    // Check role after first frame
    // Vérifier le rôle après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRoleAndNavigate();
    });
  }

  // Check user role and navigate
  // Vérifier le rôle et naviguer
  Future<void> _checkRoleAndNavigate() async {
    final authVm = context.read<AuthViewModel>();

    // Load current user from Firestore
    // Charger l'utilisateur depuis Firestore
    await authVm.loadCurrentUser();

    if (!mounted) return;

    final role = authVm.currentUser?.role ?? 'patient';

    // Navigate based on role / Naviguer selon le rôle
    switch (role) {
      case 'admin':
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.adminDashboard,
        );
        break;

      case 'doctor':
        // Phase 3 - Coming soon
        // Phase 3 - Bientôt disponible
        _showComingSoon('Doctor Dashboard / Médecin');
        break;

      case 'nurse':
        // Phase 3 - Coming soon
        _showComingSoon('Nurse Dashboard / Infirmière');
        break;

      case 'patient':
        // Phase 3 - Coming soon
        _showComingSoon('Patient Dashboard / Patiente');
        break;

      default:
        // Go back to login / Retourner au login
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.login,
        );
    }
  }

  // Show coming soon message
  // Afficher le message bientôt disponible
  void _showComingSoon(String dashboard) {
    setState(() {});
    // Keep on this screen and show message
    // Rester sur cet écran et afficher le message
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final role = authVm.currentUser?.role;

    // If role is not admin, show coming soon
    // Si le rôle n'est pas admin, afficher bientôt disponible
    if (role != null && role != 'admin') {
      return _buildComingSoonScreen(role);
    }

    // Loading screen / Écran de chargement
    return Scaffold(
      backgroundColor: AdminColors.pageBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with gradient
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AdminColors.primaryBlue,
                    AdminColors.pink,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 24),

            // Loading indicator
            const CircularProgressIndicator(
              color: AdminColors.primaryBlue,
              strokeWidth: 3,
            ),

            const SizedBox(height: 16),

            // Loading text
            Text(
              'Loading... / Chargement...',
              style: TextStyle(
                fontSize: 16,
                color: AdminColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Coming Soon Screen for Doctor/Nurse/Patient
  Widget _buildComingSoonScreen(String role) {
    return Scaffold(
      backgroundColor: AdminColors.pageBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AdminColors.primaryBluePale,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                size: 50,
                color: AdminColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AdminColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              '${_getRoleTitle(role)} dashboard'
              ' is under development',
              style: TextStyle(
                fontSize: 16,
                color: AdminColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Le tableau de bord est en développement',
              style: TextStyle(
                fontSize: 14,
                color: AdminColors.textLight,
                fontFamily: 'Inter',
              ),
            ),

            const SizedBox(height: 32),

            // Back to Login Button
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthViewModel>().signOut();
                Navigator.of(context).pushReplacementNamed(AppRoutes.login);
              },
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
              ),
              label: const Text(
                'Back to Login / Retour',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get role title / Obtenir le titre du rôle
  String _getRoleTitle(String role) {
    switch (role) {
      case 'doctor':
        return 'Doctor / Médecin';
      case 'nurse':
        return 'Nurse / Infirmière';
      case 'patient':
        return 'Patient';
      default:
        return role;
    }
  }
}

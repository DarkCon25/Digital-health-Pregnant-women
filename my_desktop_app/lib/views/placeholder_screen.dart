import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../core/routes.dart';
import '../widgets/app_logo.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'doctor':
        return 'Médecin';
      case 'nurse':
        return 'Infirmière';
      case 'patient':
      default:
        return 'Patiente';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFF7C3AED);
      case 'doctor':
        return AppColors.primaryBlue;
      case 'nurse':
        return AppColors.success;
      case 'patient':
      default:
        return AppColors.accentPink;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'doctor':
        return Icons.medical_services_outlined;
      case 'nurse':
        return Icons.local_hospital_outlined;
      case 'patient':
      default:
        return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final user = vm.currentUser;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBluePale,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const AppLogo(
                      size: 90,
                      isCircle: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'HerCare',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (user != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getRoleIcon(user.role),
                            size: 42,
                            color: _getRoleColor(user.role),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Bienvenue, ${user.fullName}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rôle: ${_getRoleLabel(user.role)}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getRoleColor(user.role),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Text(
                      'Utilisateur introuvable',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              await vm.signOut();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.login);
                              }
                            },
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        'Se déconnecter',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

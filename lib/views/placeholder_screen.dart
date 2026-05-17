import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/admin_colors.dart';
import '../core/constants.dart';
import '../core/routes.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/app_logo.dart';

// HerCare loading/redirect screen.
// Checks the authenticated user role then routes to the proper dashboard.
class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({super.key});

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRoleAndNavigate();
    });
  }

  Future<void> _checkRoleAndNavigate() async {
    final authVm = context.read<AuthViewModel>();
    await authVm.loadCurrentUser();
    if (!mounted) return;

    final role = authVm.currentUser?.role ?? AppConstants.rolePatient;
    if (role == AppConstants.roleAdmin ||
        role == AppConstants.roleDoctor ||
        role == AppConstants.roleNurse ||
        role == AppConstants.rolePatient) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.getHomePageRoute(role),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AdminColors.pageBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LogoBlock(),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: AdminColors.primaryBlue,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Redirecting to your dashboard... / Redirection vers votre tableau de bord...',
              textAlign: TextAlign.center,
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
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return const AppLogo(
      size: 84,
      isCircle: false,
      backgroundColor: Colors.white,
    );
  }
}

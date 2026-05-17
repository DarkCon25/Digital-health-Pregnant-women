import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/colors.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'services/doctor_service.dart';
import 'services/nurse_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'views/doctor/doctor_dashboard_screen.dart';
import 'views/doctor/medical_file_screen.dart';
import 'views/login_screen.dart';
import 'views/nurse/nurse_dashboard_screen.dart';
import 'views/patient/patient_dashboard_screen.dart';
import 'views/placeholder_screen.dart';
import 'widgets/app_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => DoctorService()),
        Provider(create: (_) => NurseService()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const HerCareApp(),
    ),
  );
}

class HerCareApp extends StatelessWidget {
  const HerCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerCare - Digital Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AuthWrapper(),
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.placeholder: (_) => const PlaceholderScreen(),
        AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(),
        AppRoutes.doctorDashboard: (_) => const DoctorDashboardScreen(),
        AppRoutes.nurseDashboard: (_) => const NurseDashboardScreen(),
        AppRoutes.patientDashboard: (_) => const PatientDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.doctorMedicalFile) {
          final patientId = settings.arguments;
          if (patientId is String && patientId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => MedicalFileScreen(patientId: patientId),
              settings: settings,
            );
          }

          return MaterialPageRoute(
            builder: (_) => const PlaceholderScreen(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AuthViewModel>().loadCurrentUser();
          });
          return const PlaceholderScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradientStart,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(
              size: 100,
              isCircle: true,
              borderColor: Colors.white.withValues(alpha: 0.4),
              borderWidth: 2.5,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 20),
            Text(
              'HerCare',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'DIGITAL HEALTH',
              style: GoogleFonts.inter(
                fontSize: 11,
                letterSpacing: 3,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes.dart';
import 'firebase_options.dart';
import 'services/doctor_service.dart';
import 'services/nurse_service.dart';
import 'services/patient_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/placeholder_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';
import 'views/doctor/doctor_dashboard_screen.dart';
import 'views/doctor/medical_file_screen.dart';
import 'views/nurse/nurse_dashboard_screen.dart';
import 'views/patient/patient_dashboard_screen.dart';

// ============================================
// HerCare - Main Entry Point
// Point d'entrée principal - HerCare
// ============================================

void main() async {
  // Ensure Flutter is initialized
  // S'assurer que Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HerCareApp());
}

class HerCareApp extends StatelessWidget {
  const HerCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DoctorService()),
        Provider(create: (_) => NurseService()),
        Provider(create: (_) => PatientService()),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
      ],
      child: MaterialApp(
        // App name / Nom de l'application
        title: 'HerCare',

        // Hide debug banner
        debugShowCheckedModeBanner: false,

        // Clamp text scaling (browser zoom / accessibility) to reduce overflow.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          final clamped = mq.textScaler.clamp(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.25,
          );
          return MediaQuery(
            data: mq.copyWith(textScaler: clamped),
            child: child ?? const SizedBox.shrink(),
          );
        },

        // App theme / Thème de l'application
        theme: _buildAppTheme(),

        // Initial route / Route initiale
        // initialRoute: AppRoutes.adminDashboard,
        // initialRoute: AppRoutes.doctorDashboard,
        // initialRoute: AppRoutes.nurseDashboard,
        // initialRoute: AppRoutes.patientDashboard,
        initialRoute: AppRoutes.login,

        // Route definitions / Définitions des routes
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
            final id = settings.arguments as String?;
            if (id == null || id.isEmpty) return null;
            return MaterialPageRoute<void>(
              builder: (_) => MedicalFileScreen(patientId: id),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }

  // Build App Theme / Construire le thème
  ThemeData _buildAppTheme() {
    return ThemeData(
      // Use Material 3
      useMaterial3: true,

      // Primary color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),

      // Default font / Police par défaut
      fontFamily: 'Inter',

      // Scaffold background
      scaffoldBackgroundColor: const Color(0xFFF8FAFF),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF0F172A),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/colors.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/login_screen.dart';
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
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const HerCareApp(),
    ),
  );
}

// ════════════════════════════════════════════════
// APP
// ════════════════════════════════════════════════

class HerCareApp extends StatelessWidget {
  const HerCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerCare - Digital Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ── Auth State Wrapper ──
      home: const _AuthWrapper(),

      // ── Routes ──
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.placeholder: (_) => const PlaceholderScreen(),
      },
    );
  }
}

// ════════════════════════════════════════════════
// AUTH WRAPPER — Session Handling
// ════════════════════════════════════════════════

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        // ── Logged In → Go to Placeholder
        if (snapshot.hasData && snapshot.data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AuthViewModel>().loadCurrentUser();
          });
          return const PlaceholderScreen();
        }

        // ── Not Logged In → Show Login
        return const LoginScreen();
      },
    );
  }
}

// ════════════════════════════════════════════════
// SPLASH SCREEN
// ════════════════════════════════════════════════

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
            // ✅ اللوجو الحقيقي
            AppLogo(
              size: 100,
              isCircle: true,
              borderColor: Colors.white.withOpacity(0.4),
              borderWidth: 2.5,
              backgroundColor: Colors.white.withOpacity(0.1),
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

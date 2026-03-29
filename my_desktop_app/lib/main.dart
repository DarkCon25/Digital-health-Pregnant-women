import 'package:flutter/material.dart';

import 'views/login_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pregnancy Health Desktop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      initialRoute: '/login',
      onGenerateRoute: _generateRoute,
    );
  }

  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );

      case '/patients':
        return MaterialPageRoute(
          builder: (_) => const PatientListPage(),
          settings: settings,
        );

      case '/patient_details':
        final patientId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PatientDetailsPage(patientId: patientId ?? ''),
          settings: settings,
        );

      case '/add_edit_patient':
        final arguments = settings.arguments as Map<String, dynamic>?;
        final patientId = arguments?['patientId'] as String?;
        return MaterialPageRoute(
          builder: (_) => AddEditPatientPage(patientId: patientId),
          settings: settings,
        );

      case '/medications':
        final patientId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => MedicationTrackingPage(patientId: patientId ?? ''),
          settings: settings,
        );

      case '/risk_prediction':
        final patientId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => RiskPredictionPage(patientId: patientId ?? ''),
          settings: settings,
        );

      case '/ai_assistant':
        final patientId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AIAssistantPage(patientId: patientId ?? ''),
          settings: settings,
        );

      case '/childbirth_stats':
        return MaterialPageRoute(
          builder: (_) => const ChildbirthStatsPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}

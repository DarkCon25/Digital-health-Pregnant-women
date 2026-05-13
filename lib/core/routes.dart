import 'constants.dart';

class AppRoutes {
  static const String login = '/login';
  static const String placeholder = '/placeholder';

  // ── Role-Based Routes ──
  static const String adminDashboard = '/admin/dashboard';
  static const String doctorDashboard = '/doctor/dashboard';
  static const String doctorMedicalFile = '/doctor/medical-file';
  static const String nurseDashboard = '/nurse/dashboard';
  static const String patientDashboard = '/patient/dashboard';

  /// Get the destination route for a user role.
  static String getHomePageRoute(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return adminDashboard;
      case AppConstants.roleDoctor:
        return doctorDashboard;
      case AppConstants.roleNurse:
        return nurseDashboard;
      case AppConstants.rolePatient:
      default:
        return patientDashboard;
    }
  }
}

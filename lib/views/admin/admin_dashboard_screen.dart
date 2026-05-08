import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/admin_colors.dart';
import '../../core/routes.dart';
import '../../services/admin_service.dart';
import '../../viewmodels/admin/admin_dashboard_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/admin/admin_topbar.dart';
import '../../widgets/admin/chart_widget.dart';
import '../../widgets/admin/data_table_widget.dart';
import '../../widgets/admin/stats_card.dart';
import 'doctors_screen.dart';
import 'nurses_screen.dart';
import 'patients_screen.dart';
import 'rooms_screen.dart';
import 'accounts_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'messages_screen.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Admin Dashboard Screen (Main)
// Écran principal du tableau de bord administrateur
// Main Administrative Dashboard Screen
// ════════════════════════════════════════════════════════════════

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Current active page
  // Page actuellement active
  AdminPage _currentPage = AdminPage.dashboard;

  /// Get localized page title
  /// Obtenir le titre de la page localisé
  String _getPageTitle(AdminPage page) {
    switch (page) {
      case AdminPage.dashboard:
        return 'Dashboard / Tableau de bord';
      case AdminPage.doctors:
        return 'Doctors / Médecins';
      case AdminPage.nurses:
        return 'Nurses / Infirmières';
      case AdminPage.patients:
        return 'Patients / Patientes';
      case AdminPage.rooms:
        return 'Rooms / Chambres';
      case AdminPage.messages:
        return 'Messages';
      case AdminPage.accounts:
        return 'Accounts / Comptes';
      case AdminPage.settings:
        return 'Settings / Paramètres';
      case AdminPage.notifications:
        return 'Notifications';
    }
  }

  /// Handle logout with confirmation
  /// Gérer la déconnexion avec confirmation
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout / Déconnexion',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?\n'
          'Êtes-vous sûr de vouloir vous déconnecter?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          // Cancel button / Bouton Annuler
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel / Annuler',
              style: GoogleFonts.inter(
                color: AdminColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Confirm logout button / Bouton Confirmer
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.danger,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Logout / Déconnecter',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // Process logout if confirmed
    // Traiter la déconnexion si confirmée
    if (confirmed == true && mounted) {
      await context.read<AuthViewModel>().signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel(),
      child: Scaffold(
        backgroundColor: AdminColors.pageBg,
        body: Row(
          children: [
            // ────────────────────────────────────────
            // LEFT SIDEBAR / BARRE LATÉRALE GAUCHE
            // ────────────────────────────────────────
            AdminSidebar(
              currentPage: _currentPage,
              onPageChanged: (page) => setState(
                () => _currentPage = page,
              ),
              onLogout: _handleLogout,
            ),

            // ────────────────────────────────────────
            // MAIN CONTENT AREA / ZONE DE CONTENU PRINCIPALE
            // ────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  // Top navigation bar / Barre de navigation supérieure
                  AdminTopbar(
                    pageTitle: _getPageTitle(_currentPage),
                    onNotificationTap: () => setState(
                      () => _currentPage = AdminPage.notifications,
                    ),
                  ),

                  // Dynamic page content with smooth transition
                  // Contenu de page dynamique avec transition fluide
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(_currentPage),
                        child: _buildCurrentPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the currently selected page
  /// Construire la page actuellement sélectionnée
  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case AdminPage.dashboard:
        return const _DashboardHome();
      case AdminPage.doctors:
        return const DoctorsScreen();
      case AdminPage.nurses:
        return const NursesScreen();
      case AdminPage.patients:
        return const PatientsScreen();
      case AdminPage.rooms:
        return const RoomsScreen();
      case AdminPage.messages:
        return const MessagesScreen();
      case AdminPage.accounts:
        return const AccountsScreen();
      case AdminPage.settings:
        return const SettingsScreen();
      case AdminPage.notifications:
        return const NotificationsScreen();
    }
  }
}

// ════════════════════════════════════════════════════════════════
// DASHBOARD HOME PAGE
// PAGE D'ACCUEIL DU TABLEAU DE BORD
// ════════════════════════════════════════════════════════════════

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardViewModel>(
      builder: (context, vm, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header section / Section d'en-tête de bienvenue
              _buildWelcomeHeader(context),

              const SizedBox(height: 24),

              // Statistics cards grid / Grille de cartes statistiques
              _StatsGrid(service: vm.service),

              const SizedBox(height: 24),

              // Charts visualization row / Rangée de visualisation graphique
              _ChartsRow(vm: vm),

              const SizedBox(height: 24),

              // Recent activity tables / Tableaux d'activité récente
              _RecentTablesRow(service: vm.service),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Build welcome header with gradient background
  /// Construire l'en-tête de bienvenue avec fond dégradé
  Widget _buildWelcomeHeader(BuildContext context) {
    final user = context.read<AuthViewModel>().currentUser;
    final name = user?.firstName ?? 'Admin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AdminColors.primaryBlue,
            AdminColors.primaryBlueDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AdminColors.primaryBlue.withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text content / Contenu textuel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name! 👋',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'HerCare Admin Dashboard - Manage your healthcare system',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tableau de bord HerCare - Gérez votre système de santé',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withAlpha(191),
                  ),
                ),
              ],
            ),
          ),

          // Icon container / Conteneur d'icône
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// STATISTICS GRID - Real-time Firebase Data
// GRILLE DE STATISTIQUES - Données Firebase en temps réel
// ════════════════════════════════════════════════════════════════

class _StatsGrid extends StatelessWidget {
  final AdminService service;

  const _StatsGrid({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: service.getStatsStream(),
      builder: (context, snapshot) {
        // Loading state / État de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: AdminColors.primaryBlue,
              ),
            ),
          );
        }

        // Error state / État d'erreur
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AdminColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data / Erreur de chargement',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Data state / État des données
        final stats = snapshot.data ??
            {
              'patients': 0,
              'doctors': 0,
              'nurses': 0,
              'rooms': 0,
              'availableRooms': 0,
            };

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive column count / Nombre de colonnes réactif
            int columns = 4;
            if (constraints.maxWidth < 900) columns = 2;
            if (constraints.maxWidth < 600) columns = 1;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.7,
              children: [
                // ──────────────────────────────────
                // PATIENTS CARD / CARTE PATIENTS
                // ──────────────────────────────────
                StatsCard(
                  title: 'Patients',
                  value: stats['patients'].toString(),
                  subtitle: 'Registered in system / Enregistrées',
                  icon: Icons.people_outline_rounded,
                  color: AdminColors.pink,
                  changePercent: 12.5,
                  isIncrease: true,
                ),

                // ──────────────────────────────────
                // DOCTORS CARD / CARTE MÉDECINS
                // ──────────────────────────────────
                StatsCard(
                  title: 'Doctors / Médecins',
                  value: stats['doctors'].toString(),
                  subtitle: 'Active doctors / Actifs',
                  icon: Icons.medical_services_outlined,
                  color: AdminColors.primaryBlue,
                  changePercent: 4.2,
                  isIncrease: true,
                ),

                // ──────────────────────────────────
                // NURSES CARD / CARTE INFIRMIÈRES
                // ──────────────────────────────────
                StatsCard(
                  title: 'Nurses / Infirmières',
                  value: stats['nurses'].toString(),
                  subtitle: 'Available nurses / Disponibles',
                  icon: Icons.local_hospital_outlined,
                  color: AdminColors.greenCard,
                  changePercent: 2.1,
                  isIncrease: true,
                ),

                // ──────────────────────────────────
                // ROOMS CARD / CARTE CHAMBRES
                // ──────────────────────────────────
                StatsCard(
                  title: 'Available Rooms / Chambres',
                  value: '${stats['availableRooms']}/${stats['rooms']}',
                  subtitle: 'Rooms ready / Prêtes',
                  icon: Icons.bed_outlined,
                  color: AdminColors.orangeCard,
                  changePercent: 3.8,
                  isIncrease: false,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// CHARTS VISUALIZATION ROW
// RANGÉE DE VISUALISATION GRAPHIQUE
// ════════════════════════════════════════════════════════════════

class _ChartsRow extends StatelessWidget {
  final AdminDashboardViewModel vm;

  const _ChartsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Wide screen layout: side-by-side charts
        // Disposition écran large : graphiques côte à côte
        if (constraints.maxWidth > 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line chart (60% width) / Graphique linéaire
              Expanded(
                flex: 3,
                child: LineChartWidget(
                  title: 'Monthly Patients Statistics / '
                      'Statistiques mensuelles',
                  data: vm.monthlyData,
                  labels: vm.monthLabels,
                ),
              ),

              const SizedBox(width: 16),

              // Pie chart (40% width) / Graphique circulaire
              Expanded(
                flex: 2,
                child: PieChartWidget(
                  title: 'Staff Distribution / '
                      'Répartition du personnel',
                  data: [
                    PieChartData(
                      label: 'Patients',
                      value: 60,
                      color: AdminColors.pink,
                    ),
                    PieChartData(
                      label: 'Doctors / Médecins',
                      value: 20,
                      color: AdminColors.primaryBlue,
                    ),
                    PieChartData(
                      label: 'Nurses / Infirmières',
                      value: 20,
                      color: AdminColors.greenCard,
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // Narrow screen layout: stacked
        // Disposition écran étroit : empilé
        return LineChartWidget(
          title: 'Monthly Statistics / Statistiques mensuelles',
          data: vm.monthlyData,
          labels: vm.monthLabels,
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// RECENT ACTIVITY TABLES
// TABLEAUX D'ACTIVITÉ RÉCENTE
// ════════════════════════════════════════════════════════════════

class _RecentTablesRow extends StatelessWidget {
  final AdminService service;

  const _RecentTablesRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Wide screen: two tables side-by-side
        // Écran large : deux tableaux côte à côte
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentDoctors()),
              const SizedBox(width: 16),
              Expanded(child: _buildRecentPatients()),
            ],
          );
        }

        // Narrow screen: stacked tables
        // Écran étroit : tableaux empilés
        return Column(
          children: [
            _buildRecentDoctors(),
            const SizedBox(height: 16),
            _buildRecentPatients(),
          ],
        );
      },
    );
  }

  /// Build recent doctors table with real-time data
  /// Construire le tableau des médecins récents avec données temps réel
  Widget _buildRecentDoctors() {
    return StreamBuilder<QuerySnapshot>(
      stream: service.getDoctorsStream(),
      builder: (context, snapshot) {
        // Display only last 4 entries
        // Afficher seulement les 4 dernières entrées
        final docs = (snapshot.data?.docs ?? []).take(4).toList();

        return AdminDataTable(
          title: 'Recent Doctors / Derniers Médecins',
          columns: const [
            'Name / Nom',
            'Specialty / Spécialité',
            'Status / Statut',
          ],
          rows: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final fullName =
                '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';

            return [
              // Full name / Nom complet
              Text(
                fullName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),

              // Medical specialty / Spécialité médicale
              Text(
                data['specialty'] ?? '-',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),

              // Activity status / Statut d'activité
              StatusBadge(
                status: data['status'] ?? 'active',
              ),
            ];
          }).toList(),
        );
      },
    );
  }

  /// Build recent patients table with real-time data
  /// Construire le tableau des patients récents avec données temps réel
  Widget _buildRecentPatients() {
    return StreamBuilder<QuerySnapshot>(
      stream: service.getPatientsStream(),
      builder: (context, snapshot) {
        final docs = (snapshot.data?.docs ?? []).take(4).toList();

        return AdminDataTable(
          title: 'Recent Patients / Dernières Patientes',
          columns: const [
            'Name / Nom',
            'Province / Wilaya',
            'Status / Statut',
          ],
          rows: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final fullName =
                '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';

            return [
              // Full name / Nom complet
              Text(
                fullName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),

              // Geographic location / Localisation géographique
              Text(
                data['wilaya'] ?? '-',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AdminColors.textSecondary,
                ),
              ),

              // Medical status / Statut médical
              StatusBadge(
                status: data['status'] ?? 'active',
              ),
            ];
          }).toList(),
        );
      },
    );
  }
}

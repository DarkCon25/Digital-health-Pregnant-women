import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/app_responsive.dart';
import '../core/colors.dart';
import '../core/routes.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_button.dart' as btn;
import '../widgets/custom_text_field.dart';
import '../widgets/left_panel.dart';
import '../widgets/app_logo.dart';

// ════════════════════════════════════════════════
// ENUM — أي Panel يظهر على اليمين
// ════════════════════════════════════════════════

enum RightPanelView { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Panel State ──────────────────────────────
  RightPanelView _currentView = RightPanelView.login;

  // ── Animation ────────────────────────────────
  late AnimationController _panelController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ── Forgot Password Overlay ───────────────────
  bool _showForgotOverlay = false;

  // ── Login Form ───────────────────────────────
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  // ── Register Form ────────────────────────────
  final _registerFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  String? _selectedWilaya;
  DateTime? _selectedDate;

  // ── Forgot Password Form ─────────────────────
  final _forgotEmailController = TextEditingController();
  bool _forgotEmailSent = false;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    ));
    _panelController.forward();
  }

  @override
  void dispose() {
    _panelController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _registerEmailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  // ── Switch Panel ─────────────────────────────
  void _switchView(RightPanelView view) {
    if (_currentView == view) return;
    _panelController.reverse().then((_) {
      setState(() {
        _currentView = view;
        context.read<AuthViewModel>().clearError();
      });
      _panelController.forward();
    });
  }

  // ── Show/Hide Forgot Overlay ─────────────────
  void _openForgotOverlay() {
    setState(() {
      _showForgotOverlay = true;
      _forgotEmailSent = false;
      _forgotEmailController.clear();
    });
  }

  void _closeForgotOverlay() {
    setState(() {
      _showForgotOverlay = false;
      _forgotEmailSent = false;
    });
    context.read<AuthViewModel>().clearError();
  }

  // ── Login Handler ─────────────────────────────
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final success = await vm.signInWithEmail(
      email: _loginEmailController.text,
      password: _loginPasswordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.placeholder);
    }
  }

  // ── Register Handler ──────────────────────────
  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showSnackBar("Veuillez accepter les conditions d'utilisation.");
      return;
    }
    final vm = context.read<AuthViewModel>();
    final success = await vm.registerWithEmail(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _registerEmailController.text,
      password: _passwordController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      wilaya: _selectedWilaya,
      dateOfBirth: _selectedDate,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.placeholder);
    }
  }

  // ── Google Sign-In ────────────────────────────
  Future<void> _handleGoogleSignIn() async {
    final vm = context.read<AuthViewModel>();
    final success = await vm.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.placeholder);
    }
  }

  // ── Forgot Password Handler ───────────────────
  Future<void> _handleForgotPassword() async {
    if (_forgotEmailController.text.trim().isEmpty) {
      _showSnackBar('Veuillez entrer votre adresse email.');
      return;
    }
    final vm = context.read<AuthViewModel>();
    final success =
        await vm.sendPasswordResetEmail(_forgotEmailController.text);
    if (success && mounted) {
      setState(() => _forgotEmailSent = true);
    }
  }

  // ── Date Picker ───────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Main Layout ──
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 768) {
                return _buildDesktopLayout();
              }
              return _buildMobileLayout();
            },
          ),

          // ── Forgot Password Overlay ──
          if (_showForgotOverlay) _buildForgotOverlay(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ════════════════════════════════════════════

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Panel
        const Expanded(flex: 52, child: LeftPanel()),

        // Right Panel
        Expanded(
          flex: 48,
          child: Container(
            color: AppColors.background,
            child: Center(
              child: SingleChildScrollView(
                padding: AppResponsive.pagePadding(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppResponsive.cardMaxWidth(context),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _currentView == RightPanelView.login
                          ? _buildLoginCard()
                          : _buildRegisterCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // MOBILE LAYOUT
  // ════════════════════════════════════════════

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _MobileHeader(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _currentView == RightPanelView.login
                    ? _buildLoginCard()
                    : _buildRegisterCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  // LOGIN CARD
  // ════════════════════════════════════════════

  Widget _buildLoginCard() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final isMobile = AppResponsive.isMobile(context);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 36),
          decoration: _cardDecoration(),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Lock Icon + Title
                _buildLoginHeader(),
                const SizedBox(height: 24),

                // ── Error
                if (vm.errorMessage != null) ...[
                  _ErrorBanner(
                      message: vm.errorMessage!, onDismiss: vm.clearError),
                  const SizedBox(height: 16),
                ],

                // ── Email
                CustomTextField(
                  controller: _loginEmailController,
                  label: "Adresse e-mail ou nom d'utilisateur",
                  hintText: 'Entrez votre e-mail ou identifiant',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),

                // ── Password
                CustomTextField(
                  controller: _loginPasswordController,
                  label: 'Mot de passe',
                  hintText: 'Entrez votre mot de passe',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureLoginPassword,
                  suffixWidget: IconButton(
                    icon: Icon(
                      _obscureLoginPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textLight,
                      size: 18,
                    ),
                    onPressed: () => setState(
                        () => _obscureLoginPassword = !_obscureLoginPassword),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 14),

                // ── Remember + Forgot
                _buildRememberForgot(vm),
                const SizedBox(height: 22),

                // ── Login Button
                btn.PrimaryButton(
                  label: 'Se connecter',
                  isLoading: vm.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 18),

                // ── Divider
                _buildDivider(),
                const SizedBox(height: 18),

                // ── Patient Section
                _buildPatientSection(vm),
                const SizedBox(height: 14),

                // ── Security Badge
                const _SecurityBadge(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Login Header ─────────────────────────────
  Widget _buildLoginHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryBluePale,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primaryBlue, size: 24),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'Connexion',
            style: GoogleFonts.inter(
              fontSize: AppResponsive.fontSize(context,
                  mobile: 20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            'Accédez à votre espace sécurisé',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Remember + Forgot ────────────────────────
  Widget _buildRememberForgot(AuthViewModel vm) {
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            // ✅ يفتح الـ Overlay بدل Navigate
            onTap: _openForgotOverlay,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔑', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Mot de passe oublié ?',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPink,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Se souvenir de moi',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            Transform.scale(
              scale: 0.85,
              child: Checkbox(
                value: vm.rememberMe,
                onChanged: vm.toggleRememberMe,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Patient Section ──────────────────────────
  Widget _buildPatientSection(AuthViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentPinkLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentPinkBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Espace Patiente Enceinte',
                  style: GoogleFonts.inter(
                    fontSize: AppResponsive.fontSize(context,
                        mobile: 13, tablet: 14, desktop: 15),
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Text('🤰', style: TextStyle(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Inscrivez-vous ou connectez-vous pour consulter votre dossier médical et suivre votre grossesse',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.accentPink.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          _ResponsiveButtons(
            isLoading: vm.isLoading,
            onGoogleSignIn: _handleGoogleSignIn,
            // ✅ يبدل الـ Panel بدل Navigate
            onCreateAccount: () => _switchView(RightPanelView.register),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  // REGISTER CARD
  // ════════════════════════════════════════════

  Widget _buildRegisterCard() {
    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final isMobile = AppResponsive.isMobile(context);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          decoration: _cardDecoration(),
          child: Form(
            key: _registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Back Button
                GestureDetector(
                  onTap: () => _switchView(RightPanelView.login),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios_rounded,
                          size: 13, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Retour à la connexion',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title
                Text(
                  'Créer un compte',
                  style: GoogleFonts.inter(
                    fontSize: AppResponsive.fontSize(context,
                        mobile: 20, tablet: 22, desktop: 24),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rejoignez notre communauté pour un suivi de grossesse serein',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // ── Error
                if (vm.errorMessage != null) ...[
                  _ErrorBanner(
                      message: vm.errorMessage!, onDismiss: vm.clearError),
                  const SizedBox(height: 14),
                ],

                // ── Name Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: 'Nom',
                        hintText: 'Votre nom',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: 'Prénom',
                        hintText: 'Votre prénom',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Email
                CustomTextField(
                  controller: _registerEmailController,
                  label: 'Email',
                  hintText: 'exemple@mail.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),

                // ── Phone + DOB
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _phoneController,
                        label: 'Téléphone',
                        hintText: '05/06/07...',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDateField()),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Wilaya
                _buildWilayaDropdown(),
                const SizedBox(height: 12),

                // ── Password Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixWidget: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textLight,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: _validatePassword,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmer',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscureConfirm,
                        suffixWidget: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.textLight,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: _validateConfirm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Terms
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) =>
                            setState(() => _acceptTerms = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary),
                          children: [
                            const TextSpan(text: "J'accepte les "),
                            TextSpan(
                              text: "conditions d'utilisation",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(
                                text:
                                    " et la politique de confidentialité de HerCare."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Register Button
                btn.PrimaryButton(
                  label: 'Créer mon compte',
                  isLoading: vm.isLoading,
                  onPressed: _handleRegister,
                  backgroundColor: AppColors.accentPink,
                  height: 52,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Date Field ───────────────────────────────
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de naissance',
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textLight),
                const SizedBox(width: 10),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                      : 'jj/mm/aaaa',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Wilaya Dropdown ──────────────────────────
  Widget _buildWilayaDropdown() {
    final wilayas = [
      'Adrar',
      'Chlef',
      'Laghouat',
      'Oum El Bouaghi',
      'Batna',
      'Béjaïa',
      'Biskra',
      'Béchar',
      'Blida',
      'Bouira',
      'Tamanrasset',
      'Tébessa',
      'Tlemcen',
      'Tiaret',
      'Tizi Ouzou',
      'Alger',
      'Djelfa',
      'Jijel',
      'Sétif',
      'Saïda',
      'Skikda',
      'Sidi Bel Abbès',
      'Annaba',
      'Guelma',
      'Constantine',
      'Médéa',
      'Mostaganem',
      "M'Sila",
      'Mascara',
      'Ouargla',
      'Oran',
      'El Bayadh',
      'Illizi',
      'Bordj Bou Arréridj',
      'Boumerdès',
      'El Tarf',
      'Tindouf',
      'Tissemsilt',
      'El Oued',
      'Khenchela',
      'Souk Ahras',
      'Tipaza',
      'Mila',
      'Aïn Defla',
      'Naâma',
      'Aïn Témouchent',
      'Ghardaïa',
      'Relizane',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wilaya',
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedWilaya,
          onChanged: (val) => setState(() => _selectedWilaya = val),
          hint: Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textLight),
              const SizedBox(width: 8),
              Text('Sélectionner Wilaya',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textLight)),
            ],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.borderFocus, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: wilayas
              .map((w) => DropdownMenuItem(
                    value: w,
                    child: Text(w,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textPrimary)),
                  ))
              .toList(),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textLight),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // FORGOT PASSWORD OVERLAY
  // ════════════════════════════════════════════

  Widget _buildForgotOverlay() {
    return GestureDetector(
      // ✅ إغلاق عند الضغط خارج الـ Card
      onTap: _closeForgotOverlay,
      child: Stack(
        children: [
          // ── Blurred Background ──
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          // ── Dialog Card ──
          Center(
            child: GestureDetector(
              // ✅ منع الإغلاق عند الضغط على الـ Card نفسها
              onTap: () {},
              child: Consumer<AuthViewModel>(
                builder: (context, vm, _) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.all(24),
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 40,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _forgotEmailSent
                        ? _buildForgotSuccess()
                        : _buildForgotForm(vm),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Forgot Form ──────────────────────────────
  Widget _buildForgotForm(AuthViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryBluePale,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: AppColors.primaryBlue, size: 28),
        ),
        const SizedBox(height: 18),

        // ── Title
        Text(
          'Réinitialisation du mot de passe',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),

        // ── Error
        if (vm.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(vm.errorMessage!,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.error)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // ── Email Field
        CustomTextField(
          controller: _forgotEmailController,
          label: 'Adresse e-mail',
          hintText: 'exemple@mail.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // ── Send Button
        btn.PrimaryButton(
          label: 'Envoyer la demande',
          isLoading: vm.isLoading,
          onPressed: _handleForgotPassword,
        ),
        const SizedBox(height: 10),

        // ── Cancel
        TextButton(
          onPressed: _closeForgotOverlay,
          child: Text(
            'Annuler',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Forgot Success ───────────────────────────
  Widget _buildForgotSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Success Icon
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              color: AppColors.success, size: 34),
        ),
        const SizedBox(height: 18),

        Text(
          'Email envoyé !',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Un lien de réinitialisation a été envoyé à\n${_forgotEmailController.text}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Vérifiez votre boîte mail et vos spams.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
        ),
        const SizedBox(height: 24),

        btn.PrimaryButton(
          label: 'Retour à la connexion',
          onPressed: _closeForgotOverlay,
          icon: Icons.arrow_back_rounded,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou',
              style:
                  GoogleFonts.inter(fontSize: 12, color: AppColors.textLight)),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requis';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Confirmation requise';
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}

// ════════════════════════════════════════════════
// MOBILE HEADER
// ════════════════════════════════════════════════

class _MobileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.22;
    return Container(
      width: double.infinity,
      height: height.clamp(140.0, 200.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ اللوجو الحقيقي
          AppLogo(
            size: 90,
            isCircle: true,
            borderColor: Colors.white.withOpacity(0.4),
            borderWidth: 2,
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 10),
          Text(
            'HerCare',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'DIGITAL HEALTH',
            style: GoogleFonts.inter(
              fontSize: 10,
              letterSpacing: 3,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// RESPONSIVE BUTTONS
// ════════════════════════════════════════════════

class _ResponsiveButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onCreateAccount;

  const _ResponsiveButtons({
    required this.isLoading,
    required this.onGoogleSignIn,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 260) {
          return Row(
            children: [
              Expanded(child: _googleBtn()),
              const SizedBox(width: 10),
              Expanded(child: _createBtn()),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(width: double.infinity, child: _googleBtn()),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: _createBtn()),
          ],
        );
      },
    );
  }

  Widget _googleBtn() {
    return SizedBox(
      height: 42,
      child: OutlinedButton(
        onPressed: isLoading ? null : onGoogleSignIn,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _GoogleDots(),
              const SizedBox(width: 6),
              Text(
                'Connexion Google',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createBtn() {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onCreateAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPink,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_outlined, size: 14),
              const SizedBox(width: 6),
              Text(
                'Créer un compte',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
// GOOGLE DOTS
// ════════════════════════════════════════════════

class _GoogleDots extends StatelessWidget {
  const _GoogleDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(const Color(0xFF4285F4)),
        const SizedBox(width: 2),
        _dot(const Color(0xFFEA4335)),
        const SizedBox(width: 2),
        _dot(const Color(0xFFFBBC05)),
        const SizedBox(width: 2),
        _dot(const Color(0xFF34A853)),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ════════════════════════════════════════════════
// ERROR BANNER
// ════════════════════════════════════════════════

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.error)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                color: AppColors.error, size: 16),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════
// SECURITY BADGE
// ════════════════════════════════════════════════

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
              color: AppColors.success, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style:
                  GoogleFonts.inter(fontSize: 11, color: AppColors.textLight),
              children: [
                const TextSpan(text: 'Environnement '),
                TextSpan(
                  text: 'sécurisé',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' et chiffré pour protéger vos données'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

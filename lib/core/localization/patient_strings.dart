/// HerCare — Patient multilingual strings (AR / FR / EN).
/// Usage: PatientL10n.of(langCode).dashboardTitle
class PatientL10n {
  PatientL10n._(this._locale);

  final String _locale;

  static PatientL10n of(String locale) => PatientL10n._(locale);

  bool get isArabic => _locale == 'ar';

  // ── App Shell ─────────────────────────────────────────────────────────
  String get appName => _s('HerCare', 'HerCare', 'هيركير');
  String get portalLabel =>
      _s('Patient Portal', 'Espace Patiente', 'بوابة المريضة');

  // ── Sidebar Navigation ────────────────────────────────────────────────
  String get navDashboard =>
      _s('Dashboard', 'Tableau de bord', 'لوحة التحكم');
  String get navMedicalFile =>
      _s('My Medical File', 'Mon dossier médical', 'ملفي الطبي');
  String get navAnalyses => _s('Analyses', 'Analyses', 'التحاليل');
  String get navFetalImages =>
      _s('Fetal Images', 'Images du fœtus', 'صور الجنين');
  String get navAppointments =>
      _s('Appointments', 'Rendez-vous', 'المواعيد');
  String get navEmergency => _s('Emergency', 'Urgence', 'طوارئ');
  String get navNotifications =>
      _s('Notifications', 'Notifications', 'الإشعارات');
  String get navProfile => _s('Profile', 'Profil', 'الملف الشخصي');
  String get navLogout => _s('Logout', 'Déconnexion', 'تسجيل الخروج');

  // ── Dashboard ─────────────────────────────────────────────────────────
  String get greetingHello => _s('Hello', 'Bonjour', 'مرحباً');
  String get greetingSub =>
      _s('Take care of yourself and your baby 💗',
          'Prenez soin de vous et de votre bébé 💗',
          'اعتني بنفسك وبطفلك 💗');
  String get pregnancyWeeks =>
      _s('Weeks of pregnancy', 'Semaines de grossesse', 'أسابيع الحمل');
  String get pregnancyAge => _s('Pregnancy', 'Grossesse', 'الحمل');
  String get nextAppointment =>
      _s('Next appointment', 'Prochaine consultation', 'الموعد القادم');
  String get currentMonth =>
      _s('Current month', 'Mois actuel', 'الشهر الحالي');
  String get babyStatus =>
      _s('Baby status', 'État du bébé', 'حالة الجنين');
  String get bloodType => _s('Blood type', 'Groupe sanguin', 'فصيلة الدم');
  String get attendingPhysician =>
      _s('Attending Physician', 'Médecin traitant', 'الطبيب المتابع');
  String get healthSummary =>
      _s('Health Summary', 'Aperçu de la santé', 'ملخص الصحة');
  String get recentFetalImages =>
      _s('Recent Fetal Images', 'Dernières images', 'آخر صور الجنين');
  String get viewAll => _s('View all', 'Voir tout', 'عرض الكل');
  String get noImages =>
      _s('No images yet', 'Aucune image', 'لا توجد صور بعد');
  String get noData => _s('No data', 'Aucune donnée', 'لا توجد بيانات');

  // ── Health Metric Labels ───────────────────────────────────────────────
  String get metricBP =>
      _s('Blood Pressure', 'Tension artérielle', 'ضغط الدم');
  String get metricBPUnit => _s('mmHg', 'mmHg', 'ملم/زئبق');
  String get metricGlucose =>
      _s('Blood Sugar', 'Glycémie', 'السكر في الدم');
  String get metricGlucoseUnit => _s('mg/dL', 'mg/dL', 'ملغ/دل');
  String get metricTemp => _s('Temperature', 'Température', 'درجة الحرارة');
  String get metricTempUnit => _s('°C', '°C', '°م');
  String get metricWeight => _s('Weight', 'Poids', 'الوزن');
  String get metricWeightUnit => _s('kg', 'kg', 'كجم');
  String get metricFetalHR =>
      _s('Baby Heart Rate', 'BPM bébé', 'نبض الجنين');
  String get metricFetalHRUnit => _s('bpm', 'bpm', 'نبضة/د');

  // ── Medical File ──────────────────────────────────────────────────────
  String get medFileTitle =>
      _s('My Medical File', 'Mon dossier médical', 'ملفي الطبي');
  String get medFileSub =>
      _s('Your complete pregnancy record',
          'Votre dossier de grossesse complet',
          'سجل حملك الكامل');
  String get fileNumber => _s('File number', 'Numéro de dossier', 'رقم الملف');
  String get patientName =>
      _s('Patient name', 'Nom de la patiente', 'اسم المريضة');
  String get registrationDate =>
      _s('Registration date', 'Date d\'inscription', 'تاريخ التسجيل');
  String get expectedDueDate =>
      _s('Expected Due Date', 'Date d\'accouchement prévue', 'تاريخ الولادة المتوقع');
  String get deliveryType =>
      _s('Expected Delivery Type', 'Type d\'accouchement prévu', 'نوع الولادة');
  String get room => _s('Room / Reception', 'Salle / Chambre', 'الغرفة');
  String get healthStatus =>
      _s('Health status', 'Condition de santé', 'الحالة الصحية');
  String get doctorNotes =>
      _s('Doctor Notes', 'Notes du médecin', 'ملاحظات الطبيب');
  String get pregnancyTimeline =>
      _s('Pregnancy Timeline', 'Chronologie de la grossesse', 'مراحل الحمل');
  String get trimester1 =>
      _s('1st Trimester', '1er Trimestre', 'الثلث الأول');
  String get trimester2 =>
      _s('2nd Trimester', '2ème Trimestre', 'الثلث الثاني');
  String get trimester3 =>
      _s('3rd Trimester', '3ème Trimestre', 'الثلث الثالث');
  String get dueDateLabel =>
      _s('Due Date', 'Date d\'accouchement', 'تاريخ الولادة');
  String get lastUpdated =>
      _s('Last updated', 'Dernière mise à jour', 'آخر تحديث');
  String get noMedFile =>
      _s('No medical file found', 'Aucun dossier médical', 'لم يُعثر على ملف طبي');

  // ── Analyses ──────────────────────────────────────────────────────────
  String get analysesTitle =>
      _s('Analyses', 'Analyses', 'التحاليل الطبية');
  String get analysesSub =>
      _s('Test Results', 'Résultats de vos analyses', 'نتائج التحاليل');
  String get tabAll => _s('All', 'Tous', 'الكل');
  String get tabBlood => _s('Blood', 'Sang', 'دم');
  String get tabUrine => _s('Urine', 'Urine', 'بول');
  String get tabOther => _s('Others', 'Autres', 'أخرى');
  String get colTest => _s('Test', 'Examen', 'الفحص');
  String get colResult => _s('Result', 'Résultat', 'النتيجة');
  String get colDate => _s('Date', 'Date', 'التاريخ');
  String get colStatus => _s('Status', 'Statut', 'الحالة');
  String get colFile => _s('File', 'Fichier', 'الملف');
  String get statusNormal => _s('Normal', 'Normal', 'طبيعي');
  String get statusLow => _s('Low', 'Faible', 'منخفض');
  String get statusCritical => _s('Critical', 'Critique', 'حرج');
  String get statusHigh => _s('High', 'Élevé', 'مرتفع');
  String get downloadFile =>
      _s('Download', 'Télécharger', 'تحميل');
  String get noAnalyses =>
      _s('No analyses yet', 'Aucune analyse', 'لا توجد تحاليل بعد');
  String get noteConsultDoctor =>
      _s('Note: Please consult your doctor for more details.',
          'Remarque : Consultez votre médecin pour plus de détails.',
          'ملاحظة: استشيري طبيبك للمزيد من التفاصيل.');

  // ── Fetal Images ──────────────────────────────────────────────────────
  String get fetalImagesTitle =>
      _s('Fetal Images', 'Images du fœtus', 'صور الجنين');
  String get fetalImagesSub =>
      _s('Echo / Ultrasound gallery', 'Galerie écho / échographie', 'معرض صور الإيكو');
  String get noteImagesInfo =>
      _s('Note: Images are for informational purposes only.',
          'Remarque : Les images sont à titre informatif uniquement.',
          'ملاحظة: الصور للاطلاع فقط ولا تُعدّ تشخيصاً طبياً.');
  String get noFetalImages =>
      _s('No images yet', 'Aucune image', 'لا توجد صور بعد');
  String get fullscreen =>
      _s('Full screen', 'Plein écran', 'ملء الشاشة');
  String get close => _s('Close', 'Fermer', 'إغلاق');

  // ── Appointments ──────────────────────────────────────────────────────
  String get appointmentsTitle =>
      _s('Appointments', 'Rendez-vous', 'المواعيد');
  String get appointmentsSub =>
      _s('Your scheduled visits', 'Vos visites planifiées', 'مواعيدك المجدولة');
  String get tabUpcoming =>
      _s('Upcoming', 'À venir', 'القادمة');
  String get tabPast => _s('Past', 'Passés', 'السابقة');
  String get statusConfirmed =>
      _s('Confirmed', 'Confirmé', 'مؤكد');
  String get statusPending =>
      _s('Pending', 'En attente', 'قيد الانتظار');
  String get statusCompleted =>
      _s('Completed', 'Terminé', 'مكتمل');
  String get statusCancelled =>
      _s('Cancelled', 'Annulé', 'ملغى');
  String get requestNewAppointment =>
      _s('Request New Appointment', 'Demander un nouveau rendez-vous', 'طلب موعد جديد');
  String get noAppointments =>
      _s('No appointments', 'Aucun rendez-vous', 'لا توجد مواعيد');
  String get requestSent =>
      _s('Request sent successfully!', 'Demande envoyée avec succès !', 'تم إرسال الطلب بنجاح!');
  String get appointmentType =>
      _s('Type', 'Type', 'النوع');
  String get appointmentWith =>
      _s('with', 'avec', 'مع');

  // ── Emergency ─────────────────────────────────────────────────────────
  String get emergencyTitle =>
      _s('Emergency', 'Urgence', 'طوارئ');
  String get emergencySub =>
      _s('Emergency medical assistance', 'Assistance médicale d\'urgence', 'المساعدة الطبية الطارئة');
  String get emergencyNeedHelp =>
      _s('Need immediate help?', 'Besoin d\'aide immédiate ?', 'تحتاجين مساعدة فورية؟');
  String get emergencyDesc =>
      _s('Press the button below to alert the medical team.',
          'Appuyez sur le bouton ci-dessous pour alerter l\'équipe médicale.',
          'اضغطي الزر أدناه لتنبيه الفريق الطبي.');
  String get emergencyLocationNote =>
      _s('Your location and information will be sent automatically.',
          'Votre localisation et vos informations seront envoyées automatiquement.',
          'سيتم إرسال موقعك ومعلوماتك تلقائياً.');
  String get emergencyCallBtn =>
      _s('Emergency Call', 'Appel d\'urgence', 'نداء استغاثة');
  String get emergencySending =>
      _s('Sending alert…', 'Envoi en cours…', 'جارٍ الإرسال…');
  String get emergencySent =>
      _s('Alert sent! Help is on the way.', 'Alerte envoyée ! Aide en route.', 'تم الإرسال! المساعدة في الطريق.');
  String get emergencyError =>
      _s('Failed to send. Retry.', 'Échec de l\'envoi. Réessayez.', 'فشل الإرسال. حاولي مجدداً.');

  // ── Notifications ─────────────────────────────────────────────────────
  String get notificationsTitle =>
      _s('Notifications', 'Notifications', 'الإشعارات');
  String get notificationsSub =>
      _s('Your recent alerts & messages',
          'Vos alertes et messages récents',
          'تنبيهاتك ورسائلك الأخيرة');
  String get viewAllNotifications =>
      _s('View all notifications', 'Voir toutes les notifications', 'عرض جميع الإشعارات');
  String get noNotifications =>
      _s('No notifications', 'Aucune notification', 'لا توجد إشعارات');
  String get today => _s('Today', 'Aujourd\'hui', 'اليوم');
  String get yesterday => _s('Yesterday', 'Hier', 'أمس');

  // ── Profile ───────────────────────────────────────────────────────────
  String get profileTitle =>
      _s('Profile', 'Profil', 'الملف الشخصي');
  String get profileSub =>
      _s('Your personal information', 'Vos informations personnelles', 'بياناتك الشخصية');
  String get fullName => _s('Full name', 'Nom complet', 'الاسم الكامل');
  String get email => _s('Email', 'Email', 'البريد الإلكتروني');
  String get phone => _s('Phone', 'Téléphone', 'رقم الهاتف');
  String get address => _s('Address', 'Adresse', 'العنوان');
  String get dateOfBirth =>
      _s('Date of birth', 'Date de naissance', 'تاريخ الميلاد');
  String get editProfile =>
      _s('Edit Profile', 'Modifier le profil', 'تعديل الملف الشخصي');
  String get saveChanges =>
      _s('Save changes', 'Enregistrer', 'حفظ التغييرات');
  String get cancel => _s('Cancel', 'Annuler', 'إلغاء');
  String get languageLabel =>
      _s('Language', 'Langue', 'اللغة');
  String get langArabic => _s('Arabic', 'Arabe', 'العربية');
  String get langFrench => _s('French', 'Français', 'الفرنسية');
  String get langEnglish => _s('English', 'Anglais', 'الإنجليزية');
  String get profileUpdated =>
      _s('Profile updated', 'Profil mis à jour', 'تم تحديث الملف الشخصي');

  // ── General ───────────────────────────────────────────────────────────
  String get loading => _s('Loading…', 'Chargement…', 'جارٍ التحميل…');
  String get errorOccurred =>
      _s('An error occurred', 'Une erreur s\'est produite', 'حدث خطأ');
  String get retry => _s('Retry', 'Réessayer', 'إعادة المحاولة');
  String get months => _s('months', 'mois', 'أشهر');
  String get weeks => _s('weeks', 'semaines', 'أسابيع');
  String get days => _s('days', 'jours', 'أيام');
  String get healthy => _s('Healthy', 'En bonne santé', 'بصحة جيدة');
  String get normal => _s('Normal', 'Normal', 'طبيعي');

  String _s(String en, String fr, String ar) {
    if (_locale == 'ar') return ar;
    if (_locale == 'fr') return fr;
    return en;
  }
}

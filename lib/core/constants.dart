class AppConstants {
  // App Info
  static const String appName = 'HerCare';
  static const String appTagline = 'DIGITAL HEALTH';
  static const String appMotivation =
      'Suivi numérique intelligent\nde la santé maternelle';
  static const String appDescription =
      'Une plateforme médicale moderne facilitant la coordination\nentre l\'équipe soignante, l\'administration et la patiente.';
  static const String appQuote =
      '"Chaque suivi précis aujourd\'hui fait la différence pour la santé de\nla mère et de l\'enfant demain."';

  // Stats
  static const String stat1Value = '+500';
  static const String stat1Label = 'Patientes inscrites';
  static const String stat2Value = '50+';
  static const String stat2Label = 'Médecins et infirmières';
  static const String stat3Value = '24/7';
  static const String stat3Label = 'Toujours disponible';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String medicalFilesCollection = 'medical_files';
  static const String consultationsSubcollection = 'consultations';
  static const String emergencyAlertsCollection = 'emergency_alerts';
  static const String appointmentsCollection = 'appointments';
  static const String messagesCollection = 'messages';
  static const String roomsCollection = 'rooms';
  static const String labTestsCollection = 'lab_tests';
  static const String ultrasoundImagesCollection = 'ultrasound_images';
  static const String icuCasesCollection = 'icu_cases';
  static const String notificationsCollection = 'notifications';
  static const String medicationSchedulesCollection = 'medication_schedules';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleDoctor = 'doctor';
  static const String roleNurse = 'nurse';
  static const String rolePatient = 'patient';

  // Default Role
  static const String defaultRole = rolePatient;

  // Validation
  static const int minPasswordLength = 6;

  // Algeria Wilayas
  static const List<String> wilayas = [
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
    'M\'Sila',
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
    'Timimoun',
    'Bordj Badji Mokhtar',
    'Ouled Djellal',
    'Béni Abbès',
    'In Salah',
    'In Guezzam',
    'Touggourt',
    'Djanet',
    'El M\'Ghair',
    'El Meniaa',
  ];
}

import 'package:flutter/material.dart';

/// Controls the active language for the patient portal (AR / FR / EN).
class PatientLocaleViewModel extends ChangeNotifier {
  String _locale = 'fr';

  String get locale => _locale;

  bool get isArabic => _locale == 'ar';

  TextDirection get textDirection =>
      _locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  void setLocale(String code) {
    if (_locale == code) return;
    _locale = code;
    notifyListeners();
  }
}

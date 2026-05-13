import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/nurse/emergency_request_model.dart';
import '../../services/nurse_service.dart';

class EmergencyViewModel extends ChangeNotifier {
  EmergencyViewModel(this._service);

  final NurseService _service;

  List<EmergencyRequestModel> open = [];
  EmergencyRequestModel? selected;

  StreamSubscription<List<EmergencyRequestModel>>? _sub;

  void start() {
    _sub?.cancel();
    _sub = _service.watchEmergencyRequests().listen((list) {
      open = list.where((e) => e.isOpen).toList();
      if (selected != null) {
        final still = open.where((e) => e.id == selected!.id).toList();
        selected = still.isEmpty ? (open.isNotEmpty ? open.first : null) : still.first;
      } else if (open.isNotEmpty) {
        selected = open.first;
      }
      notifyListeners();
    });
  }

  void select(EmergencyRequestModel e) {
    selected = e;
    notifyListeners();
  }

  Future<void> resolveSelected() async {
    if (selected == null) return;
    await _service.resolveEmergency(selected!.id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

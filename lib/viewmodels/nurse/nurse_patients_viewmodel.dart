import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/nurse/nurse_patient_model.dart';
import '../../services/nurse_service.dart';

class NursePatientsViewModel extends ChangeNotifier {
  NursePatientsViewModel(this._service);

  final NurseService _service;

  List<NursePatientModel> _all = [];
  String search = '';
  String statusFilter = '';
  String roomFilter = '';
  String deliveryFilter = '';

  StreamSubscription<List<NursePatientModel>>? _sub;

  List<NursePatientModel> get allPatients => _all;

  List<NursePatientModel> get filtered {
    var list = _all;
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.fullName.toLowerCase().contains(q) ||
              p.id.toLowerCase().contains(q) ||
              (p.roomNumber ?? '').toLowerCase().contains(q))
          .toList();
    }
    if (statusFilter.isNotEmpty) {
      list = list
          .where((p) => p.status.toLowerCase() == statusFilter.toLowerCase())
          .toList();
    }
    if (roomFilter.isNotEmpty) {
      list = list
          .where((p) => (p.roomNumber ?? '') == roomFilter)
          .toList();
    }
    if (deliveryFilter.isNotEmpty) {
      list = list
          .where((p) =>
              (p.deliveryType ?? '').toLowerCase() ==
              deliveryFilter.toLowerCase())
          .toList();
    }
    return list;
  }

  List<String> get roomOptions {
    final set = <String>{};
    for (final p in _all) {
      final r = p.roomNumber;
      if (r != null && r.isNotEmpty) set.add(r);
    }
    final l = set.toList()..sort();
    return l;
  }

  void start() {
    _sub?.cancel();
    _sub = _service.watchPatients().listen((list) {
      _all = list;
      notifyListeners();
    });
  }

  void setSearch(String v) {
    search = v;
    notifyListeners();
  }

  void setStatusFilter(String v) {
    statusFilter = v;
    notifyListeners();
  }

  void setRoomFilter(String v) {
    roomFilter = v;
    notifyListeners();
  }

  void setDeliveryFilter(String v) {
    deliveryFilter = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

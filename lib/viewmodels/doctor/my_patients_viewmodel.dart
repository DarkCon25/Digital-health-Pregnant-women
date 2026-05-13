import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/patient_model.dart';
import '../../services/doctor_service.dart';

class MyPatientsViewModel extends ChangeNotifier {
  MyPatientsViewModel(this._service);

  final DoctorService _service;

  List<PatientModel> patients = [];
  String searchQuery = '';
  String roomFilter = '';
  /// Empty string = no filter.
  String statusFilter = '';
  int pageIndex = 0;
  static const int pageSize = 8;

  StreamSubscription<List<PatientModel>>? _sub;

  void start(String doctorId) {
    _sub?.cancel();
    _sub = _service.watchPatientsForDoctor(doctorId).listen((list) {
      patients = list;
      notifyListeners();
    });
  }

  List<PatientModel> get filtered {
    var list = patients;
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.fullName.toLowerCase().contains(q) ||
              p.uid.toLowerCase().contains(q) ||
              (p.email.toLowerCase().contains(q)) ||
              (p.roomNumber?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    if (roomFilter.isNotEmpty) {
      list = list.where((p) => p.roomNumber == roomFilter).toList();
    }
    if (statusFilter.isNotEmpty) {
      list = list
          .where(
            (p) => p.status.toLowerCase() == statusFilter.toLowerCase(),
          )
          .toList();
    }
    return list;
  }

  int get pageCount {
    final n = filtered.length;
    if (n == 0) return 1;
    return (n + pageSize - 1) ~/ pageSize;
  }

  List<PatientModel> get pagedPatients {
    final f = filtered;
    if (f.isEmpty) return [];
    final pc = pageCount;
    final safe = pageIndex.clamp(0, pc - 1);
    final start = safe * pageSize;
    final end = (start + pageSize).clamp(0, f.length);
    return f.sublist(start, end);
  }

  void setPage(int index) {
    if (index < 0 || index >= pageCount) return;
    pageIndex = index;
    notifyListeners();
  }

  List<String> get roomOptions {
    final set = <String>{};
    for (final p in patients) {
      final r = p.roomNumber?.trim();
      if (r != null && r.isNotEmpty) set.add(r);
    }
    return set.toList()..sort();
  }

  void setSearch(String value) {
    searchQuery = value;
    pageIndex = 0;
    notifyListeners();
  }

  void setRoomFilter(String room) {
    roomFilter = room;
    pageIndex = 0;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    statusFilter = status ?? '';
    pageIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

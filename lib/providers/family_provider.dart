import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../services/firestore_service.dart';

class FamilyProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  Future<bool> submitFamilyEntry(FamilyModel family) async {
    _setLoading(true);
    try {
      await _firestoreService.createFamily(family);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateFamilyEntry(String id, FamilyModel family) async {
    _setLoading(true);
    try {
      await _firestoreService.updateFamily(id, family);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteFamily(String id) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteFamily(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Stream<List<FamilyModel>> getAllFamilies() {
    return _firestoreService.streamAllFamilies();
  }

  Stream<List<FamilyModel>> getOperatorFamilies(String operatorUid) {
    return _firestoreService.streamOperatorFamilies(operatorUid);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = '';
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _isLoading = false;
    notifyListeners();
  }
}

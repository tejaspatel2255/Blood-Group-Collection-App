import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../services/supabase_service.dart';

class FamilyProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<FamilyModel> _families = [];
  bool _isLoading = false;
  String _error = '';

  List<FamilyModel> get families => _families;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadFamilies() async {
    _setLoading(true);
    try {
      _families = await _supabaseService.getFamilies();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadFamiliesByOperator(String operatorId) async {
    _setLoading(true);
    try {
      _families = await _supabaseService.getFamiliesByOperator(operatorId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> searchFamilies(String query) async {
    _setLoading(true);
    try {
      _families = await _supabaseService.searchFamilies(query);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> addFamily(FamilyModel family) async {
    _setLoading(true);
    try {
      await _supabaseService.createFamily(family);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateFamily(FamilyModel family) async {
    _setLoading(true);
    try {
      await _supabaseService.updateFamily(family);
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
      await _supabaseService.deleteFamily(id);
      _families.removeWhere((f) => f.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
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

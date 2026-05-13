import 'package:flutter/material.dart';
import '../models/family_model.dart';
import '../services/supabase_service.dart';
import '../core/utils/app_error.dart';

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
      _setError(e);
    }
  }

  Future<void> loadFamiliesByOperator(String operatorId) async {
    _setLoading(true);
    try {
      _families = await _supabaseService.getFamiliesByOperator(operatorId);
      _setLoading(false);
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> searchFamilies(String query) async {
    _setLoading(true);
    try {
      _families = await _supabaseService.searchFamilies(query);
      _setLoading(false);
    } catch (e) {
      _setError(e);
    }
  }

  Future<bool> addFamily(FamilyModel family) async {
    _setLoading(true);
    try {
      await _supabaseService.createFamily(family);
      // Auto-refresh based on role/context (Admin sees all, Operator sees theirs)
      // For simplicity, we'll let the UI decide or just load all if it's admin.
      // But typically we want to refresh the current view.
      if (family.createdBy.isNotEmpty) {
        await loadFamiliesByOperator(family.createdBy);
      } else {
        await loadFamilies();
      }
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> updateFamily(FamilyModel family) async {
    _setLoading(true);
    try {
      await _supabaseService.updateFamily(family);
      if (family.createdBy.isNotEmpty) {
        await loadFamiliesByOperator(family.createdBy);
      } else {
        await loadFamilies();
      }
      return true;
    } catch (e) {
      _setError(e);
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
      _setError(e);
      return false;
    }
  }

  List<Map<String, dynamic>> _operators = [];
  List<Map<String, dynamic>> get operators => _operators;

  Future<void> loadOperators() async {
    try {
      _operators = await _supabaseService.getOperators();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading operators: $e');
    }
  }

  Future<void> searchFamiliesForOperator(String query, String operatorId) async {
    _setLoading(true);
    try {
      _families = await _supabaseService.searchFamiliesForOperator(query, operatorId);
      _setLoading(false);
    } catch (e) {
      _setError(e);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = '';
    notifyListeners();
  }

  void _setError(dynamic e) {
    _error = AppError.friendly(e);
    _isLoading = false;
    notifyListeners();
  }
}

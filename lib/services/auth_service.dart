import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { admin, operator, hof, unauthenticated }

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Helper to hash password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Admin Login
  Future<UserRole> loginAdmin(String email, String password) async {
    try {
      // 1. Sign in with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      
      if (response.user != null) {
        // 2. Check if the user has the 'admin' role in the operators table
        final adminData = await _supabase
            .from('operators')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle();
            
        if (adminData != null && adminData['role'] == 'admin') {
          return UserRole.admin;
        } else {
          // If not an admin, sign them out
          await logout();
          throw Exception('Access denied: You do not have administrator privileges.');
        }
      }
      return UserRole.unauthenticated;
    } on AuthException catch (e) {
      throw Exception('Admin login failed: ${e.message}');
    } catch (e) {
      throw Exception('Admin login failed: ${e.toString()}');
    }
  }

  // Operator Login
  Future<UserRole> loginOperator(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (response.user != null) {
        return UserRole.operator;
      }
      return UserRole.unauthenticated;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        throw Exception('Email not confirmed. Please disable "Confirm email" in Supabase Auth settings or click the confirmation link.');
      }
      throw Exception('Operator login failed: ${e.message}');
    } catch (e) {
      throw Exception('Operator login failed: ${e.toString()}');
    }
  }

  // Operator Signup
  Future<AuthResponse> signupOperator(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(email: email, password: password);
      
      if (response.user != null) {
        // Insert into operators table
        await _supabase.from('operators').insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'entries_count': 0,
        });
      }
      return response;
    } catch (e) {
      throw Exception('Operator signup failed: ${e.toString()}');
    }
  }

  // HOF Login
  Future<Map<String, dynamic>?> loginHOF(String mobileNumber, String password) async {
    try {
      final response = await _supabase
          .from('families')
          .select('*, family_members(*)')
          .eq('login_username', mobileNumber)
          .eq('login_password', hashPassword(password))
          .maybeSingle();

      if (response != null) {
        return {
          'role': UserRole.hof,
          'familyId': response['id'],
          'familyData': response,
        };
      }
      return null;
    } catch (e) {
      throw Exception('HOF login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppError {
  /// Returns a human-friendly error message based on the exception type.
  /// Logs the full error to the console in debug mode.
  static String friendly(dynamic e) {
    debugPrint('ERROR: $e');
    
    if (e is AuthException) {
      if (e.message.contains('Invalid login credentials')) {
        return 'Incorrect email or password. Please try again.';
      }
      if (e.message.contains('Email not confirmed')) {
        return 'Email not confirmed. Please check your inbox.';
      }
      return e.message;
    }

    if (e is PostgrestException) {
      if (e.message.contains('row level security')) {
        return 'Permission denied. (Database RLS Policy Error)';
      }
      return 'Database error: ${e.message}';
    }

    final errorStr = e.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('socketexception')) {
      return 'Connection failed. Please check your internet.';
    }
    
    if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again later.';
    }

    // Default friendly message
    return 'Something went wrong. Please try again.';
  }
}

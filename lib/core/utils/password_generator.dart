import 'package:intl/intl.dart';

class PasswordGenerator {
  /// Generates a password using:
  /// 1. First name in UPPERCASE (extract first word only)
  /// 2. DOB in ddmmyyyy format
  /// Example: Name = "Ramesh Patel", DOB = 15/08/1975 -> RAMESH15081975
  static String generatePassword(String fullName, DateTime dob) {
    if (fullName.trim().isEmpty) return '';
    
    // Extract first name and uppercase
    String firstName = fullName.trim().split(' ').first.toUpperCase();
    
    // Format DOB as ddmmyyyy
    String formattedDob = DateFormat('ddMMyyyy').format(dob);
    
    return '$firstName$formattedDob';
  }
}

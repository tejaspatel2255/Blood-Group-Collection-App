import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, operator, hof, unauthenticated }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin Login
  Future<UserRole> loginAdmin(String email, String password) async {
    try {
      if (email == 'admin@familyregistry.com' && password == 'Admin@2024') {
        // Admin@2024 is hardcoded for admin entry as per requirements.
        // If Admin is configured in Firebase Auth, this will log them in.
        try {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
        } catch (_) {
          // If admin doesn't exist in Firebase Auth yet, bypass if hardcoded matches
        }
        return UserRole.admin;
      }
      return UserRole.unauthenticated;
    } catch (e) {
      throw Exception('Admin login failed: ${e.toString()}');
    }
  }

  // Operator Login
  Future<UserRole> loginOperator(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        return UserRole.operator;
      }
      return UserRole.unauthenticated;
    } catch (e) {
      throw Exception('Operator login failed: ${e.toString()}');
    }
  }

  // Operator Signup
  Future<UserCredential> signupOperator(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _firestore.collection('operators').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'entriesCount': 0,
        });
      }
      return credential;
    } catch (e) {
      throw Exception('Operator signup failed: ${e.toString()}');
    }
  }

  // HOF Login
  Future<Map<String, dynamic>?> loginHOF(String mobileNumber, String password) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('families')
          .where('loginCredentials.username', isEqualTo: mobileNumber)
          .where('loginCredentials.password', isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return {
          'role': UserRole.hof,
          'familyId': query.docs.first.id,
          'familyData': query.docs.first.data(),
        };
      }
      return null;
    } catch (e) {
      throw Exception('HOF login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

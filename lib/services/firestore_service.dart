import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService() {
    // Enable offline persistence
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Generate next serial number
  Future<String> _generateSerialNumber() async {
    final docRef = _db.collection('metadata').doc('counters');
    
    return await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'familyCount': 1});
        return 'FAM-0001';
      }
      
      int currentCount = snapshot.data()?['familyCount'] ?? 0;
      int newCount = currentCount + 1;
      transaction.update(docRef, {'familyCount': newCount});
      
      return 'FAM-${newCount.toString().padLeft(4, '0')}';
    });
  }

  // Create Family Entry
  Future<String> createFamily(FamilyModel family) async {
    try {
      final serialNumber = await _generateSerialNumber();
      family.serialNumber = serialNumber;
      
      final docRef = await _db.collection('families').add(family.toMap());
      
      // Update operator entry count
      if (family.createdBy.isNotEmpty) {
        await _db.collection('operators').doc(family.createdBy).update({
          'entriesCount': FieldValue.increment(1)
        });
      }
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create family: $e');
    }
  }

  // Update Family Entry
  Future<void> updateFamily(String id, FamilyModel family) async {
    try {
      family.updatedAt = DateTime.now();
      await _db.collection('families').doc(id).update(family.toMap());
    } catch (e) {
      throw Exception('Failed to update family: $e');
    }
  }

  // Delete Family Entry
  Future<void> deleteFamily(String id) async {
    try {
      await _db.collection('families').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete family: $e');
    }
  }

  // Get Family by ID
  Future<FamilyModel?> getFamilyById(String id) async {
    try {
      final doc = await _db.collection('families').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return FamilyModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch family: $e');
    }
  }

  // Stream all families (for Admin)
  Stream<List<FamilyModel>> streamAllFamilies() {
    return _db.collection('families')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FamilyModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream operator's families
  Stream<List<FamilyModel>> streamOperatorFamilies(String operatorUid) {
    return _db.collection('families')
        .where('createdBy', isEqualTo: operatorUid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
            .map((doc) => FamilyModel.fromMap(doc.data(), doc.id))
            .toList();
          // Sort locally to avoid requiring a composite index in Firestore
          list.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return list;
        });
  }
}

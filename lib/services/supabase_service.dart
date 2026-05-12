import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/family_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all families (for Admin)
  Future<List<FamilyModel>> getFamilies() async {
    final response = await _supabase
        .from('families')
        .select('*, family_members(*)')
        .order('created_at', ascending: false);
    
    return (response as List).map((map) => FamilyModel.fromMap(map)).toList();
  }

  // Get families by operator
  Future<List<FamilyModel>> getFamiliesByOperator(String operatorId) async {
    final response = await _supabase
        .from('families')
        .select('*, family_members(*)')
        .eq('created_by', operatorId)
        .order('created_at', ascending: false);
    
    return (response as List).map((map) => FamilyModel.fromMap(map)).toList();
  }

  // Get single family by ID
  Future<FamilyModel?> getFamilyById(String id) async {
    final response = await _supabase
        .from('families')
        .select('*, family_members(*)')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return FamilyModel.fromMap(response);
  }

  // Generate next serial number (FAM-0001 format)
  Future<String> _generateSerialNumber() async {
    final response = await _supabase
        .from('families')
        .select('id')
        .count(CountOption.exact);
        
    final count = response.count;
    return 'FAM-${(count + 1).toString().padLeft(4, '0')}';
  }

  // Create Family
  Future<void> createFamily(FamilyModel family) async {
    try {
      family.serialNumber = await _generateSerialNumber();
      
      // 1. Insert Family
      final familyMap = family.toMap();
      familyMap.remove('id'); // DB will generate UUID
      
      final insertedFamily = await _supabase
          .from('families')
          .insert(familyMap)
          .select('id')
          .single();
          
      final familyId = insertedFamily['id'];

      // 2. Insert Members
      if (family.members.isNotEmpty) {
        final membersList = family.members.map((m) {
          final mMap = m.toMap();
          mMap.remove('id');
          mMap['family_id'] = familyId;
          return mMap;
        }).toList();
        
        await _supabase.from('family_members').insert(membersList);
      }
      
      // 3. Update operator entry count
      if (family.createdBy.isNotEmpty) {
        // We do a simple RPC or manual increment. 
        // For simplicity, we'll fetch current and update. 
        // In a real app, an RPC (Stored Procedure) is better for concurrency.
        final op = await _supabase.from('operators').select('entries_count').eq('id', family.createdBy).maybeSingle();
        if (op != null) {
          int count = op['entries_count'] ?? 0;
          await _supabase.from('operators').update({'entries_count': count + 1}).eq('id', family.createdBy);
        }
      }
    } catch (e) {
      throw Exception('Failed to create family: $e');
    }
  }

  // Update Family
  Future<void> updateFamily(FamilyModel family) async {
    if (family.id == null) throw Exception('Family ID is required for update');
    
    try {
      family.updatedAt = DateTime.now();
      
      final familyMap = family.toMap();
      
      await _supabase.from('families').update(familyMap).eq('id', family.id!);
      
      // For members: Delete all existing and re-insert 
      // (This is simpler than diffing, assuming it's a small list)
      await _supabase.from('family_members').delete().eq('family_id', family.id!);
      
      if (family.members.isNotEmpty) {
        final membersList = family.members.map((m) {
          final mMap = m.toMap();
          mMap.remove('id'); // let DB generate
          mMap['family_id'] = family.id;
          return mMap;
        }).toList();
        
        await _supabase.from('family_members').insert(membersList);
      }
    } catch (e) {
      throw Exception('Failed to update family: $e');
    }
  }

  // Delete Family
  Future<void> deleteFamily(String id) async {
    try {
      // Deleting the family will cascade delete members if the DB schema is set up with ON DELETE CASCADE.
      // If not, we should delete members first:
      await _supabase.from('family_members').delete().eq('family_id', id);
      await _supabase.from('families').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete family: $e');
    }
  }

  // Upload Photo to Supabase Storage
  Future<String> uploadPhoto(Uint8List imageBytes, String fileName) async {
    try {
      final String path = 'profiles/$fileName';
      await _supabase.storage.from('photos').uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
          );
      
      return _supabase.storage.from('photos').getPublicUrl(path);
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Search Families
  Future<List<FamilyModel>> searchFamilies(String query) async {
    if (query.isEmpty) return getFamilies();
    
    // Search across name, mobile, and serial number
    final response = await _supabase
        .from('families')
        .select('*, family_members(*)')
        .or('hof_name.ilike.%$query%,mobile.ilike.%$query%,serial_number.ilike.%$query%')
        .order('created_at', ascending: false);
        
    return (response as List).map((map) => FamilyModel.fromMap(map)).toList();
  }
}

import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/family_model.dart';
import '../models/member_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Helper to hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

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

  // Generate next serial number (using RPC)
  Future<String> _generateSerialNumber() async {
    final response = await _supabase.rpc('generate_family_serial');
    return response.toString();
  }

  // Create Family
  Future<void> createFamily(FamilyModel family) async {
    try {
      family.serialNumber = await _generateSerialNumber();
      
      // Hash password before storing
      family.loginPassword = _hashPassword(family.loginPassword);
      
      // 1. Insert Family
      final familyMap = family.toMap();
      familyMap.remove('id'); // DB will generate UUID
      familyMap.remove('family_members'); // This is a virtual field for drafts/UI
      
      final insertedFamily = await _supabase
          .from('families')
          .insert(familyMap)
          .select('id')
          .single();
          
      final familyId = insertedFamily['id'];

      // 2. Insert Members (with photo upload)
      if (family.members.isNotEmpty) {
        final membersList = <Map<String, dynamic>>[];
        for (final m in family.members) {
          final mMap = m.toMap();
          mMap.remove('id');
          mMap.remove('family_members');
          mMap['family_id'] = familyId;
          // Upload member photo if a local image was selected
          if (m.localPhotoBytes != null) {
            try {
              final memberPhotoUrl = await uploadPhoto(
                m.localPhotoBytes!,
                'member_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
              mMap['photo_url'] = memberPhotoUrl;
            } catch (_) {
              // Keep existing or empty URL if upload fails
            }
          }
          membersList.add(mMap);
        }
        await _supabase.from('family_members').insert(membersList);
      }
      
      // 3. Update operator entry count using RPC
      if (family.createdBy.isNotEmpty) {
        await _supabase.rpc('increment_operator_count', params: {'operator_id': family.createdBy});
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
      
      // Hash password if it seems to be in plain text (length check or other heuristic)
      // For now, we assume if it's updated, it's passed in plain text.
      // But in a real app, we might check if it's already a 64-char hex string (SHA-256).
      if (family.loginPassword.length < 64) {
        family.loginPassword = _hashPassword(family.loginPassword);
      }
      
      final familyMap = family.toMap();
      familyMap.remove('family_members'); // This is a virtual field for drafts/UI
      
      await _supabase.from('families').update(familyMap).eq('id', family.id!);
      
      // Member Diff Logic
      // 1. Get existing members from DB
      final existingMembersData = await _supabase.from('family_members').select('id').eq('family_id', family.id!);
      final existingIds = (existingMembersData as List).map((m) => m['id'].toString()).toSet();
      
      final currentIds = family.members.where((m) => m.id != null).map((m) => m.id!).toSet();
      
      // 2. Members to delete (In DB but not in new list)
      final idsToDelete = existingIds.difference(currentIds);
      if (idsToDelete.isNotEmpty) {
        await _supabase.from('family_members').delete().inFilter('id', idsToDelete.toList());
      }
      
      // 3. Update existing and Insert new
      for (var member in family.members) {
        final mMap = member.toMap();
        mMap.remove('family_members');
        mMap['family_id'] = family.id;
        
        // Upload member photo if a NEW local image was selected
        if (member.localPhotoBytes != null) {
          try {
            final memberPhotoUrl = await uploadPhoto(
              member.localPhotoBytes!,
              'member_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            mMap['photo_url'] = memberPhotoUrl;
          } catch (_) {
            // Keep existing URL if upload fails
          }
        }
        
        if (member.id != null && existingIds.contains(member.id)) {
          // Update
          await _supabase.from('family_members').update(mMap).eq('id', member.id!);
        } else {
          // Insert new
          mMap.remove('id');
          await _supabase.from('family_members').insert(mMap);
        }
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

  // Search Families (Global)
  Future<List<FamilyModel>> searchFamilies(String query) async {
    final sanitizedQuery = query.trim().length > 100 ? query.trim().substring(0, 100) : query.trim();
    
    if (sanitizedQuery.isEmpty) return getFamilies();
    
    final response = await _supabase
        .from('families')
        .select('*, family_members(*)')
        .or('hof_name.ilike.%$sanitizedQuery%,mobile.ilike.%$sanitizedQuery%,serial_number.ilike.%$sanitizedQuery%')
        .order('created_at', ascending: false);
        
    return (response as List).map((map) => FamilyModel.fromMap(map)).toList();
  }

  // Search Families for a specific Operator
  Future<List<FamilyModel>> searchFamiliesForOperator(String query, String operatorId) async {
    final sanitizedQuery = query.trim().length > 100 ? query.trim().substring(0, 100) : query.trim();
    
    if (sanitizedQuery.isEmpty) return getFamiliesByOperator(operatorId);
    
    final response = await _supabase
        .from('families')
        .select('*, family_members(*)')
        .eq('created_by', operatorId)
        .or('hof_name.ilike.%$sanitizedQuery%,mobile.ilike.%$sanitizedQuery%,serial_number.ilike.%$sanitizedQuery%')
        .order('created_at', ascending: false);
        
    return (response as List).map((map) => FamilyModel.fromMap(map)).toList();
  }

  // Get all operators (for Admin filter)
  Future<List<Map<String, dynamic>>> getOperators() async {
    final response = await _supabase
        .from('operators')
        .select('id, name, email')
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }
}

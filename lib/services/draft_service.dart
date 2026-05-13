import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_model.dart';

class DraftService {
  static const String _draftKey = 'family_registration_draft';

  Future<void> saveDraft(FamilyModel family, Uint8List? photoBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {
      'family': family.toMap(),
      if (photoBytes != null) 'photo': base64Encode(photoBytes),
    };
    await prefs.setString(_draftKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_draftKey);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final family = FamilyModel.fromMap(data['family']);
      Uint8List? photo;
      if (data['photo'] != null) {
        photo = base64Decode(data['photo']);
      }
      return {
        'family': family,
        'photo': photo,
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}

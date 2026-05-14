import 'dart:typed_data';
import '../core/utils/age_calculator.dart';

class MemberModel {
  String? id;
  String? familyId;
  String name;
  String relationship;
  DateTime? dob;
  int age;
  String gender;
  String bloodGroup;
  String maritalStatus;
  String area;
  String education;
  String occupation;
  String mobile;
  String mobileCountryCode;
  String photoUrl;
  Uint8List? localPhotoBytes;

  MemberModel({
    this.id,
    this.familyId,
    required this.name,
    required this.relationship,
    this.dob,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.maritalStatus,
    this.area = '',
    required this.education,
    required this.occupation,
    this.mobile = '',
    this.mobileCountryCode = '+91',
    this.photoUrl = '',
    this.localPhotoBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (familyId != null) 'family_id': familyId,
      'name': name,
      'relationship': relationship,
      'dob': dob?.toIso8601String(),
      // 'age' is removed as it's a computed field
      'gender': gender,
      'blood_group': bloodGroup,
      'marital_status': maritalStatus,
      'area': area,
      'education': education,
      'occupation': occupation,
      'mobile': mobile,
      'photo_url': photoUrl,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    final DateTime? birthDate = map['dob'] != null ? DateTime.tryParse(map['dob']) : null;
    return MemberModel(
      id: map['id']?.toString(),
      familyId: map['family_id']?.toString(),
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      dob: birthDate,
      age: birthDate != null ? AgeCalculator.calculateAge(birthDate) : (map['age'] ?? 0),
      gender: map['gender'] ?? '',
      bloodGroup: map['blood_group'] ?? '',
      maritalStatus: map['marital_status'] ?? '',
      area: map['area'] ?? '',
      education: map['education'] ?? '',
      occupation: map['occupation'] ?? '',
      mobile: map['mobile'] ?? '',
      mobileCountryCode: map['mobile_country_code'] ?? '+91',
      photoUrl: map['photo_url'] ?? '',
    );
  }

  MemberModel copyWith({
    String? id,
    String? familyId,
    String? name,
    String? relationship,
    DateTime? dob,
    int? age,
    String? gender,
    String? bloodGroup,
    String? maritalStatus,
    String? area,
    String? education,
    String? occupation,
    String? mobile,
    String? mobileCountryCode,
    String? photoUrl,
    Uint8List? localPhotoBytes,
  }) {
    return MemberModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      area: area ?? this.area,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      mobile: mobile ?? this.mobile,
      mobileCountryCode: mobileCountryCode ?? this.mobileCountryCode,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoBytes: localPhotoBytes ?? this.localPhotoBytes,
    );
  }
}

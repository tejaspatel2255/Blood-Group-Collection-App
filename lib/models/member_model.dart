import 'dart:typed_data';

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
  String education;
  String occupation;
  String mobile;
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
    required this.education,
    required this.occupation,
    this.mobile = '',
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
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'marital_status': maritalStatus,
      'education': education,
      'occupation': occupation,
      'mobile': mobile,
      'photo_url': photoUrl,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id']?.toString(),
      familyId: map['family_id']?.toString(),
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      bloodGroup: map['blood_group'] ?? '',
      maritalStatus: map['marital_status'] ?? '',
      education: map['education'] ?? '',
      occupation: map['occupation'] ?? '',
      mobile: map['mobile'] ?? '',
      photoUrl: map['photo_url'] ?? '',
    );
  }
}

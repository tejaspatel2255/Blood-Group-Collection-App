import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  String id;
  String firstName;
  String lastName;
  String relationWithHOF;
  DateTime? dob;
  int age;
  String bloodGroup;
  String maritalStatus;
  String education;
  String occupation;
  String photoUrl;
  String? localPhotoPath;

  MemberModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.relationWithHOF,
    this.dob,
    required this.age,
    required this.bloodGroup,
    required this.maritalStatus,
    required this.education,
    required this.occupation,
    this.photoUrl = '',
    this.localPhotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'relationWithHOF': relationWithHOF,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'age': age,
      'bloodGroup': bloodGroup,
      'maritalStatus': maritalStatus,
      'education': education,
      'occupation': occupation,
      'photoUrl': photoUrl,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      relationWithHOF: map['relationWithHOF'] ?? '',
      dob: map['dob'] != null ? (map['dob'] as Timestamp).toDate() : null,
      age: map['age'] ?? 0,
      bloodGroup: map['bloodGroup'] ?? '',
      maritalStatus: map['maritalStatus'] ?? '',
      education: map['education'] ?? '',
      occupation: map['occupation'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }
}

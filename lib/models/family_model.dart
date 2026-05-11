import 'package:cloud_firestore/cloud_firestore.dart';
import 'member_model.dart';

class HeadOfFamily {
  String firstName;
  String middleName;
  String lastName;
  DateTime? dob;
  int age;
  String bloodGroup;
  String maritalStatus;
  String education;
  String occupation;
  String photoUrl;
  String village;
  String taluka;
  String district;
  String state;
  String pincode;
  String mobileNumber;
  String email;

  HeadOfFamily({
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    this.dob,
    required this.age,
    required this.bloodGroup,
    required this.maritalStatus,
    this.education = '',
    this.occupation = '',
    this.photoUrl = '',
    this.village = '',
    this.taluka = '',
    this.district = '',
    this.state = '',
    this.pincode = '',
    this.mobileNumber = '',
    this.email = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'age': age,
      'bloodGroup': bloodGroup,
      'maritalStatus': maritalStatus,
      'education': education,
      'occupation': occupation,
      'photoUrl': photoUrl,
      'village': village,
      'taluka': taluka,
      'district': district,
      'state': state,
      'pincode': pincode,
      'mobileNumber': mobileNumber,
      'email': email,
    };
  }

  factory HeadOfFamily.fromMap(Map<String, dynamic> map) {
    return HeadOfFamily(
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      dob: map['dob'] != null ? (map['dob'] as Timestamp).toDate() : null,
      age: map['age'] ?? 0,
      bloodGroup: map['bloodGroup'] ?? '',
      maritalStatus: map['maritalStatus'] ?? '',
      education: map['education'] ?? '',
      occupation: map['occupation'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      village: map['village'] ?? '',
      taluka: map['taluka'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

class LoginCredentials {
  String username;
  String password;

  LoginCredentials({required this.username, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }

  factory LoginCredentials.fromMap(Map<String, dynamic> map) {
    return LoginCredentials(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }
}

class FamilyModel {
  String? id;
  String serialNumber;
  DateTime? createdAt;
  DateTime? updatedAt;
  String createdBy;
  HeadOfFamily headOfFamily;
  List<MemberModel> members;
  LoginCredentials? loginCredentials;

  FamilyModel({
    this.id,
    required this.serialNumber,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.headOfFamily,
    required this.members,
    this.loginCredentials,
  });

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'headOfFamily': headOfFamily.toMap(),
      'members': members.map((e) => e.toMap()).toList(),
      if (loginCredentials != null) 'loginCredentials': loginCredentials!.toMap(),
    };
  }

  factory FamilyModel.fromMap(Map<String, dynamic> map, String docId) {
    return FamilyModel(
      id: docId,
      serialNumber: map['serialNumber'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      createdBy: map['createdBy'] ?? '',
      headOfFamily: HeadOfFamily.fromMap(map['headOfFamily'] ?? {}),
      members: map['members'] != null
          ? List<MemberModel>.from(map['members'].map((x) => MemberModel.fromMap(x)))
          : [],
      loginCredentials: map['loginCredentials'] != null 
          ? LoginCredentials.fromMap(map['loginCredentials'])
          : null,
    );
  }
}

import 'member_model.dart';

class FamilyModel {
  String? id;
  String serialNumber;
  DateTime? createdAt;
  DateTime? updatedAt;
  String createdBy;
  
  // HOF Details
  String hofName;
  String fatherHusbandName;
  String motherName;
  DateTime? dob;
  int age;
  String gender;
  String bloodGroup;
  String maritalStatus;
  String education;
  String educationOther;
  String occupation;
  String occupationOther;
  String annualIncome;
  String photoUrl;
  
  // Address & Contact
  String currentAddress;
  String nativePlace;
  String city;
  String state;
  String pinCode;
  String mobile;
  String whatsapp;
  String email;
  
  // Login
  String loginUsername;
  String loginPassword;
  
  // Relations
  List<MemberModel> members;

  FamilyModel({
    this.id,
    required this.serialNumber,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.hofName,
    this.fatherHusbandName = '',
    this.motherName = '',
    this.dob,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.maritalStatus,
    this.education = '',
    this.educationOther = '',
    this.occupation = '',
    this.occupationOther = '',
    this.annualIncome = '',
    this.photoUrl = '',
    this.currentAddress = '',
    this.nativePlace = '',
    this.city = '',
    this.state = '',
    this.pinCode = '',
    required this.mobile,
    this.whatsapp = '',
    this.email = '',
    required this.loginUsername,
    required this.loginPassword,
    this.members = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'serial_number': serialNumber,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'created_by': createdBy,
      'hof_name': hofName,
      'father_husband_name': fatherHusbandName,
      'mother_name': motherName,
      'dob': dob?.toIso8601String(),
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'marital_status': maritalStatus,
      'education': education,
      'education_other': educationOther,
      'occupation': occupation,
      'occupation_other': occupationOther,
      'annual_income': annualIncome,
      'photo_url': photoUrl,
      'current_address': currentAddress,
      'native_place': nativePlace,
      'city': city,
      'state': state,
      'pin_code': pinCode,
      'mobile': mobile,
      'whatsapp': whatsapp,
      'email': email,
      'login_username': loginUsername,
      'login_password': loginPassword,
    };
  }

  factory FamilyModel.fromMap(Map<String, dynamic> map) {
    return FamilyModel(
      id: map['id']?.toString(),
      serialNumber: map['serial_number'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
      createdBy: map['created_by']?.toString() ?? '',
      hofName: map['hof_name'] ?? '',
      fatherHusbandName: map['father_husband_name'] ?? '',
      motherName: map['mother_name'] ?? '',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob']) : null,
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      bloodGroup: map['blood_group'] ?? '',
      maritalStatus: map['marital_status'] ?? '',
      education: map['education'] ?? '',
      educationOther: map['education_other'] ?? '',
      occupation: map['occupation'] ?? '',
      occupationOther: map['occupation_other'] ?? '',
      annualIncome: map['annual_income'] ?? '',
      photoUrl: map['photo_url'] ?? '',
      currentAddress: map['current_address'] ?? '',
      nativePlace: map['native_place'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pinCode: map['pin_code'] ?? '',
      mobile: map['mobile'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      email: map['email'] ?? '',
      loginUsername: map['login_username'] ?? '',
      loginPassword: map['login_password'] ?? '',
      members: map['family_members'] != null
          ? List<MemberModel>.from(
              (map['family_members'] as List).map((x) => MemberModel.fromMap(x)))
          : [],
    );
  }
}

import 'member_model.dart';
import '../core/utils/age_calculator.dart';

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
  String mobileCountryCode;
  String whatsapp;
  String whatsappCountryCode;
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
    this.mobileCountryCode = '+91',
    this.whatsapp = '',
    this.whatsappCountryCode = '+91',
    this.email = '',
    required this.loginUsername,
    required this.loginPassword,
    List<MemberModel>? members,
  }) : this.members = members ?? [];

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
      // 'age' is removed as it's a computed field
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
      'family_members': members.map((m) => m.toMap()).toList(),
    };
  }

  factory FamilyModel.fromMap(Map<String, dynamic> map) {
    final DateTime? birthDate = map['dob'] != null ? DateTime.tryParse(map['dob']) : null;
    return FamilyModel(
      id: map['id']?.toString(),
      serialNumber: map['serial_number'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null,
      createdBy: map['created_by']?.toString() ?? '',
      hofName: map['hof_name'] ?? '',
      fatherHusbandName: map['father_husband_name'] ?? '',
      motherName: map['mother_name'] ?? '',
      dob: birthDate,
      age: birthDate != null ? AgeCalculator.calculateAge(birthDate) : (map['age'] ?? 0),
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
      mobileCountryCode: map['mobile_country_code'] ?? '+91',
      whatsapp: map['whatsapp'] ?? '',
      whatsappCountryCode: map['whatsapp_country_code'] ?? '+91',
      email: map['email'] ?? '',
      loginUsername: map['login_username'] ?? '',
      loginPassword: map['login_password'] ?? '',
      members: map['family_members'] != null
          ? List<MemberModel>.from(
              (map['family_members'] as List).map((x) => MemberModel.fromMap(x)))
          : [],
    );
  }

  FamilyModel copyWith({
    String? id,
    String? serialNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? hofName,
    String? fatherHusbandName,
    String? motherName,
    DateTime? dob,
    int? age,
    String? gender,
    String? bloodGroup,
    String? maritalStatus,
    String? education,
    String? educationOther,
    String? occupation,
    String? occupationOther,
    String? annualIncome,
    String? photoUrl,
    String? currentAddress,
    String? nativePlace,
    String? city,
    String? state,
    String? pinCode,
    String? mobile,
    String? mobileCountryCode,
    String? whatsapp,
    String? whatsappCountryCode,
    String? email,
    String? loginUsername,
    String? loginPassword,
    List<MemberModel>? members,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      hofName: hofName ?? this.hofName,
      fatherHusbandName: fatherHusbandName ?? this.fatherHusbandName,
      motherName: motherName ?? this.motherName,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      education: education ?? this.education,
      educationOther: educationOther ?? this.educationOther,
      occupation: occupation ?? this.occupation,
      occupationOther: occupationOther ?? this.occupationOther,
      annualIncome: annualIncome ?? this.annualIncome,
      photoUrl: photoUrl ?? this.photoUrl,
      currentAddress: currentAddress ?? this.currentAddress,
      nativePlace: nativePlace ?? this.nativePlace,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      mobile: mobile ?? this.mobile,
      mobileCountryCode: mobileCountryCode ?? this.mobileCountryCode,
      whatsapp: whatsapp ?? this.whatsapp,
      whatsappCountryCode: whatsappCountryCode ?? this.whatsappCountryCode,
      email: email ?? this.email,
      loginUsername: loginUsername ?? this.loginUsername,
      loginPassword: loginPassword ?? this.loginPassword,
      members: members ?? this.members,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorModel {
  String uid;
  String email;
  String name;
  DateTime? createdAt;
  int entriesCount;

  OperatorModel({
    required this.uid,
    required this.email,
    required this.name,
    this.createdAt,
    this.entriesCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'entriesCount': entriesCount,
    };
  }

  factory OperatorModel.fromMap(Map<String, dynamic> map) {
    return OperatorModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      entriesCount: map['entriesCount'] ?? 0,
    );
  }
}

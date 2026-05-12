class OperatorModel {
  String id;
  String email;
  String name;
  DateTime? createdAt;
  int entriesCount;

  OperatorModel({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt,
    this.entriesCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'entries_count': entriesCount,
    };
  }

  factory OperatorModel.fromMap(Map<String, dynamic> map) {
    return OperatorModel(
      id: map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
      entriesCount: map['entries_count'] ?? 0,
    );
  }
}

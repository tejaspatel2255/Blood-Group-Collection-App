import 'package:flutter/material.dart';
import '../../models/family_model.dart';

class FamilyCard extends StatelessWidget {
  final FamilyModel family;
  final VoidCallback onTap;

  const FamilyCard({super.key, required this.family, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: family.headOfFamily.photoUrl.isNotEmpty
              ? NetworkImage(family.headOfFamily.photoUrl)
              : null,
          child: family.headOfFamily.photoUrl.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text('${family.headOfFamily.firstName} ${family.headOfFamily.lastName}'),
        subtitle: Text('ID: ${family.serialNumber} • Members: ${family.members.length + 1}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

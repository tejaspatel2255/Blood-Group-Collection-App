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
          backgroundImage: family.photoUrl.isNotEmpty
              ? NetworkImage(family.photoUrl)
              : null,
          child: family.photoUrl.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(family.hofName),
        subtitle: Text('ID: ${family.serialNumber} • Members: ${family.members.length + 1}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/family_model.dart';

class FamilyCard extends StatelessWidget {
  final FamilyModel family;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? operatorName;

  const FamilyCard({
    super.key,
    required this.family,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.operatorName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'family_${family.id}',
          child: CircleAvatar(
            radius: 25,
            backgroundImage: family.photoUrl.isNotEmpty
                ? NetworkImage(family.photoUrl)
                : null,
            child: family.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
        ),
        title: Text(
          family.hofName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${family.serialNumber} • Members: ${family.members.length + 1}'),
            if (operatorName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Operator: $operatorName',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            if (onEdit == null && onDelete == null)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

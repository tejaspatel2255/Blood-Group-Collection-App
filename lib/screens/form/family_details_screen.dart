import 'package:flutter/material.dart';
import '../../models/family_model.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class FamilyDetailsScreen extends StatelessWidget {
  final FamilyModel family;

  const FamilyDetailsScreen({super.key, required this.family});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family ${family.serialNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Head of Family'),
            _buildHOFCard(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Contact & Address'),
            _buildInfoRow('Mobile', '+91 ${family.mobile}'),
            if (family.whatsapp.isNotEmpty) _buildInfoRow('WhatsApp', '+91 ${family.whatsapp}'),
            _buildInfoRow('Email', family.email.isNotEmpty ? family.email : 'N/A'),
            _buildInfoRow('Address', '${family.currentAddress}\n${family.city}, ${family.state} - ${family.pinCode}'),
            if (family.nativePlace.isNotEmpty) _buildInfoRow('Native Place', family.nativePlace),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Education & Occupation'),
            _buildInfoRow('Education', family.education == 'Other' ? family.educationOther : family.education),
            _buildInfoRow('Occupation', family.occupation == 'Other' ? family.occupationOther : family.occupation),
            _buildInfoRow('Annual Income', family.annualIncome),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Family Members (${family.members.length})'),
            const SizedBox(height: 8),
            if (family.members.isEmpty)
              const Text('No additional members registered.')
            else
              ...family.members.map((m) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: m.photoUrl.isNotEmpty ? NetworkImage(m.photoUrl) : null,
                    child: m.photoUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(m.name),
                  subtitle: Text('${m.relationship} • ${m.age} yrs • ${m.bloodGroup}'),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHOFCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: family.photoUrl.isNotEmpty ? NetworkImage(family.photoUrl) : null,
              child: family.photoUrl.isEmpty ? const Icon(Icons.person, size: 40) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(family.hofName, style: Theme.of(context).textTheme.titleLarge),
                  if (family.fatherHusbandName.isNotEmpty) Text('C/O: ${family.fatherHusbandName}'),
                  if (family.motherName.isNotEmpty) Text('Mother: ${family.motherName}'),
                  const SizedBox(height: 4),
                  Text('Age: ${family.age} • Blood Group: ${family.bloodGroup}'),
                  Text('DOB: ${family.dob != null ? DateFormat('dd/MM/yyyy').format(family.dob!) : 'N/A'}'),
                  Text('Gender: ${family.gender} • Marital: ${family.maritalStatus}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

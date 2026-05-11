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
            _buildInfoRow('Mobile', '+91 ${family.headOfFamily.mobileNumber}'),
            _buildInfoRow('Email', family.headOfFamily.email.isNotEmpty ? family.headOfFamily.email : 'N/A'),
            _buildInfoRow('Address', '${family.headOfFamily.village}, ${family.headOfFamily.taluka}, ${family.headOfFamily.district}, ${family.headOfFamily.state} - ${family.headOfFamily.pincode}'),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Education & Occupation'),
            _buildInfoRow('Education', family.headOfFamily.education),
            _buildInfoRow('Occupation', family.headOfFamily.occupation),
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
                  title: Text('${m.firstName} ${m.lastName}'),
                  subtitle: Text('${m.relationWithHOF} • ${m.age} yrs • ${m.bloodGroup}'),
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
    final hof = family.headOfFamily;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: hof.photoUrl.isNotEmpty ? NetworkImage(hof.photoUrl) : null,
              child: hof.photoUrl.isEmpty ? const Icon(Icons.person, size: 40) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${hof.firstName} ${hof.lastName}', style: Theme.of(context).textTheme.titleLarge),
                  Text('Age: ${hof.age} • Blood Group: ${hof.bloodGroup}'),
                  Text('DOB: ${hof.dob != null ? DateFormat('dd/MM/yyyy').format(hof.dob!) : 'N/A'}'),
                  Text('Marital Status: ${hof.maritalStatus}'),
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
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

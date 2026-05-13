import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/family_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_error.dart';

class FamilyDetailsScreen extends StatelessWidget {
  final FamilyModel family;

  const FamilyDetailsScreen({super.key, required this.family});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text("Are you sure you want to delete ${family.hofName}'s record? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<FamilyProvider>().deleteFamily(family.id!);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record deleted successfully')));
                context.pop();
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<FamilyProvider>().error)));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool canDelete = authProvider.role == UserRole.admin || authProvider.role == UserRole.operator;

    return Scaffold(
      appBar: AppBar(
        title: Text('Family ${family.serialNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/family/edit', extra: family),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
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
              ...family.members.map((m) => _MemberCard(member: m)),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Text(family.hofName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  if (family.fatherHusbandName.isNotEmpty) Text('C/O: ${family.fatherHusbandName}', style: const TextStyle(color: AppColors.textSecondary)),
                  if (family.motherName.isNotEmpty) Text('Mother: ${family.motherName}', style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip('Age: ${family.age}'),
                      _buildChip('Group: ${family.bloodGroup}'),
                    ],
                  ),
                  const SizedBox(height: 4),
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

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
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

class _MemberCard extends StatefulWidget {
  final dynamic member; // Using dynamic to avoid explicit MemberModel cast if not needed, but better cast to MemberModel
  const _MemberCard({required this.member});

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: m.photoUrl.isNotEmpty ? NetworkImage(m.photoUrl) : null,
                    child: m.photoUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${m.relationship} • ${m.age} yrs • ${m.bloodGroup}', style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 24),
                _buildMemberDetail('Date of Birth', m.dob != null ? DateFormat('dd/MM/yyyy').format(m.dob!) : 'N/A'),
                _buildMemberDetail('Gender', m.gender),
                _buildMemberDetail('Marital Status', m.maritalStatus),
                _buildMemberDetail('Education', m.education),
                _buildMemberDetail('Occupation', m.occupation),
                if (m.mobile.isNotEmpty) _buildMemberDetail('Mobile', '+91 ${m.mobile}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

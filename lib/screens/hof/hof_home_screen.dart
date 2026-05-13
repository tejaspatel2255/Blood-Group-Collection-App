import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/family_model.dart';
import '../../core/constants/app_colors.dart';

class HOFHomeScreen extends StatelessWidget {
  const HOFHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final Map<String, dynamic>? data = authProvider.familyData;
    
    if (data == null) {
      return const Scaffold(body: Center(child: Text('No data found.')));
    }
    
    final family = FamilyModel.fromMap(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Family Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, family),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Family Members (${family.members.length})', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => context.push('/family/edit', extra: family),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...family.members.map((m) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: m.photoUrl.isNotEmpty ? NetworkImage(m.photoUrl) : null,
                  child: m.photoUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(m.name),
                subtitle: Text('${m.relationship} • Age: ${m.age}'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, FamilyModel family) {
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
                  Text(family.hofName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Family ID: ${family.serialNumber}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  Text('${family.city}, ${family.state}'),
                  Text('+91 ${family.mobile}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

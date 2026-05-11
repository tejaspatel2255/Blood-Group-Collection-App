import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/family_model.dart';
import '../../core/constants/app_colors.dart';
import '../../services/pdf_service.dart';

class HOFHomeScreen extends StatelessWidget {
  const HOFHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final Map<String, dynamic>? data = authProvider.familyData;
    
    if (data == null) {
      return const Scaffold(body: Center(child: Text('No data found.')));
    }
    
    final family = FamilyModel.fromMap(data, authProvider.familyId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Family Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, family.headOfFamily, family.serialNumber),
            const SizedBox(height: 24),
            Text('Family Members (${family.members.length})', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...family.members.map((m) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: m.localPhotoPath != null ? NetworkImage(m.localPhotoPath!) : null,
                  child: m.localPhotoPath == null ? const Icon(Icons.person) : null,
                ),
                title: Text('${m.firstName} ${m.lastName}'),
                subtitle: Text('${m.relationWithHOF} • Age: ${m.age}'),
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final pdfService = PdfService();
                    await pdfService.generateFamilyIDCard(family);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Family ID Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, HeadOfFamily hof, String id) {
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
                  Text('${hof.firstName} ${hof.lastName}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('Family ID: $id', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  Text('${hof.village}, ${hof.district}'),
                  Text('+91 ${hof.mobileNumber}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

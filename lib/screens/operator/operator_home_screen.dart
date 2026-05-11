import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../models/family_model.dart';
import '../../widgets/family_card.dart';

class OperatorHomeScreen extends StatelessWidget {
  const OperatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final familyProvider = context.watch<FamilyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
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
      body: StreamBuilder<List<FamilyModel>>(
        stream: familyProvider.getOperatorFamilies(authProvider.currentOperatorUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final families = snapshot.data ?? [];
          
          if (families.isEmpty) {
            return const Center(
              child: Text('No family entries created yet. Tap + to add one.'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: families.length,
            itemBuilder: (context, index) {
              return FamilyCard(
                family: families[index],
                onTap: () {
                  context.push('/family_details', extra: families[index]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/operator/new_entry'),
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }
}

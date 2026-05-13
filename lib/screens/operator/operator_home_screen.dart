import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../widgets/family_card.dart';
import '../../models/family_model.dart';

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentOperatorUid.isNotEmpty) {
      context.read<FamilyProvider>().loadFamiliesByOperator(authProvider.currentOperatorUid);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search();
    });
  }

  void _search() {
    final query = _searchController.text.trim();
    final authProvider = context.read<AuthProvider>();
    if (query.isNotEmpty) {
      context.read<FamilyProvider>().searchFamiliesForOperator(query, authProvider.currentOperatorUid);
    } else {
      _loadData();
    }
  }

  void _confirmDelete(FamilyModel family) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text("Are you sure you want to delete ${family.hofName}'s record?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<FamilyProvider>().deleteFamily(family.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record deleted')));
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
    final familyProvider = context.watch<FamilyProvider>();
    final families = familyProvider.families;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by Name, Mobile, or Serial No',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadData();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('New Family Entry'),
                onPressed: () {
                  context.push('/operator/new_entry');
                },
              ),
            ),
          ),
          Expanded(
            child: familyProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : familyProvider.error.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                familyProvider.error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    : families.isEmpty
                        ? const Center(child: Text('No entries found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: families.length,
                            itemBuilder: (context, index) {
                            final family = families[index];
                            return FamilyCard(
                              family: family,
                              onTap: () {
                                context.push('/family_details', extra: family);
                              },
                              onEdit: () {
                                context.push('/family/edit', extra: family);
                              },
                              onDelete: () => _confirmDelete(family),
                            );
                          },
                      ),
          ),
        ],
      ),
    );
  }
}

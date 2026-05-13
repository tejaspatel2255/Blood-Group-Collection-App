import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../models/family_model.dart';
import '../../widgets/family_card.dart';
import '../../services/auth_service.dart';
import '../../core/utils/app_error.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedOperatorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().loadFamilies();
      context.read<FamilyProvider>().loadOperators();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<FamilyProvider>().searchFamilies(query);
    } else if (_selectedOperatorId != null) {
      context.read<FamilyProvider>().loadFamiliesByOperator(_selectedOperatorId!);
    } else {
      context.read<FamilyProvider>().loadFamilies();
    }
  }

  void _confirmDelete(FamilyModel family) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text("Are you sure you want to delete ${family.hofName}'s record? Admin privileges will permanently remove this data."),
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

  void _showAddOperatorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _AddOperatorDialog(),
    );
  }


  @override
  Widget build(BuildContext context) {
    final familyProvider = context.watch<FamilyProvider>();
    final families = familyProvider.families;
    
    int totalMembers = families.length; // Counting HOFs
    for (var f in families) {
      totalMembers += f.members.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FamilyProvider>().loadFamilies();
              context.read<FamilyProvider>().loadOperators();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: familyProvider.isLoading && families.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCard(context, families.length, totalMembers),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search families...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              hint: const Text('Filter'),
                              value: _selectedOperatorId,
                              underline: const SizedBox(),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('All Operators')),
                                ...familyProvider.operators.map((op) => DropdownMenuItem(
                                      value: op['id'],
                                      child: Text(op['name'] ?? 'Unknown'),
                                    )),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedOperatorId = val);
                                _performSearch();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Operator'),
                          onPressed: () => _showAddOperatorDialog(context),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (familyProvider.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      familyProvider.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: families.isEmpty
                      ? const Center(child: Text('No families found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: families.length,
                          itemBuilder: (context, index) {
                            final family = families[index];
                            final operatorData = familyProvider.operators.firstWhere(
                              (op) => op['id'] == family.createdBy,
                              orElse: () => {'name': 'Unknown'},
                            );
                            return FamilyCard(
                              family: family,
                              operatorName: operatorData['name'],
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

  Widget _buildStatsCard(BuildContext context, int families, int members) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(title: 'Total Families', value: families.toString()),
          _StatItem(title: 'Total Members', value: members.toString()),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  
  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _AddOperatorDialog extends StatefulWidget {
  const _AddOperatorDialog();

  @override
  State<_AddOperatorDialog> createState() => _AddOperatorDialogState();
}

class _AddOperatorDialogState extends State<_AddOperatorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = AuthService();
        await authService.signupOperator(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operator added successfully!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppError.friendly(e))));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Data Entry Operator'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
              validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter valid email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _submit, child: const Text('Create Account')),
      ],
    );
  }
}

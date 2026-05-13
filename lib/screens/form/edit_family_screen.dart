import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/family_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';

import 'step1_basic_info.dart';
import 'step2_address_contact.dart';
import 'step3_education_occupation.dart';
import 'step4_family_composition.dart';

class EditFamilyScreen extends StatefulWidget {
  final FamilyModel family;

  const EditFamilyScreen({super.key, required this.family});

  @override
  State<EditFamilyScreen> createState() => _EditFamilyScreenState();
}

class _EditFamilyScreenState extends State<EditFamilyScreen> {
  int _currentStep = 0;
  late FamilyModel _family;
  Uint8List? _hofPhoto;
  
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Deep copy to avoid modifying the original before submit
    _family = widget.family.copyWith(
      members: widget.family.members.map((m) => m.copyWith()).toList(),
    );
  }

  void _nextStep() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _step1Key.currentState?.validate() ?? false;
        if (isValid) _step1Key.currentState?.save();
        break;
      case 1:
        isValid = _step2Key.currentState?.validate() ?? false;
        if (isValid) _step2Key.currentState?.save();
        break;
      case 2:
        isValid = _step3Key.currentState?.validate() ?? false;
        if (isValid) _step3Key.currentState?.save();
        break;
      case 3:
        isValid = true;
        break;
    }

    if (isValid) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);
    try {
      final supabaseService = SupabaseService();
      
      // Handle photo update if a new one was selected
      if (_hofPhoto != null) {
        try {
          final photoUrl = await supabaseService.uploadPhoto(
            _hofPhoto!,
            'hof_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          _family.photoUrl = photoUrl;
        } catch (e) {
          debugPrint('Photo upload failed: $e');
          // We continue with existing photo if upload fails
        }
      }
      
      if (!mounted) return;
      final success = await context.read<FamilyProvider>().updateFamily(_family);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family record updated successfully!')),
        );
        context.pop(); // Go back to details or list
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<FamilyProvider>().error)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isHOF = authProvider.role == UserRole.hof;

    return Scaffold(
      appBar: AppBar(title: Text(isHOF ? 'Edit My Profile' : 'Edit Family Record')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _previousStep,
              steps: [
                Step(
                  title: const Text('Basic'),
                  content: Step1BasicInfo(
                    formKey: _step1Key,
                    family: _family,
                    onPhotoSelected: (file) => setState(() => _hofPhoto = file),
                    initialPhoto: _hofPhoto,
                    isEditing: true,
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Address'),
                  content: Step2AddressContact(
                    formKey: _step2Key,
                    family: _family,
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Edu/Occ'),
                  content: Step3EducationOccupation(
                    formKey: _step3Key,
                    family: _family,
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Members'),
                  content: Step4FamilyComposition(
                    members: _family.members,
                    onMembersUpdated: (updatedMembers) {
                      setState(() {
                        _family.members = updatedMembers;
                      });
                    },
                  ),
                  isActive: _currentStep >= 3,
                ),
              ],
            ),
    );
  }
}

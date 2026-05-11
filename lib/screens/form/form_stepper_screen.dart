import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/family_model.dart';
import '../../models/member_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../services/storage_service.dart';

import 'step1_basic_info.dart';
import 'step2_address_contact.dart';
import 'step3_education_occupation.dart';
import 'step4_family_composition.dart';

class FormStepperScreen extends StatefulWidget {
  const FormStepperScreen({super.key});

  @override
  State<FormStepperScreen> createState() => _FormStepperScreenState();
}

class _FormStepperScreenState extends State<FormStepperScreen> {
  int _currentStep = 0;
  
  final HeadOfFamily _hof = HeadOfFamily(
    firstName: '',
    lastName: '',
    bloodGroup: '',
    dob: DateTime.now(),
    age: 0,
    maritalStatus: '',
  );
  
  final List<MemberModel> _members = [];
  
  File? _hofPhoto;
  
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  
  bool _isSubmitting = false;

  void _nextStep() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _step1Key.currentState?.validate() ?? false;
        if (isValid && _hofPhoto == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload a photo')),
          );
          isValid = false;
        }
        break;
      case 1:
        isValid = _step2Key.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _step3Key.currentState?.validate() ?? false;
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
      final authProvider = context.read<AuthProvider>();
      final storageService = StorageService();
      
      String photoUrl = '';
      if (_hofPhoto != null) {
        photoUrl = await storageService.uploadPhoto(_hofPhoto!, 'hof_photos');
      }
      
      _hof.photoUrl = photoUrl;
      
      final family = FamilyModel(
        id: const Uuid().v4(),
        serialNumber: '',
        headOfFamily: _hof,
        members: _members,
        createdBy: authProvider.currentOperatorUid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final success = await context.read<FamilyProvider>().submitFamilyEntry(family);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family entry created successfully!')),
        );
        context.go('/operator/home');
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
    return Scaffold(
      appBar: AppBar(title: const Text('New Family Entry')),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _previousStep,
              steps: [
                Step(
                  title: const Text('Basic Info'),
                  content: Step1BasicInfo(
                    formKey: _step1Key,
                    hof: _hof,
                    onPhotoSelected: (file) => _hofPhoto = file,
                    initialPhoto: _hofPhoto,
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Address'),
                  content: Step2AddressContact(
                    formKey: _step2Key,
                    hof: _hof,
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Education'),
                  content: Step3EducationOccupation(
                    formKey: _step3Key,
                    hof: _hof,
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Members'),
                  content: Step4FamilyComposition(
                    members: _members,
                    onMembersUpdated: (updatedMembers) {
                      setState(() {
                        _members.clear();
                        _members.addAll(updatedMembers);
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

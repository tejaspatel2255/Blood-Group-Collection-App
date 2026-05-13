import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/password_generator.dart';
import '../../models/family_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../services/supabase_service.dart';

import '../../services/draft_service.dart';

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
  final DraftService _draftService = DraftService();
  
  int _draftVersion = 0;
  
  FamilyModel _family = FamilyModel(
    serialNumber: '',
    createdBy: '',
    hofName: '',
    age: 0,
    gender: '',
    bloodGroup: '',
    maritalStatus: '',
    mobile: '',
    loginUsername: '',
    loginPassword: '',
  );
  
  Uint8List? _hofPhoto;
  
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<Step4FamilyCompositionState>();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDraft());
  }

  Future<void> _checkDraft() async {
    final draftData = await _draftService.loadDraft();
    if (draftData != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Continue Registration?'),
          content: const Text('We found a saved draft from your previous session. Would you like to continue or start fresh?'),
          actions: [
            TextButton(
              onPressed: () async {
                await _draftService.clearDraft();
                Navigator.pop(ctx);
              },
              child: const Text('Start New'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _family = draftData['family'];
                  _hofPhoto = draftData['photo'];
                  _draftVersion++; // This will force children to rebuild with new data
                });
                Navigator.pop(ctx);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  void _saveDraft() {
    _draftService.saveDraft(_family, _hofPhoto);
  }

  void _nextStep() {
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        // 1. Check photo first before form validation
        final hasPhoto = _hofPhoto != null || _family.photoUrl.isNotEmpty;
        if (!hasPhoto) {
          // Tell step1 widget to show inline error
          (_step1Key.currentContext?.findAncestorStateOfType<State>()
              as dynamic)?.markPhotoError?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload a photo (10 KB – 100 KB)')),
          );
          isValid = false;
          break;
        }
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
        // Validate all member photos via the public state key
        isValid = _step4Key.currentState?.validate() ?? true;
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All members must have a photo uploaded.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
    }

    if (isValid) {
      _saveDraft();
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
      final supabaseService = SupabaseService();
      
      String photoUrl = '';
      if (_hofPhoto != null) {
        try {
          photoUrl = await supabaseService.uploadPhoto(
            _hofPhoto!,
            'hof_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Photo upload failed: ${e.toString()}\n\nTip: Check if bucket "photos" is public and allows inserts.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 10),
              ),
            );
          }
        }
      }
      
      _family.photoUrl = photoUrl;
      _family.createdBy = authProvider.currentOperatorUid;
      
      // Generate credentials
      _family.loginUsername = _family.mobile;
      if (_family.dob != null) {
        _family.loginPassword = PasswordGenerator.generateHOFPassword(_family.hofName, _family.dob!);
      }
      if (!mounted) return;
      final success = await context.read<FamilyProvider>().addFamily(_family);
      
      if (success && mounted) {
        await _draftService.clearDraft();
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
                  title: const Text('Basic'),
                  content: Step1BasicInfo(
                    key: ValueKey('step1_${_draftVersion.toString()}'),
                    formKey: _step1Key,
                    family: _family,
                    onPhotoSelected: (file) {
                      setState(() {
                        _hofPhoto = file;
                        _saveDraft();
                      });
                    },
                    initialPhoto: _hofPhoto,
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Address'),
                  content: Step2AddressContact(
                    key: ValueKey('step2_${_draftVersion.toString()}'),
                    formKey: _step2Key,
                    family: _family,
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Edu/Occ'),
                  content: Step3EducationOccupation(
                    key: ValueKey('step3_${_draftVersion.toString()}'),
                    formKey: _step3Key,
                    family: _family,
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Members'),
                  content: Step4FamilyComposition(
                    key: _step4Key,
                    members: _family.members,
                    onMembersUpdated: (updatedMembers) {
                      setState(() {
                        _family.members = updatedMembers;
                        _saveDraft();
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

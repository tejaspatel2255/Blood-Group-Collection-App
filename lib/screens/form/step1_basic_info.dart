import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dropdown_data.dart';
import '../../core/utils/age_calculator.dart';
import '../../models/family_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/photo_picker_widget.dart';

class Step1BasicInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final FamilyModel family;
  final Function(Uint8List?) onPhotoSelected;
  final Uint8List? initialPhoto;
  final bool isEditing;

  const Step1BasicInfo({
    super.key,
    required this.formKey,
    required this.family,
    required this.onPhotoSelected,
    this.initialPhoto,
    this.isEditing = false,
  });

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  late TextEditingController _nameController;
  late TextEditingController _fatherHusbandController;
  late TextEditingController _motherController;
  late TextEditingController _dobController;
  late TextEditingController _ageController;

  bool _photoError = false;

  static const int _minPhotoBytes = 10240;  // 10 KB
  static const int _maxPhotoBytes = 102400; // 100 KB

  static final _nameRegex = RegExp(r'^[a-zA-Z\s\.\-]+$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.family.hofName);
    _fatherHusbandController = TextEditingController(text: widget.family.fatherHusbandName);
    _motherController = TextEditingController(text: widget.family.motherName);
    _dobController = TextEditingController(
      text: widget.family.dob != null
          ? DateFormat('dd/MM/yyyy').format(widget.family.dob!)
          : '',
    );
    _ageController = TextEditingController(
      text: widget.family.dob != null ? widget.family.age.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherHusbandController.dispose();
    _motherController.dispose();
    _dobController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // ── Photo with size validation ─────────────────────────────────────────────
  void _onPhotoSelected(Uint8List? bytes) {
    if (bytes == null) return;
    if (bytes.lengthInBytes < _minPhotoBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size must be at least 10 KB')),
      );
      return;
    }
    if (bytes.lengthInBytes > _maxPhotoBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image size must not exceed 100 KB')),
      );
      return;
    }
    setState(() => _photoError = false);
    widget.onPhotoSelected(bytes);
  }

  // ── Date picker ────────────────────────────────────────────────────────────
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.family.dob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final age = AgeCalculator.calculateAge(picked);
      setState(() {
        widget.family.dob = picked;
        widget.family.age = age;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
        _ageController.text = age.toString();
      });
    }
  }

  // ── Called by FormStepperScreen to check photo before form.validate() ──────
  bool get hasPhoto =>
      widget.initialPhoto != null || widget.family.photoUrl.isNotEmpty;

  void markPhotoError() => setState(() => _photoError = true);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HOF Photo (REQUIRED) ────────────────────────────────────────
          PhotoPickerWidget(
            initialImage: widget.initialPhoto,
            imageUrl: widget.family.photoUrl,
            onImageSelected: _onPhotoSelected,
          ),
          if (_photoError)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.error_outline, size: 14, color: AppColors.error),
                  SizedBox(width: 4),
                  Text(
                    'Photo is required',
                    style: TextStyle(fontSize: 12, color: AppColors.error),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 20),
            child: Center(
              child: Text(
                'Photo required • 10 KB – 100 KB • JPG / PNG',
                style: TextStyle(
                  fontSize: 11,
                  color: _photoError ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // ── Full Name ───────────────────────────────────────────────────
          CustomTextField(
            label: 'Full Name *',
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.hofName = val;
              if (val.isEmpty) return 'Full Name is required';
              if (val.length < 2) return 'Full Name must be at least 2 characters';
              if (val.length > 100) return 'Full Name too long (max 100 chars)';
              if (!_nameRegex.hasMatch(val)) return 'Enter a valid Full Name (letters and spaces only)';
              return null;
            },
          ),

          // ── Father / Husband Name ───────────────────────────────────────
          CustomTextField(
            label: "Father's / Husband's Name *",
            controller: _fatherHusbandController,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.fatherHusbandName = val;
              if (val.isEmpty) return "Father's / Husband's Name is required";
              if (val.length < 2) return 'Name must be at least 2 characters';
              if (val.length > 100) return 'Name too long (max 100 chars)';
              if (!_nameRegex.hasMatch(val)) return 'Enter a valid name (letters and spaces only)';
              return null;
            },
          ),

          // ── Mother Name ─────────────────────────────────────────────────
          CustomTextField(
            label: "Mother's Name *",
            controller: _motherController,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              final val = v?.trim() ?? '';
              widget.family.motherName = val;
              if (val.isEmpty) return "Mother's Name is required";
              if (val.length < 2) return 'Name must be at least 2 characters';
              if (val.length > 100) return 'Name too long (max 100 chars)';
              if (!_nameRegex.hasMatch(val)) return 'Enter a valid name (letters and spaces only)';
              return null;
            },
          ),

          // ── DOB + Age ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Date of Birth *',
                      controller: _dobController,
                      validator: (_) {
                        if (widget.family.dob == null) return 'Date of Birth is required';
                        if (widget.family.dob!.isAfter(DateTime.now())) {
                          return 'Cannot be a future date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Age (auto)',
                  controller: _ageController,
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  validator: (_) => null, // Error shown on DOB field
                ),
              ),
            ],
          ),

          // ── Gender ──────────────────────────────────────────────────────
          CustomDropdown(
            label: 'Gender *',
            items: DropdownData.genders,
            selectedItem: widget.family.gender.isNotEmpty ? widget.family.gender : null,
            onChanged: (v) => setState(() => widget.family.gender = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Gender is required' : null,
          ),

          // ── Blood Group ─────────────────────────────────────────────────
          CustomDropdown(
            label: 'Blood Group *',
            items: DropdownData.bloodGroups,
            selectedItem: widget.family.bloodGroup.isNotEmpty ? widget.family.bloodGroup : null,
            onChanged: (v) => setState(() => widget.family.bloodGroup = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Blood Group is required' : null,
          ),

          // ── Marital Status ──────────────────────────────────────────────
          CustomDropdown(
            label: 'Marital Status *',
            items: DropdownData.maritalStatuses,
            selectedItem: widget.family.maritalStatus.isNotEmpty ? widget.family.maritalStatus : null,
            onChanged: (v) => setState(() => widget.family.maritalStatus = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Marital Status is required' : null,
          ),

          // ── Area ──────────────────────────────────────────────────────────
          CustomDropdown(
            label: 'Area *',
            items: const ['Motapore', 'Nanapore', 'Vachewad'],
            selectedItem: widget.family.area.isNotEmpty ? widget.family.area : null,
            onChanged: (v) => setState(() => widget.family.area = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Area is required' : null,
          ),
        ],
      ),
    );
  }
}

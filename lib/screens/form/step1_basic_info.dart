import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants/dropdown_data.dart';
import '../../models/family_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/photo_picker_widget.dart';

class Step1BasicInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final FamilyModel family;
  final Function(Uint8List?) onPhotoSelected;
  final Uint8List? initialPhoto;

  const Step1BasicInfo({
    super.key,
    required this.formKey,
    required this.family,
    required this.onPhotoSelected,
    this.initialPhoto,
  });

  @override
  State<Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  late TextEditingController _nameController;
  late TextEditingController _fatherHusbandController;
  late TextEditingController _motherController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.family.hofName);
    _fatherHusbandController = TextEditingController(text: widget.family.fatherHusbandName);
    _motherController = TextEditingController(text: widget.family.motherName);
    _ageController = TextEditingController(text: widget.family.age > 0 ? widget.family.age.toString() : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherHusbandController.dispose();
    _motherController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.family.dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.family.dob) {
      setState(() {
        widget.family.dob = picked;
        // Basic age calc
        widget.family.age = DateTime.now().year - picked.year;
        _ageController.text = widget.family.age.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          PhotoPickerWidget(
            initialImage: widget.initialPhoto,
            onImageSelected: widget.onPhotoSelected,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Full Name',
            controller: _nameController,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter full name';
              widget.family.hofName = v;
              return null;
            },
          ),
          CustomTextField(
            label: 'Father/Husband Name',
            controller: _fatherHusbandController,
            validator: (v) {
              if (v != null) widget.family.fatherHusbandName = v;
              return null;
            },
          ),
          CustomTextField(
            label: 'Mother Name',
            controller: _motherController,
            validator: (v) {
              if (v != null) widget.family.motherName = v;
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: 'Date of Birth',
                      controller: TextEditingController(
                        text: widget.family.dob != null
                            ? "${widget.family.dob!.day}/${widget.family.dob!.month}/${widget.family.dob!.year}"
                            : '',
                      ),
                      validator: (v) => widget.family.dob == null ? 'Required' : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  readOnly: widget.family.dob != null, // read-only if DOB is set
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    widget.family.age = int.tryParse(v) ?? 0;
                    return null;
                  },
                ),
              ),
            ],
          ),
          CustomDropdown(
            label: 'Gender',
            items: DropdownData.genders,
            selectedItem: widget.family.gender.isNotEmpty ? widget.family.gender : null,
            onChanged: (v) {
              setState(() => widget.family.gender = v ?? '');
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          CustomDropdown(
            label: 'Blood Group',
            items: DropdownData.bloodGroups,
            selectedItem: widget.family.bloodGroup.isNotEmpty ? widget.family.bloodGroup : null,
            onChanged: (v) {
              setState(() => widget.family.bloodGroup = v ?? '');
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          CustomDropdown(
            label: 'Marital Status',
            items: DropdownData.maritalStatuses,
            selectedItem: widget.family.maritalStatus.isNotEmpty ? widget.family.maritalStatus : null,
            onChanged: (v) {
              setState(() => widget.family.maritalStatus = v ?? '');
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
